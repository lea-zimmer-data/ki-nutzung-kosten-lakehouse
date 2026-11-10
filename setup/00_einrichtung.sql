-- =====================================================================
-- 00_einrichtung.sql
--
-- Legt in Databricks alles an, was das Projekt braucht:
--   1. den Katalog ki_nutzung (oberster Ordner für alle Daten)
--   2. je ein Schema für die Schichten bronze, silver, gold
--      und eines für die Werkzeuge des KI-Agenten
--   3. die Ablage (Volume) für die CSV-Dateien
--
-- Ausführen: einmal komplett im SQL-Editor ("Run all").
-- Die Datei kann gefahrlos mehrfach ausgeführt werden:
-- Bereits Vorhandenes wird übersprungen (IF NOT EXISTS).
-- =====================================================================

-- 1. Katalog
CREATE CATALOG IF NOT EXISTS ki_nutzung
  COMMENT 'KI-Nutzung und -Kosten mit synthetischen Beispieldaten';

-- 2. Schemas: eines je Schicht und eines für den Agenten
CREATE SCHEMA IF NOT EXISTS ki_nutzung.bronze
  COMMENT 'Rohdaten, unverändert eingelesen';

CREATE SCHEMA IF NOT EXISTS ki_nutzung.silver
  COMMENT 'Saubere Datentypen und Prüfregeln für die Datenqualität';

CREATE SCHEMA IF NOT EXISTS ki_nutzung.gold
  COMMENT 'Auswertungen für Fachbereiche, Genie und den KI-Agenten';

CREATE SCHEMA IF NOT EXISTS ki_nutzung.agent
  COMMENT 'Werkzeuge (Funktionen), die der KI-Agent aufrufen darf';

-- 3. Ablage für die CSV-Dateien aus scripts/generate_data.py
CREATE VOLUME IF NOT EXISTS ki_nutzung.bronze.rohdaten
  COMMENT 'CSV-Dateien mit den synthetischen Beispieldaten';

-- 4. Kontrolle: zeigt alle Schemas im Katalog.
--    Erwartet: agent, bronze, default, gold, information_schema, silver
--    (default und information_schema legt Databricks selbst an)
SHOW SCHEMAS IN ki_nutzung;
