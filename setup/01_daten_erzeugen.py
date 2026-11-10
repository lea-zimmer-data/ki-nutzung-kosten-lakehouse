# Databricks notebook source
# MAGIC %md
# MAGIC # 01 Beispieldaten erzeugen
# MAGIC
# MAGIC Dieses Notebook startet den Datengenerator `scripts/generate_data.py` und legt fünf CSV-Dateien in die Ablage `/Volumes/ki_nutzung/bronze/rohdaten`.
# MAGIC
# MAGIC - Alle Daten sind **frei erfunden**.
# MAGIC - Der Generator ist **unverändert** aus dem Snowflake-Projekt [ki-nutzung-kosten-analytics](https://github.com/lea-zimmer-data/ki-nutzung-kosten-analytics) übernommen. Mit demselben Startwert 42 entstehen genau dieselben Daten, auch die vier bewusst eingebauten Datenfehler.
# MAGIC - **Voraussetzung:** `setup/00_einrichtung.sql` wurde ausgeführt.
# MAGIC
# MAGIC **Ausführen:** oben auf **Run all** klicken. Mehrfaches Ausführen ist unproblematisch, die Dateien werden mit identischem Inhalt überschrieben.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Schritt 1: Daten erzeugen

# COMMAND ----------

import sys
from pathlib import Path

ZIEL = Path("/Volumes/ki_nutzung/bronze/rohdaten")
STARTWERT = 42


def repo_ordner() -> Path:
    """Findet den Hauptordner des Repos, egal wo der Git-Ordner im Workspace liegt."""
    kandidat = Path.cwd().parent
    if (kandidat / "scripts" / "generate_data.py").exists():
        return kandidat
    notebook = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
    return Path("/Workspace" + notebook).parent.parent


sys.path.insert(0, str(repo_ordner() / "scripts"))
import generate_data  # noqa: E402

generate_data.main(STARTWERT, ZIEL)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Schritt 2: Kontrolle
# MAGIC
# MAGIC Prüft, ob alle fünf Dateien da sind und so viele Zeilen haben wie im Snowflake-Projekt.

# COMMAND ----------

ERWARTET = {
    "departments.csv": 8,
    "ai_models.csv": 3,
    "users.csv": 220,
    "use_cases.csv": 15,
    "usage_events.csv": 55861,
}

alles_ok = True
for name, soll in ERWARTET.items():
    datei = ZIEL / name
    if datei.exists():
        with open(datei, encoding="utf-8") as f:
            ist = sum(1 for _ in f) - 1  # ohne Kopfzeile
    else:
        ist = 0
    ok = ist == soll
    alles_ok = alles_ok and ok
    print(f"{'✓' if ok else '✗'} {name:<18} {ist:>6} Zeilen (erwartet {soll})")

print()
if alles_ok:
    print("Alles in Ordnung: gleiche Zeilenzahlen wie im Snowflake-Projekt.")
else:
    print("Abweichung gefunden. Bitte prüfen, ob setup/00_einrichtung.sql ausgeführt wurde.")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Schritt 3: Ein Blick in die Daten
# MAGIC
# MAGIC Die ersten zehn KI-Anfragen aus `usage_events.csv`. Jede Zeile ist eine Anfrage an ein KI-Modell: wer, wofür, mit welchem Modell, wie viele Token und ob sie erfolgreich war.

# COMMAND ----------

display(
    spark.read.option("header", True)
    .csv(str(ZIEL / "usage_events.csv"))
    .limit(10)
)
