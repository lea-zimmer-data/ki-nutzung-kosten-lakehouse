-- =====================================================================
-- datenqualitaet.sql
--
-- Frage 5: Wo liegen Datenqualitätsprobleme?
-- Zeigt die Übersicht mit Ampel, Erklärung, Empfehlung und Zuständigkeit.
--   grün = keine Auffälligkeit
--   gelb = weniger als 1 % betroffen
--   rot  = 1 % oder mehr betroffen
--
-- Ausführen: im SQL-Editor einfügen und auf "Run" klicken.
-- Voraussetzung: Die Pipeline ki_nutzung_pipeline ist einmal gelaufen.
-- =====================================================================

SELECT
  pruefung,
  betroffene_zeilen,
  geprueft,
  anteil_prozent,
  ampel,
  erklaerung,
  empfehlung,
  zustaendig
FROM ki_nutzung.gold.mart_datenqualitaet
ORDER BY pruefung;
