-- =====================================================================
-- pruefregeln_der_pipeline.sql
--
-- Zeigt, was die Pipeline bei ihrem letzten Lauf zu jeder Prüfregel
-- aufgezeichnet hat: wie viele Zeilen bestanden haben und wie viele
-- gegen die Regel verstoßen.
--
-- Die Zahlen stammen aus dem Protokoll der Pipeline (Event Log), nicht
-- aus den Tabellen. Sie müssen zur Übersicht in datenqualitaet.sql
-- passen. So kontrollieren sich zwei unabhängige Wege gegenseitig.
--
-- Ausführen: im SQL-Editor einfügen und auf "Run" klicken.
-- Voraussetzung: Die Pipeline ki_nutzung_pipeline ist einmal gelaufen.
-- =====================================================================

WITH protokoll AS (
  SELECT *
  FROM event_log(TABLE(ki_nutzung.gold.fct_usage_events))
),

-- Nur der letzte Lauf zählt. Ohne diese Einschränkung würden sich die
-- Zahlen aller bisherigen Läufe aufsummieren.
letzter_lauf AS (
  SELECT origin.update_id AS lauf_id
  FROM protokoll
  WHERE event_type = 'create_update'
  ORDER BY timestamp DESC
  LIMIT 1
),

regeln AS (
  SELECT explode(from_json(
           details:flow_progress:data_quality:expectations,
           'array<struct<name: string, dataset: string, passed_records: bigint, failed_records: bigint>>'
         )) AS regel
  FROM protokoll
  WHERE event_type = 'flow_progress'
    AND origin.update_id = (SELECT lauf_id FROM letzter_lauf)
)

SELECT
  regel.dataset              AS tabelle,
  regel.name                 AS pruefregel,
  sum(regel.passed_records)  AS bestanden,
  sum(regel.failed_records)  AS verstoesse
FROM regeln
GROUP BY regel.dataset, regel.name
ORDER BY verstoesse DESC, tabelle, pruefregel;
