-- =====================================================================
-- 03_gold.sql  |  Schicht GOLD: fertige Auswertungen
--
-- Sieben Tabellen mit denselben Namen und derselben Rechenlogik wie im
-- Snowflake-Projekt ki-nutzung-kosten-analytics:
--
--   fct_usage_events                    Grundlage: jede KI-Anfrage einmal
--   mart_kosten_je_abteilung_monat      Frage 1
--   mart_aktive_nutzer_monat            Frage 2
--   mart_anwendungsfaelle_konformitaet  Frage 3
--   mart_kosten_je_anwendungsfall       Frage 4
--   mart_datenqualitaet                 Frage 5 (Übersicht mit Ampel)
--   mart_datenqualitaet_details         Frage 5 (betroffene Datensätze)
--
-- Diese Datei ist Teil der Pipeline und wird nicht einzeln ausgeführt.
-- =====================================================================

-- Faktentabelle: jede KI-Anfrage genau einmal, angereichert mit Kosten,
-- Abteilung und Markierungen für Datenqualitätsprobleme.
-- Kosten = Eingabe-Token x Preis / 1000 + Ausgabe-Token x Preis / 1000.
-- Entscheidung: Fehlgeschlagene Anfragen (status = 'fehler') kosten nichts.
-- Entscheidung: Doppelt gelieferte Ereignisse zählen nur einmal (zeilen_nr = 1).
-- PRÜFREGEL 2 (melden): Ereignisse ohne Anwendungsfall.
-- PRÜFREGEL 3 (melden): Nutzung nach dem Austritt.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.fct_usage_events (
  CONSTRAINT kosten_berechnet EXPECT (kosten_eur IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT anwendungsfall_zugeordnet EXPECT (hat_anwendungsfall),
  CONSTRAINT nutzung_vor_austritt EXPECT (NOT ist_nach_austritt)
)
COMMENT 'Ein Eintrag je KI-Anfrage, angereichert mit Kosten, Abteilung und Qualitätsmarkierungen. Grundlage aller Auswertungen.'
AS SELECT
  e.event_id,
  e.event_ts,
  cast(date_trunc('MONTH', e.event_ts) AS DATE)             AS event_monat,
  e.user_id,
  coalesce(d.department_name, 'Unbekannt')                  AS department_name,
  e.use_case_id,
  e.model_id,
  e.input_tokens,
  e.output_tokens,
  e.status,
  (e.status = 'erfolg')                                     AS ist_erfolg,
  CASE
    WHEN e.status = 'erfolg' THEN
        e.input_tokens  * m.price_per_1k_input_eur  / 1000
      + e.output_tokens * m.price_per_1k_output_eur / 1000
    ELSE 0
  END                                                       AS kosten_eur,
  (e.use_case_id IS NOT NULL)                               AS hat_anwendungsfall,
  (u.left_date IS NOT NULL AND cast(e.event_ts AS DATE) > u.left_date) AS ist_nach_austritt,
  (d.department_id IS NOT NULL)                             AS ist_bekannte_abteilung
FROM ki_nutzung.silver.usage_events e
LEFT JOIN ki_nutzung.silver.users       u ON e.user_id = u.user_id
LEFT JOIN ki_nutzung.silver.departments d ON u.department_id = d.department_id
LEFT JOIN ki_nutzung.silver.ai_models   m ON e.model_id = m.model_id
WHERE e.zeilen_nr = 1;

-- Frage 1: Was kostet KI pro Abteilung und Monat?
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_kosten_je_abteilung_monat
COMMENT 'Frage 1: KI-Kosten je Abteilung und Monat'
AS SELECT
  event_monat,
  department_name,
  count_if(ist_erfolg)                AS erfolgreiche_anfragen,
  sum(input_tokens + output_tokens)   AS token_gesamt,
  round(sum(kosten_eur), 2)           AS kosten_eur
FROM ki_nutzung.gold.fct_usage_events
GROUP BY event_monat, department_name;

-- Frage 2: Wie viele aktive Nutzer gab es je Monat?
-- Aktiv = mindestens eine erfolgreiche Anfrage im Monat.
-- Anfragen nach dem Austrittsdatum zählen nicht (sie erscheinen in der Qualitätsübersicht).
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_aktive_nutzer_monat
COMMENT 'Frage 2: Aktive Nutzer je Monat und Abteilung. Aktiv heißt: mindestens eine erfolgreiche Anfrage im Monat.'
AS SELECT
  event_monat,
  department_name,
  count(DISTINCT user_id) AS aktive_nutzer
FROM ki_nutzung.gold.fct_usage_events
WHERE ist_erfolg
  AND NOT ist_nach_austritt
GROUP BY event_monat, department_name;

-- Frage 3: Welcher Anteil der Anwendungsfälle ist freigegeben und vollständig dokumentiert?
-- Konform = Status 'freigegeben' und Dokumentation vollständig.
-- Eingestellte Anwendungsfälle zählen nicht mit.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_anwendungsfaelle_konformitaet
COMMENT 'Frage 3: Anteil der freigegebenen und vollständig dokumentierten Anwendungsfälle je Risikoklasse'
AS SELECT
  risk_class                                                                   AS risikoklasse,
  count(*)                                                                     AS anzahl_anwendungsfaelle,
  count_if(status = 'freigegeben' AND coalesce(documentation_complete, false)) AS anzahl_konform,
  round(
    count_if(status = 'freigegeben' AND coalesce(documentation_complete, false))
    / count(*) * 100, 1
  )                                                                            AS konform_prozent
FROM ki_nutzung.silver.use_cases
WHERE status <> 'eingestellt'
GROUP BY risk_class;

-- Frage 4: Welche Anwendungsfälle kosten am meisten je erfolgreicher Anfrage?
-- Nur Anwendungsfälle mit mindestens 100 Anfragen. Anfragen ohne Zuordnung bleiben außen vor.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_kosten_je_anwendungsfall
COMMENT 'Frage 4: Kosten je erfolgreicher Anfrage und Anwendungsfall'
AS SELECT
  u.use_case_name,
  u.risk_class                                                     AS risikoklasse,
  count_if(f.ist_erfolg)                                           AS erfolgreiche_anfragen,
  round(sum(f.kosten_eur), 2)                                      AS kosten_eur,
  round(sum(f.kosten_eur) / nullif(count_if(f.ist_erfolg), 0), 4)  AS kosten_je_erfolgreicher_anfrage_eur
FROM ki_nutzung.gold.fct_usage_events f
JOIN ki_nutzung.silver.use_cases u ON f.use_case_id = u.use_case_id
GROUP BY u.use_case_name, u.risk_class
HAVING count(*) >= 100;

-- Frage 5: Wo liegen Datenqualitätsprobleme?
-- Die vier bewusst eingebauten Probleme werden gezählt, bewertet und erklärt.
-- Sie werden nicht stillschweigend repariert, damit die Fachbereiche sie sehen.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_datenqualitaet
COMMENT 'Frage 5: Übersicht der Datenqualitätsprüfungen mit Ampel, Erklärung, Empfehlung und Zuständigkeit. grün = keine Auffälligkeit, gelb = weniger als 1 % betroffen, rot = 1 % oder mehr betroffen.'
AS
WITH pruefungen AS (

  SELECT
    'Doppelte Ereignisse'               AS pruefung,
    count(*) - count(DISTINCT event_id) AS betroffene_zeilen,
    count(*)                            AS geprueft,
    'Dasselbe Ereignis wurde mehrfach geliefert. Die Auswertung zählt es nur einmal.' AS erklaerung,
    'Prüfen, ob die Quelle doppelt exportiert oder geliefert hat.' AS empfehlung,
    'Quellsystem / IT'                  AS zustaendig
  FROM ki_nutzung.bronze.usage_events

  UNION ALL

  SELECT
    'Ereignisse ohne Anwendungsfall',
    count_if(NOT hat_anwendungsfall),
    count(*),
    'Es ist nicht bekannt, wofür die KI hier genutzt wurde. Die Kosten sind enthalten, aber keinem Anwendungsfall zuordenbar.',
    'Die Angabe des Anwendungsfalls bei der Nutzung zur Pflicht machen.',
    'Fachbereich / KI-Verantwortliche'
  FROM ki_nutzung.gold.fct_usage_events

  UNION ALL

  SELECT
    'Nutzung nach dem Austritt',
    count_if(ist_nach_austritt),
    count(*),
    'Ein Nutzerkonto war nach dem Austritt der Person noch aktiv. Mögliche Ursachen: Konto nicht gesperrt oder weitergegeben.',
    'Konten beim Austritt sperren und die Nutzung prüfen.',
    'IT / Personal'
  FROM ki_nutzung.gold.fct_usage_events

  UNION ALL

  SELECT
    'Nutzer mit unbekannter Abteilung',
    count_if(NOT ist_bekannte_abteilung),
    count(*),
    'Der Nutzer ist keiner bekannten Abteilung zugeordnet. Seine Kosten erscheinen unter der Abteilung Unbekannt.',
    'Die Stammdaten der Nutzer pflegen.',
    'Personal / Stammdaten'
  FROM ki_nutzung.silver.users

)
SELECT
  pruefung,
  betroffene_zeilen,
  geprueft,
  round(betroffene_zeilen / nullif(geprueft, 0) * 100, 2) AS anteil_prozent,
  CASE
    WHEN betroffene_zeilen = 0 THEN 'grün'
    WHEN betroffene_zeilen / nullif(geprueft, 0) < 0.01 THEN 'gelb'
    ELSE 'rot'
  END AS ampel,
  erklaerung,
  empfehlung,
  zustaendig
FROM pruefungen;

-- Die einzelnen betroffenen Datensätze zu jeder Prüfung.
-- Damit können Fachbereiche und IT gezielt nachsehen und korrigieren.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.gold.mart_datenqualitaet_details
COMMENT 'Frage 5: Die einzelnen betroffenen Datensätze zu jeder Datenqualitätsprüfung'
AS
SELECT
  'Doppelte Ereignisse'                               AS pruefung,
  'Ereignis'                                          AS objekt_typ,
  event_id                                            AS objekt_id,
  'in den Rohdaten ' || count(*) || ' Mal geliefert'  AS detail
FROM ki_nutzung.bronze.usage_events
GROUP BY event_id
HAVING count(*) > 1

UNION ALL

SELECT
  'Ereignisse ohne Anwendungsfall',
  'Ereignis',
  event_id,
  'Nutzer ' || user_id || ', ' || date_format(event_ts, 'yyyy-MM-dd HH:mm:ss.SSS')
FROM ki_nutzung.gold.fct_usage_events
WHERE NOT hat_anwendungsfall

UNION ALL

SELECT
  'Nutzung nach dem Austritt',
  'Ereignis',
  event_id,
  'Nutzer ' || user_id || ', ' || date_format(event_ts, 'yyyy-MM-dd HH:mm:ss.SSS')
FROM ki_nutzung.gold.fct_usage_events
WHERE ist_nach_austritt

UNION ALL

SELECT
  'Nutzer mit unbekannter Abteilung',
  'Nutzer',
  user_id,
  'Abteilungs-ID ' || coalesce(department_id, '(leer)')
FROM ki_nutzung.silver.users
WHERE NOT ist_bekannte_abteilung;
