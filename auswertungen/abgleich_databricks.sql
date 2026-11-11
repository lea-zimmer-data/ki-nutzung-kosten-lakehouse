-- =====================================================================
-- abgleich_databricks.sql
--
-- Abgleich Snowflake und Databricks: 21 Kennzahlen über alle sieben
-- Auswertungen. Dieselbe Abfrage gibt es für beide Plattformen, nur der
-- Ort der Tabellen unterscheidet sich. Stimmen alle 21 Werte überein,
-- liefern beide Plattformen dieselben Ergebnisse.
--
-- Diese Datei ist für Databricks. Ausführen: Datei öffnen und auf "Run all" klicken.
-- =====================================================================

SELECT '01 fct_usage_events: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.fct_usage_events

UNION ALL

SELECT '02 fct_usage_events: erfolgreiche Anfragen' AS kennzahl, cast(count_if(ist_erfolg) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.fct_usage_events

UNION ALL

SELECT '03 fct_usage_events: Summe Kosten' AS kennzahl, cast(sum(kosten_eur) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.fct_usage_events

UNION ALL

SELECT '04 fct_usage_events: Summe Token' AS kennzahl, cast(sum(input_tokens + output_tokens) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.fct_usage_events

UNION ALL

SELECT '05 Frage 1: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_abteilung_monat

UNION ALL

SELECT '06 Frage 1: Summe Kosten gerundet' AS kennzahl, cast(sum(kosten_eur) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_abteilung_monat

UNION ALL

SELECT '07 Frage 1: Kosten Kundenservice Dezember' AS kennzahl, cast(sum(kosten_eur) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_abteilung_monat
WHERE department_name = 'Kundenservice' AND event_monat = '2025-12-01'

UNION ALL

SELECT '08 Frage 2: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_aktive_nutzer_monat

UNION ALL

SELECT '09 Frage 2: Summe aktive Nutzer' AS kennzahl, cast(sum(aktive_nutzer) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_aktive_nutzer_monat

UNION ALL

SELECT '10 Frage 3: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_anwendungsfaelle_konformitaet

UNION ALL

SELECT '11 Frage 3: Summe konforme Anwendungsfaelle' AS kennzahl, cast(sum(anzahl_konform) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_anwendungsfaelle_konformitaet

UNION ALL

SELECT '12 Frage 3: Summe Konform-Prozent' AS kennzahl, cast(sum(konform_prozent) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_anwendungsfaelle_konformitaet

UNION ALL

SELECT '13 Frage 4: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_anwendungsfall

UNION ALL

SELECT '14 Frage 4: Summe Kosten' AS kennzahl, cast(sum(kosten_eur) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_anwendungsfall

UNION ALL

SELECT '15 Frage 4: Summe Kosten je Anfrage' AS kennzahl, cast(sum(kosten_je_erfolgreicher_anfrage_eur) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_kosten_je_anwendungsfall

UNION ALL

SELECT '16 Frage 5: Doppelte Ereignisse' AS kennzahl, cast(sum(betroffene_zeilen) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet
WHERE pruefung = 'Doppelte Ereignisse'

UNION ALL

SELECT '17 Frage 5: Ereignisse ohne Anwendungsfall' AS kennzahl, cast(sum(betroffene_zeilen) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet
WHERE pruefung = 'Ereignisse ohne Anwendungsfall'

UNION ALL

SELECT '18 Frage 5: Nutzung nach dem Austritt' AS kennzahl, cast(sum(betroffene_zeilen) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet
WHERE pruefung = 'Nutzung nach dem Austritt'

UNION ALL

SELECT '19 Frage 5: Nutzer mit unbekannter Abteilung' AS kennzahl, cast(sum(betroffene_zeilen) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet
WHERE pruefung = 'Nutzer mit unbekannter Abteilung'

UNION ALL

SELECT '20 Frage 5: Summe Anteil-Prozent' AS kennzahl, cast(sum(anteil_prozent) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet

UNION ALL

SELECT '21 Frage 5 Details: Zeilen' AS kennzahl, cast(count(*) AS DECIMAL(38, 6)) AS wert
FROM ki_nutzung.gold.mart_datenqualitaet_details

ORDER BY kennzahl;
