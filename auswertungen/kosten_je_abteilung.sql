-- =====================================================================
-- kosten_je_abteilung.sql
--
-- Frage 1: Was kostet KI pro Abteilung?
-- Zeigt für den letzten Monat in den Daten je Abteilung die Zahl der
-- erfolgreichen Anfragen und die Kosten, die teuerste Abteilung zuerst.
--
-- Rechenregel: Fehlgeschlagene Anfragen kosten nichts.
-- Abteilung "Unbekannt": Nutzer, die keiner bekannten Abteilung
-- zugeordnet sind (siehe datenqualitaet.sql).
--
-- Ausführen: Datei öffnen und auf "Run all" klicken.
-- Voraussetzung: Die Pipeline ki_nutzung_pipeline ist einmal gelaufen.
-- =====================================================================

SELECT
  event_monat,
  department_name   AS abteilung,
  erfolgreiche_anfragen,
  kosten_eur
FROM ki_nutzung.gold.mart_kosten_je_abteilung_monat
WHERE event_monat = (
  SELECT max(event_monat)
  FROM ki_nutzung.gold.mart_kosten_je_abteilung_monat
)
ORDER BY kosten_eur DESC;
