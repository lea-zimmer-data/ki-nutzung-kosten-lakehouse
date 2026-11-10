# Databricks-Use-Case – Aufbau (Entwurf)

Stand: 10.11.2026

## Die Idee in einem Satz

Dieselben Daten und dieselben fünf Fachfragen wie im Snowflake-Projekt `ki-nutzung-kosten-analytics`, jetzt auf Databricks. Dazu kommt ein KI-Agent, der die Fragen beantwortet und bei jeder Zahl sagt, wie verlässlich sie ist.

**Botschaft:** Ein KI-Agent ist nur so gut wie die Daten, auf die er zugreift. Der Agent ist der Aufhänger, nicht die Botschaft. Im Mittelpunkt stehen die Datenbasis und die Prüfregeln.

## Namen

| Was | Name |
|---|---|
| GitHub-Repo | `lea-zimmer-data/ki-nutzung-kosten-lakehouse` (angelegt 10.11.2026, öffentlich, MIT, Python-.gitignore) |
| Beschreibung (About) | Verlässliche Daten für KI-Agenten: KI-Nutzung und -Kosten im Databricks Lakehouse, mit Beispieldaten |
| Topics | `databricks`, `lakehouse`, `unity-catalog`, `lakeflow`, `ai-agents`, `genie`, `data-quality`, `data-governance`, `beginner-friendly` |
| Katalog | `ki_nutzung` |
| Schemas | `bronze`, `silver`, `gold`, `agent` |
| Volume für die CSV-Dateien | `ki_nutzung.bronze.rohdaten` |
| Pipeline | `ki_nutzung_pipeline` |
| Genie Space | „KI-Kosten fragen“ |
| Agent | kein eigener Name, einfach „der Agent“ |
| App (optional) | `ki-nutzung-app` |

Lakehouse ist ein Architekturmuster und kein Produkt (Microsoft Fabric arbeitet zum Beispiel auch damit). Der Name bleibt also neutral gegenüber dem Anbieter und passt neben `ki-nutzung-kosten-analytics`: Beide sagen, wie die Daten aufbereitet werden, nicht mit welchem Werkzeug. Databricks steht nur in Beschreibung und Topics.

## Schichten

Rohdaten (CSV im Volume) → **Bronze** (unverändert eingelesen) → **Silver** (Datentypen, Prüfregeln) → **Gold** (Auswertungen) → Genie Space und Agent

### Silver: die vier Prüfregeln (Expectations)

| Datenproblem | Prüfregel | Verhalten |
|---|---|---|
| Doppelte `event_id` | `event_id_eindeutig` | melden; braucht eine Hilfsspalte, weil Prüfregeln zeilenweise prüfen |
| Events ohne `use_case_id` | `anwendungsfall_zugeordnet` | melden |
| Events nach dem Austritt | `nutzung_vor_austritt` | melden |
| Unbekannte `department_id` | `abteilung_bekannt` | melden |

„Melden“ heißt: Die Zeile bleibt drin, der Verstoß wird gezählt. Die Pipeline repariert nichts still, ein Mensch entscheidet.

### Gold: dieselben Namen wie im Snowflake-Projekt

`fct_usage_events`, `mart_kosten_je_abteilung_monat`, `mart_aktive_nutzer_monat`, `mart_anwendungsfaelle_konformitaet`, `mart_kosten_je_anwendungsfall`, `mart_datenqualitaet`, `mart_datenqualitaet_details`

## Der Agent in zwei Stufen

**Stufe 1: Genie Space „KI-Kosten fragen“** ohne Code, auf den Gold-Tabellen. Fachbereiche stellen die Fragen 1, 2 und 4 in eigenen Worten.

**Stufe 2: Agent mit Werkzeugen.** Die Werkzeuge sind Unity-Catalog-Funktionen im Schema `agent`:

| Werkzeug | Fachfrage |
|---|---|
| `kosten_je_abteilung(monat)` | 1 – Kosten je Abteilung und Monat |
| `aktive_nutzer(monat)` | 2 – aktive Nutzer je Monat |
| `konformitaet_je_risikoklasse()` | 3 – freigegeben und dokumentiert je Risikoklasse |
| `teuerste_anwendungsfaelle(anzahl)` | 4 – Kosten je erfolgreicher Anfrage |
| `datenqualitaet()` | 5 – Ampel-Übersicht |
| `betroffene_datensaetze(pruefung)` | 5 – betroffene Datensätze |

**Regel des Agenten:** Bevor er eine Zahl nennt, ruft er `datenqualitaet()` auf und nennt gelbe oder rote Prüfungen mit Zuständigkeit dazu. Er korrigiert nichts, er meldet.

Beispiel: „Was hat der Vertrieb im Oktober für KI ausgegeben?“ → Betrag, dazu der Hinweis, dass ein Teil der Ereignisse keinem Anwendungsfall zugeordnet ist, mit Ampel und Zuständigkeit (Fachbereich / KI-Verantwortliche).

