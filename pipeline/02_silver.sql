-- =====================================================================
-- 02_silver.sql  |  Schicht SILVER: saubere Datentypen und Prüfregeln
--
-- Macht aus Text echte Zahlen, Datumswerte und Ja/Nein-Felder.
-- Dazu kommen Prüfregeln (in Databricks: "Expectations").
--
-- Es gibt zwei Arten von Prüfregeln:
--
--   MELDEN  (ohne Zusatz)
--     Die Zeile bleibt in der Tabelle, der Verstoß wird gezählt und in
--     der Pipeline angezeigt. So bleiben Fehler sichtbar, und ein Mensch
--     entscheidet, was damit geschieht.
--
--   STOPPEN (ON VIOLATION FAIL UPDATE)
--     Die Pipeline bricht ab. Das gilt nur für Fehler, bei denen jede
--     Auswertung falsch würde, zum Beispiel ein unbekannter Status.
--
-- Bewusst gibt es keine Regel, die Zeilen still aussortiert.
--
-- Diese Datei ist Teil der Pipeline und wird nicht einzeln ausgeführt.
-- =====================================================================

-- Abteilungen: nur sauber benannt, keine Änderung am Inhalt.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.silver.departments (
  CONSTRAINT abteilungs_id_vorhanden EXPECT (department_id IS NOT NULL) ON VIOLATION FAIL UPDATE
)
COMMENT 'Abteilungen des Unternehmens (bereinigte Stammdaten)'
AS SELECT
  department_id,
  department_name,
  cost_center
FROM ki_nutzung.bronze.departments;

-- KI-Modelle: Preise von Text in Zahlen umwandeln.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.silver.ai_models (
  CONSTRAINT modell_id_vorhanden EXPECT (model_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT preise_vorhanden EXPECT (price_per_1k_input_eur IS NOT NULL AND price_per_1k_output_eur IS NOT NULL) ON VIOLATION FAIL UPDATE
)
COMMENT 'KI-Modelle mit ihren Preisen je 1.000 Eingabe- und Ausgabe-Token'
AS SELECT
  model_id,
  model_name,
  try_cast(price_per_1k_input_eur  AS DECIMAL(18, 6)) AS price_per_1k_input_eur,
  try_cast(price_per_1k_output_eur AS DECIMAL(18, 6)) AS price_per_1k_output_eur
FROM ki_nutzung.bronze.ai_models;

-- Nutzer: Datumsangaben umwandeln und prüfen, ob die Abteilung bekannt ist.
-- PRÜFREGEL 4 (melden): Nutzer mit unbekannter Abteilung.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.silver.users (
  CONSTRAINT nutzer_id_vorhanden EXPECT (user_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT abteilung_bekannt EXPECT (ist_bekannte_abteilung)
)
COMMENT 'Nutzer mit Abteilung, Eintritts- und Austrittsdatum'
AS SELECT
  u.user_id,
  u.department_id,
  try_cast(u.hired_date AS DATE) AS hired_date,
  try_cast(u.left_date  AS DATE) AS left_date,
  (d.department_id IS NOT NULL)  AS ist_bekannte_abteilung
FROM ki_nutzung.bronze.users u
LEFT JOIN ki_nutzung.bronze.departments d
  ON u.department_id = d.department_id;

-- Anwendungsfälle: Datum und Ja/Nein-Feld in passende Typen umwandeln.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.silver.use_cases (
  CONSTRAINT anwendungsfall_id_vorhanden EXPECT (use_case_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT risikoklasse_gueltig EXPECT (risk_class IN ('minimal', 'begrenzt', 'hoch')) ON VIOLATION FAIL UPDATE
)
COMMENT 'Anwendungsfälle der KI mit Risikoklasse, Status und Dokumentationsstand'
AS SELECT
  use_case_id,
  use_case_name,
  department_id,
  risk_class,
  status,
  try_cast(approved_date AS DATE)             AS approved_date,
  try_cast(documentation_complete AS BOOLEAN) AS documentation_complete
FROM ki_nutzung.bronze.use_cases;

-- KI-Anfragen: Typen umwandeln und Duplikate kennzeichnen.
-- Eine Prüfregel sieht immer nur eine Zeile. Damit sie Duplikate erkennt,
-- nummeriert die Hilfsspalte zeilen_nr alle Zeilen mit derselben event_id.
-- Die erste Lieferung hat die Nummer 1, jede weitere ist ein Duplikat.
-- PRÜFREGEL 1 (melden): doppelt gelieferte Ereignisse.
CREATE OR REFRESH MATERIALIZED VIEW ki_nutzung.silver.usage_events (
  CONSTRAINT event_id_vorhanden EXPECT (event_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT status_gueltig EXPECT (status IN ('erfolg', 'fehler')) ON VIOLATION FAIL UPDATE,
  CONSTRAINT event_id_eindeutig EXPECT (zeilen_nr = 1)
)
COMMENT 'KI-Anfragen mit sauberen Datentypen. Duplikate bleiben erhalten und sind über zeilen_nr > 1 erkennbar.'
AS SELECT
  event_id,
  try_cast(event_ts AS TIMESTAMP)   AS event_ts,
  user_id,
  nullif(use_case_id, '')           AS use_case_id,
  model_id,
  try_cast(input_tokens  AS INT)    AS input_tokens,
  try_cast(output_tokens AS INT)    AS output_tokens,
  try_cast(latency_ms    AS INT)    AS latency_ms,
  status,
  row_number() OVER (PARTITION BY event_id ORDER BY event_ts) AS zeilen_nr
FROM ki_nutzung.bronze.usage_events;
