-- =====================================================================
-- 01_bronze.sql  |  Schicht BRONZE: Rohdaten unverändert einlesen
--
-- Liest die fünf CSV-Dateien aus der Ablage
-- /Volumes/ki_nutzung/bronze/rohdaten und legt je Datei eine Tabelle an.
--
-- Grundsatz: Hier wird nichts verändert und nichts geprüft.
-- Alle Spalten bleiben Text (STRING), genau wie sie geliefert wurden.
-- So lässt sich später jederzeit nachsehen, was die Quelle geschickt hat.
--
-- Diese Datei ist Teil der Pipeline und wird nicht einzeln ausgeführt.
-- =====================================================================

CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.bronze.departments
COMMENT 'Rohdaten: Abteilungen, unverändert aus departments.csv'
AS SELECT *
FROM read_files(
  '/Volumes/ki_nutzung/bronze/rohdaten/departments.csv',
  format => 'csv',
  header => true,
  schema => 'department_id STRING, department_name STRING, cost_center STRING'
);

CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.bronze.ai_models
COMMENT 'Rohdaten: KI-Modelle und Preise, unverändert aus ai_models.csv'
AS SELECT *
FROM read_files(
  '/Volumes/ki_nutzung/bronze/rohdaten/ai_models.csv',
  format => 'csv',
  header => true,
  schema => 'model_id STRING, model_name STRING, price_per_1k_input_eur STRING, price_per_1k_output_eur STRING'
);

CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.bronze.users
COMMENT 'Rohdaten: Nutzer, unverändert aus users.csv'
AS SELECT *
FROM read_files(
  '/Volumes/ki_nutzung/bronze/rohdaten/users.csv',
  format => 'csv',
  header => true,
  schema => 'user_id STRING, department_id STRING, hired_date STRING, left_date STRING'
);

CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.bronze.use_cases
COMMENT 'Rohdaten: KI-Anwendungsfälle, unverändert aus use_cases.csv'
AS SELECT *
FROM read_files(
  '/Volumes/ki_nutzung/bronze/rohdaten/use_cases.csv',
  format => 'csv',
  header => true,
  schema => 'use_case_id STRING, use_case_name STRING, department_id STRING, risk_class STRING, status STRING, approved_date STRING, documentation_complete STRING'
);

CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.bronze.usage_events
COMMENT 'Rohdaten: KI-Anfragen, unverändert aus usage_events.csv (enthält bewusst Duplikate)'
AS SELECT *
FROM read_files(
  '/Volumes/ki_nutzung/bronze/rohdaten/usage_events.csv',
  format => 'csv',
  header => true,
  schema => 'event_id STRING, event_ts STRING, user_id STRING, use_case_id STRING, model_id STRING, input_tokens STRING, output_tokens STRING, latency_ms STRING, status STRING'
);
