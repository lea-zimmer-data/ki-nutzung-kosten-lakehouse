# Schnellstart für absolute Anfänger

Diese Anleitung ist für Menschen **ohne technische Vorkenntnisse**: Betriebswirtinnen, Controller, Assistenten der Geschäftsführung, Fachbereiche. Stell dir vor, dein Chef fragt: *„Was kostet uns eigentlich die KI, und können wir den Zahlen trauen?“* Mit dieser Anleitung baust du die Antwort selbst nach, Schritt für Schritt und komplett im Browser.

**Was du brauchst:** einen Browser und eine E-Mail-Adresse. Du installierst nichts auf deinem Rechner.
**Zeitbedarf bis zum Ende von Teil 4:** etwa 15 Minuten.

> **Wichtig:** Das Projekt arbeitet mit **erfundenen Beispieldaten**. Damit kannst du gefahrlos üben. Die Databricks Free Edition ist zum Lernen gedacht und darf nicht für kommerzielle Zwecke genutzt werden. Bevor du echte Unternehmensdaten verwendest, sprich mit deiner IT und dem Datenschutz.

> **Stand:** Das Projekt ist im Aufbau. Diese Anleitung wächst mit jedem Schritt. Weitere Teile folgen.

---

## Teil 1: Die wichtigsten Begriffe (3 Minuten)

| Begriff | Einfach erklärt |
|---|---|
| **Repository (Repo)** | Ein Projektordner im Internet, in dem alle Dateien und alle Änderungen gespeichert sind. |
| **GitHub** | Die Webseite, auf der dieses Repo liegt. |
| **Databricks** | Eine Datenplattform in der Cloud. Dort werden die Daten gespeichert, geprüft und ausgewertet, und dort läuft auch der KI-Agent. |
| **Free Edition** | Die kostenlose Lernversion von Databricks. Sie hat Grenzen bei der Rechenleistung, reicht für dieses Projekt aber aus. |
| **Workspace** | Deine persönliche Arbeitsumgebung in Databricks. |
| **Git-Ordner** | Eine Kopie dieses Repos in deinem Workspace. So hast du alle Dateien direkt in Databricks. |
| **Katalog, Schema, Tabelle** | Die Ordnung der Daten, wie Aktenschrank, Schublade und Akte. Der Katalog dieses Projekts heißt `ki_nutzung`. |
| **Volume (Ablage)** | Ein Ordner in Databricks für Dateien, hier für die CSV-Dateien mit den Beispieldaten. |
| **SQL** | Die Sprache, mit der man Datenbanken Fragen stellt. Du musst sie nicht lernen. Du führst die fertigen Dateien aus diesem Repo nur aus. |
| **Bronze, Silver, Gold** | Die drei Stufen, die die Daten durchlaufen: roh eingelesen (Bronze), geprüft und sauber (Silver), fertig ausgewertet (Gold). |
| **Prüfregel** | Eine Regel, die bei jedem Lauf kontrolliert, ob die Daten stimmen, zum Beispiel „Jede Ereignisnummer kommt nur einmal vor“. Verstöße werden gemeldet, nicht still repariert. |
| **KI-Agent** | Ein Programm, das Fragen in normaler Sprache versteht, sich die Antwort aus den Gold-Tabellen holt und dazusagt, wie verlässlich die Daten sind. |

---

## Teil 2: Databricks-Konto anlegen (ca. 5 Minuten)

1. Suche im Internet nach **„Databricks Free Edition“** und öffne die offizielle Seite auf `databricks.com`.
2. Melde dich mit deiner E-Mail-Adresse an und bestätige den Code, den du per E-Mail bekommst.
3. Nach der Anmeldung siehst du die Databricks-Oberfläche. Oben links steht „databricks Free Edition“.

> **Tipp:** Nimm eine E-Mail-Adresse, die du langfristig behältst. Dein Konto hängt an dieser Adresse.

**Das solltest du sehen:** Links ein Menü mit Einträgen wie **Workspace**, **Catalog**, **Jobs & Pipelines** und weiter unten **SQL Editor** und **Genie Agents**.

---

## Teil 3: Das Projekt in Databricks holen (ca. 3 Minuten)

1. Klicke links im Menü auf **Workspace** und dann auf **Home**.
2. Klicke oben rechts auf **Create** und wähle **Git folder**.
3. Trage bei **Git repository URL** ein:
   `https://github.com/lea-zimmer-data/ki-nutzung-kosten-lakehouse`
4. **Git provider** steht auf **GitHub**, der **Git folder name** wird automatisch ausgefüllt. Beides kannst du so lassen.
5. Lass das Häkchen bei **Sparse checkout mode** weg.
6. Klicke auf **Create Git folder**.

**Das solltest du sehen:** einen Ordner `ki-nutzung-kosten-lakehouse` mit den Unterordnern `docs` und `setup` sowie den Dateien `README.md` und `LICENSE`.

---

## Teil 4: Die Grundstruktur anlegen (ca. 5 Minuten)

In diesem Schritt legst du den Katalog `ki_nutzung`, die Schemas für die drei Stufen und die Ablage für die Beispieldaten an. Alles steckt in einer einzigen Datei.

1. Öffne im Git-Ordner den Unterordner **setup** und klicke auf die Datei **00_einrichtung.sql**.
2. Führe die Datei komplett aus:
   - Wenn sich die Datei im SQL-Editor öffnet, wähle oben die Rechenleistung (**Serverless Starter Warehouse** oder ähnlich) und klicke auf **Run all**.
   - Wenn du nur Text siehst, markiere alles (Strg + A), kopiere es (Strg + C), öffne links **SQL Editor**, füge den Text ein (Strg + V) und klicke auf **Run all**.
3. Warte, bis unten ein Ergebnis erscheint. Das kann beim ersten Mal eine Minute dauern, weil die Rechenleistung erst startet.

**Das solltest du sehen:** eine Liste mit den Schemas `agent`, `bronze`, `default`, `gold`, `information_schema` und `silver`. Wenn du links auf **Catalog** klickst, findest du den Katalog `ki_nutzung`. Unter `bronze` liegt die Ablage `rohdaten`.

### Falls etwas nicht klappt

| Meldung oder Problem | Lösung |
|---|---|
| Fehler bei `CREATE CATALOG`, zum Beispiel zu einem fehlenden Speicherort | Lege den Katalog über die Oberfläche an: links **Catalog**, dann das **Plus-Symbol** und **Create catalog**. Name `ki_nutzung`, Speicher auf **Default Storage** lassen, **Create**. Danach die Datei noch einmal komplett ausführen. |
| Der Katalog `ki_nutzung` erscheint links nicht | In der Catalog-Ansicht auf das Symbol zum **Aktualisieren** klicken. |
| Die Datei wurde aus Versehen doppelt ausgeführt | Kein Problem. Vorhandenes wird übersprungen. |

---

*Weitere Teile folgen: Beispieldaten erzeugen, Pipeline mit Prüfregeln, Abgleich mit dem Snowflake-Projekt, Genie Agent und KI-Agent.*