**Testfragen:** 20 Fragen mit erwarteten Antworten aus den Gold-Tabellen, ausgewertet mit MLflow. Die Trefferquote steht in der README.

## Repo-Struktur

```
ki-nutzung-kosten-lakehouse/
├── README.md
├── LICENSE                        # MIT, wie im ersten Repo
├── .gitignore
├── scripts/
│   └── generate_data.py           # unverändert aus dem Snowflake-Repo
├── setup/
│   └── 00_einrichtung.sql         # Katalog, Schemas, Volume
├── pipeline/
│   ├── 01_bronze.sql
│   ├── 02_silver.sql              # mit den vier Prüfregeln
│   └── 03_gold.sql
├── agent/
│   ├── werkzeuge.sql              # die sechs Unity-Catalog-Funktionen
│   ├── agent.py                   # Agent mit Werkzeugen
│   ├── testfragen.yaml            # 20 Fragen mit erwarteten Antworten
│   └── genie_anweisungen.md       # Anweisungen und Beispielfragen für den Genie Space
├── app/                           # optional: Chat-Oberfläche
│   ├── app.py
│   └── app.yaml
└── docs/
    ├── architektur.svg
    ├── fachfragen.md              # dieselben fünf Fragen und Entscheidungen
    ├── datenqualitaet-verstehen.md
    ├── vergleich-snowflake-databricks.md
    ├── agent-verstehen.md         # für Fachbereiche: was der Agent darf und was nicht
    └── schnellstart-anfaenger.md
```

## Reihenfolge

1. **Einrichtung:** Free Edition, Katalog, Schemas, Volume. Der Generator schreibt direkt ins Volume (`--out /Volumes/ki_nutzung/bronze/rohdaten`). Gleicher Startwert 42 → gleiche Daten wie im Snowflake-Projekt.
2. **Pipeline:** Bronze → Silver → Gold mit den Prüfregeln.
3. **Abgleich:** Die Zahlen müssen mit dem Snowflake-Projekt übereinstimmen → `docs/vergleich-snowflake-databricks.md`.
4. **Genie Space** einrichten.
5. **Agent** mit Werkzeugen und Testfragen.
6. Optional: **App** als Chat-Oberfläche.
7. **README, Architekturbild, LinkedIn-Beitrag.**

**Anleitung für Endanwender:** `docs/schnellstart-anfaenger.md` wächst mit jedem Schritt mit (Wunsch von Lea). Jeder Schritt gilt erst als fertig, wenn der passende Teil der Anleitung steht. Lea testet jeden Teil selbst als erste Anwenderin. Stand 10.11.: Teile 1–4 (Begriffe, Konto, Git-Ordner, Einrichtung) geschrieben.

## Reihenfolge in der README

1. Datenbasis und Prüfregeln
2. Nachweis: Snowflake und Databricks liefern dieselben Zahlen
3. Agent als Probe aufs Exempel

## Repo-Hygiene

- `.gitignore` später um `.databricks/` und den Datenordner ergänzen
- Secret Scanning und Push Protection prüfen; Databricks-Token nie ins Repo
- Topics im About-Feld eintragen

## Vorteil gegenüber dem ersten Projekt

Der Generator braucht nur die Python-Standardbibliothek und läuft damit direkt in Databricks. Ziel: alles im Browser, ohne lokales Python, ohne `.env`, ohne Git Bash.

## Ergebnis der Workspace-Prüfung (10.11.2026)

- **Genie:** verfügbar, heißt im Menü jetzt „Genie Agents“ (unter SQL). Stufe 1 = Genie Agent „KI-Kosten fragen“.
- **Modelle:** liegen im Unity Gateway, nicht mehr unter Serving. Gewählt: GPT OSS 120B (`system.ai.gpt-oss-120b`, kann Werkzeuge nutzen); Ersatz: Llama 3.3 70B (`system.ai.meta-llama-3-3-70b-instruct`). Free Edition: Tageskontingent statt Abrechnung.
- **Agententypen:** Information Extraction, Document Parsing, Text Classification, Code your own agent, Genie Agent. Kein Supervisor ohne Code sichtbar → Stufe 2 über „Code your own agent“ (Agent Framework).
- **GitHub:** Git-Ordner `ki-nutzung-kosten-lakehouse` im Benutzerordner angelegt, Klonen klappt (ohne Sparse Checkout). Für Push später GitHub-Token unter Einstellungen → Linked accounts.

## Regeln wegen der Anmelde-Adresse

- Die Anmelde-Adresse erscheint im Benutzerordner und als „Owner“. Das bleibt in Databricks und geht nicht zu GitHub.
- Im Code keine festen Pfade wie `/Workspace/Users/...`; nur Katalog `ki_nutzung` und `/Volumes/ki_nutzung/bronze/rohdaten`.
- Commit-Identität: Bei den Git-Anmeldedaten unter Linked accounts Benutzername `lea-zimmer-data` und die GitHub-noreply-Adresse (GitHub → Settings → Emails) eintragen, damit keine Mail-Adresse öffentlich in den Commits steht.
- Screenshots für LinkedIn zuschneiden.
