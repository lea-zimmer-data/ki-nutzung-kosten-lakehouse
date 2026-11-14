# Schnellstart für absolute Anfänger

Diese Anleitung ist für Menschen **ohne technische Vorkenntnisse**: Betriebswirtinnen, Controller, Assistenten der Geschäftsführung, Fachbereiche. Stell dir vor, dein Chef fragt: *„Was kostet uns eigentlich die KI, und können wir den Zahlen trauen?“* Mit dieser Anleitung baust du die Antwort selbst nach, Schritt für Schritt und komplett im Browser.

**Was du brauchst:** einen Browser und eine E-Mail-Adresse. Du installierst nichts auf deinem Rechner, und es kostet nichts.
**Zeitbedarf:** beim ersten Mal etwa 90 Minuten. Du kannst nach jedem Teil aufhören und später weitermachen.

> **Wichtig:** Das Projekt arbeitet mit **erfundenen Beispieldaten**. Damit kannst du gefahrlos üben. Die Databricks Free Edition ist zum Lernen gedacht und darf nicht für kommerzielle Zwecke genutzt werden. Bevor du echte Unternehmensdaten verwendest, sprich mit deiner IT und dem Datenschutz.

---

## Teil 1: Was du am Ende hast (2 Minuten)

Nach dieser Anleitung läuft in deinem eigenen Databricks-Konto eine vollständige Datenstrecke:

- **Rund 56.000 KI-Anfragen** eines erfundenen Unternehmens aus einem Jahr, mit Abteilungen, Nutzern, Anwendungsfällen und Preisen.
- **Eine Pipeline**, die diese Daten mit einem Klick einliest, prüft und auswertet.
- **Eine Antwort auf die Frage deines Chefs:** eine Tabelle mit den KI-Kosten je Abteilung.
- **Ein Dashboard mit zwei Seiten**, das ein KI-Assistent aus zwei kurzen Anweisungen baut: eine Seite zu Kosten und Freigaben, eine zur Datenqualität.
- **Einen Genie Agent**, dem du Fragen in normaler Sprache stellst, zum Beispiel „Was hat der Vertrieb im Oktober für KI ausgegeben?“.
- **Eine ehrliche Qualitätsübersicht:** In den Daten stecken vier absichtlich eingebaute Fehler. Die Pipeline findet alle vier und zeigt mit einer Ampel, wie schwer sie wiegen und wer sich darum kümmern sollte.

Du schreibst dabei keine einzige Zeile Code. Du klickst, führst fertige Dateien aus und vergleichst das Ergebnis mit dem, was hier unter **„Das solltest du sehen“** steht.

Unbekannte Wörter wie *Katalog*, *Pipeline* oder *Prüfregel* sind am Ende unter [Begriffe zum Nachschlagen](#begriffe-zum-nachschlagen) erklärt.

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

**Das solltest du sehen:** einen Ordner `ki-nutzung-kosten-lakehouse` mit den Unterordnern `auswertungen`, `docs`, `pipeline`, `scripts` und `setup` sowie den Dateien `README.md` und `LICENSE`.

---

## Teil 4: Die Grundstruktur anlegen (ca. 5 Minuten)

In diesem Schritt legst du den Katalog `ki_nutzung`, die Schemas für die drei Stufen und die Ablage für die Beispieldaten an. Alles steckt in einer einzigen Datei.

1. Öffne im Git-Ordner den Unterordner **setup** und klicke auf die Datei **00_einrichtung.sql**. Sie öffnet sich in einem Editor.
2. Oben rechts steht bei der Rechenleistung **Serverless**. Das passt, du musst nichts ändern.
3. Klicke ganz oben links auf den kleinen **Pfeil neben ▶** und wähle **Run all**. Gibt es den Eintrag nicht, klicke direkt auf **▶**.
4. Warte, bis unten ein Ergebnis erscheint. Das kann beim ersten Mal eine Minute dauern, weil die Rechenleistung erst startet.

**Das solltest du sehen:** eine Tabelle mit sechs Schemas: `agent`, `bronze`, `default`, `gold`, `information_schema` und `silver`. Wenn du links auf **Catalog** klickst, findest du den Katalog `ki_nutzung`. Unter `bronze` liegt die Ablage `rohdaten`.

> **Was sind `default` und `information_schema`?** Beide legt Databricks in jedem neuen Katalog automatisch an. `default` ist ein leeres Ersatzfach, falls jemand beim Anlegen einer Tabelle kein Schema angibt. `information_schema` enthält nur Beschreibungen, zum Beispiel welche Tabellen es gibt. Dieses Projekt nutzt keins von beiden, du kannst sie ignorieren.

### Falls etwas nicht klappt

| Meldung oder Problem | Lösung |
|---|---|
| Fehler bei `CREATE CATALOG`, zum Beispiel zu einem fehlenden Speicherort | Lege den Katalog über die Oberfläche an: links **Catalog**, dann das **Plus-Symbol** und **Create catalog**. Name `ki_nutzung`, Speicher auf **Default Storage** lassen, **Create**. Danach die Datei noch einmal komplett ausführen. |
| Der Katalog `ki_nutzung` erscheint links nicht | In der Catalog-Ansicht auf das Symbol zum **Aktualisieren** klicken. |
| Die Datei wurde aus Versehen doppelt ausgeführt | Kein Problem. Vorhandenes wird übersprungen. |

---

## Teil 5: Die Beispieldaten erzeugen (ca. 5 Minuten)

Jetzt entstehen die erfundenen Daten: Abteilungen, KI-Modelle, Mitarbeitende, KI-Anwendungsfälle und rund 56.000 KI-Anfragen aus einem Jahr. Darin sind vier Datenfehler bewusst eingebaut, damit du später siehst, wie die Prüfregeln sie finden.

1. Öffne im Git-Ordner den Unterordner **setup** und klicke auf **01_daten_erzeugen**. Das ist ein *Notebook*: eine Datei, in der sich Erklärungen und ausführbare Abschnitte abwechseln.
2. Prüfe oben rechts, ob bei der Rechenleistung **Serverless** steht.
3. Klicke oben auf **Run all**.
4. Warte, bis alle Abschnitte durchgelaufen sind. Unter jedem Abschnitt erscheint dann sein Ergebnis.

**Das solltest du sehen:**

- Unter Schritt 1 die Zeile `users=220 use_cases=15 events=55861 -> /Volumes/ki_nutzung/bronze/rohdaten`.
- Unter Schritt 2 fünf Zeilen mit einem Häkchen ✓ und darunter: *Alles in Ordnung: gleiche Zeilenzahlen wie im Snowflake-Projekt.*
- Unter Schritt 3 eine Tabelle mit den ersten zehn KI-Anfragen.

Die Dateien selbst findest du links unter **Catalog → ki_nutzung → bronze → Volumes → rohdaten**.

> **Gut zu wissen:** Der Generator `scripts/generate_data.py` ist unverändert aus dem Snowflake-Projekt [ki-nutzung-kosten-analytics](https://github.com/lea-zimmer-data/ki-nutzung-kosten-analytics) übernommen. Mit dem Startwert 42 entstehen bei jedem Lauf genau dieselben Daten. Deshalb kann man die Ergebnisse beider Projekte später direkt vergleichen.

### Falls etwas nicht klappt

| Meldung oder Problem | Lösung |
|---|---|
| Fehler, dass `/Volumes/ki_nutzung/bronze/rohdaten` nicht existiert | Teil 4 wurde noch nicht ausgeführt. Hole das nach und starte das Notebook dann noch einmal. |
| `No module named 'generate_data'` | Im Git-Ordner fehlt der Ordner `scripts`. Klicke oben auf den Knopf **main** und dann auf **Pull**, um den aktuellen Stand zu holen. |
| `unrecognized arguments: -f …` und `SystemExit: 2` | Du hast `scripts/generate_data.py` direkt gestartet. Das ist ein Hilfsprogramm, das nur über das Notebook läuft. Starte stattdessen `setup/01_daten_erzeugen`. |
| Ein Kreuz ✗ statt Häkchen bei Schritt 2 | Notebook noch einmal komplett ausführen. Bleibt das Kreuz, ein Issue im Repo anlegen. |

---

## Teil 6: Die Pipeline anlegen und starten (ca. 20 Minuten)

Jetzt kommt das Herzstück. Die Pipeline liest die Rohdaten ein (Bronze), macht daraus saubere Daten mit Prüfregeln (Silver) und baut die fertigen Auswertungen (Gold). Der Code dafür liegt schon im Ordner `pipeline`. Du musst Databricks nur sagen, wo er liegt.

### Schritt 1: Pipeline anlegen

1. Klicke links im Menü auf **Jobs & Pipelines**.
2. Klicke oben rechts auf **Create** und wähle **ETL pipeline**.

Databricks legt sofort eine neue Pipeline an. Sie heißt „New Pipeline“ mit Datum und Uhrzeit und enthält nur eine leere Beispieldatei. **Klicke noch nicht auf „Run pipeline“.**

> **Wichtig:** Klicke nur einmal auf **ETL pipeline**. Jeder Klick legt eine weitere Pipeline an.

### Schritt 2: Pipeline einstellen

Klicke oben in der Leiste auf das **Zahnrad**. Es öffnen sich die **Pipeline settings**. Ändere dort drei Dinge:

**Name**
Klicke auf den Stift neben **Pipeline name** und trage `ki_nutzung_pipeline` ein.

**Katalog und Schema**
Klicke auf **Edit catalog and schema**. Wähle als Katalog `ki_nutzung` und als Schema `gold`. Speichern.

**Quellcode**
Klicke auf **Configure paths**. Du siehst zwei Felder. Klicke jeweils auf das **Ordner-Symbol** rechts daneben und wähle den Ordner aus:

| Feld | Diesen Ordner wählen |
|---|---|
| **Pipeline root folder** | `ki-nutzung-kosten-lakehouse` |
| **Source code paths** | `ki-nutzung-kosten-lakehouse` → `pipeline` |

So findest du die Ordner im Auswahlfenster: Klicke oben in der Pfadzeile auf deinen **Benutzerordner** (der Eintrag mit deiner E-Mail-Adresse). Dort liegt `ki-nutzung-kosten-lakehouse`, erkennbar am Git-Symbol und an den **Bindestrichen** im Namen.

> **Achtung, Verwechslungsgefahr:** Im selben Benutzerordner liegt auch ein Ordner `ki_nutzung_pipeline` mit **Unterstrichen**. Den hat Databricks automatisch angelegt, er enthält nur die leere Beispieldatei. Wähle ihn nicht aus. Ausgewählt wird immer der Ordner, der in der Pfadzeile ganz rechts steht. Prüfe das, bevor du auf **Select** klickst.

**Das solltest du sehen:** In den Pipeline settings steht unter **Code assets** bei **Root folder** ein Pfad, der auf `ki-nutzung-kosten-lakehouse` endet, und bei **Source code** steht `pipeline/`. Unter **Default location for data assets** stehen `ki_nutzung` und `gold`. Bei **Compute** steht **Serverless**.

### Schritt 3: Pipeline starten

1. Schließe die Einstellungen mit dem **X**.
2. Schließe den Tab mit der leeren Beispieldatei (Endung `.py`) über das **X** neben dem Dateinamen.
3. Klicke ganz links oben auf das **Ordner-Symbol** und dann im Dateibaum auf **01_bronze.sql**.
4. Klicke oben rechts auf den blauen Knopf **Run pipeline**.

Der erste Lauf dauert ein paar Minuten. Unten erscheinen die Reiter **Tables**, **Performance** und **Pipeline graph**.

**Das solltest du sehen:**

- Unter **Tables** eine Liste mit 17 Tabellen, jede mit einem grünen Häkchen. Oben rechts in diesem Bereich stehen 0 Fehler und 0 Warnungen.
- Unter **Pipeline graph** eine Grafik, die zeigt, wie die Daten von den Rohdaten bis zu den Auswertungen fließen.
- Links unter **Catalog → ki_nutzung** sind die Schemas `bronze`, `silver` und `gold` jetzt mit Tabellen gefüllt.

### Schritt 4: Ergebnis prüfen

Die Pipeline hat vier Datenfehler gefunden und gemeldet, ohne sie still zu reparieren. So siehst du sie:

1. Öffne im Git-Ordner den Unterordner **auswertungen** und klicke auf **datenqualitaet.sql**.
2. Klicke auf **Run all** (über den kleinen Pfeil neben ▶).

**Das solltest du sehen:**

| pruefung | betroffene_zeilen | geprueft | anteil_prozent | ampel |
|---|---|---|---|---|
| Doppelte Ereignisse | 139 | 55861 | 0.25 | gelb |
| Ereignisse ohne Anwendungsfall | 1102 | 55722 | 1.98 | rot |
| Nutzer mit unbekannter Abteilung | 5 | 220 | 2.27 | rot |
| Nutzung nach dem Austritt | 174 | 55722 | 0.31 | gelb |

Zu jeder Zeile stehen rechts daneben eine Erklärung, eine Empfehlung und wer zuständig ist.

**Gegenprobe:** Führe genauso **pruefregeln_der_pipeline.sql** aus. Diese Abfrage liest das Protokoll der Pipeline. Bei den vier Prüfregeln `event_id_eindeutig`, `anwendungsfall_zugeordnet`, `nutzung_vor_austritt` und `abteilung_bekannt` müssen dieselben vier Zahlen stehen: 139, 1102, 174 und 5. Alle anderen Regeln zeigen 0 Verstöße.

> **Warum zwei Wege?** Die erste Abfrage rechnet aus den Tabellen, die zweite liest, was die Pipeline beim Lauf mitgezählt hat. Stimmen beide überein, kannst du den Zahlen trauen.

### Falls etwas nicht klappt

| Meldung oder Problem | Lösung |
|---|---|
| Unten steht nur **Output / Terminal / Debugger** statt **Tables / Pipeline graph** | Du hast noch die leere Beispieldatei geöffnet. Schließe ihren Tab und öffne `01_bronze.sql` aus dem Dateibaum. |
| Die Pipeline läuft durch, aber es entstehen keine Tabellen | Bei **Source code** ist der falsche Ordner eingetragen. Öffne das Zahnrad, klicke auf **Configure paths** und wähle `ki-nutzung-kosten-lakehouse` → `pipeline`. |
| Fehler in `00_einrichtung.sql` oder `01_daten_erzeugen` während des Laufs | Bei **Source code** ist der ganze Git-Ordner eingetragen statt nur `pipeline`. Korrigiere das wie in der Zeile darüber. |
| Fehler, dass eine Datei unter `/Volumes/ki_nutzung/bronze/rohdaten` fehlt | Teil 5 wurde noch nicht ausgeführt. |
| Es gibt mehrere Pipelines in der Liste | Lösche die überzähligen: **Jobs & Pipelines**, bei der Pipeline mit dem Namen „New Pipeline …“ auf die **drei Punkte** klicken und **Delete** wählen. Die Free Edition erlaubt nur eine aktive Pipeline dieser Art. |
| Fehler wegen eines Tageslimits | Die Free Edition hat ein Tageskontingent. Versuche es am nächsten Tag noch einmal. Deine Daten bleiben erhalten. |

---

## Teil 7: Die erste Antwort (ca. 3 Minuten)

Jetzt beantwortest du die Frage vom Anfang: Was kostet uns die KI?

1. Öffne im Git-Ordner den Unterordner **auswertungen** und klicke auf **kosten_je_abteilung.sql**.
2. Klicke auf **Run all**.

**Das solltest du sehen:** die KI-Kosten je Abteilung im Dezember 2025, die teuerste Abteilung zuerst.

| event_monat | abteilung | erfolgreiche_anfragen | kosten_eur |
|---|---|---|---|
| 2025-12-01 | Kundenservice | 1945 | 9.65 |
| 2025-12-01 | Produktentwicklung | 1215 | 6.41 |
| 2025-12-01 | Vertrieb | 1133 | 5.58 |
| 2025-12-01 | IT | 981 | 5.32 |
| 2025-12-01 | Marketing | 812 | 4.49 |
| 2025-12-01 | Personal | 509 | 2.34 |
| 2025-12-01 | Finanzen | 372 | 2.17 |
| 2025-12-01 | Recht und Compliance | 328 | 1.74 |
| 2025-12-01 | Unbekannt | 213 | 1.12 |

Die Beträge sind klein, weil Preise und Mengen erfunden sind. Es geht um den Weg zur Zahl, nicht um die Zahl selbst.

**Und kannst du den Zahlen trauen?** Schau auf die letzte Zeile: 213 Anfragen laufen unter „Unbekannt“. Das sind die Nutzer mit unbekannter Abteilung aus der Qualitätsübersicht in Teil 6. Die Kosten fehlen also nicht, sie sind nur keiner Abteilung zugeordnet. Genau dafür ist die Qualitätsübersicht da: Sie sagt dir, wo eine Zahl mit Vorsicht zu lesen ist und wer das Problem beheben kann.

---

## Teil 8: Ein Dashboard per Anweisung (ca. 15 Minuten)

Jetzt lässt du einen KI-Assistenten ein Dashboard bauen. Du beschreibst in normaler Sprache, was du sehen willst, und der Assistent erstellt Kennzahlen, Diagramme und Tabellen. Programmieren musst du dafür nicht, und auch kein Diagramm von Hand anlegen.

Die beiden Anweisungen stehen fertig in [docs/prompts.md](prompts.md). Du kopierst sie nur.

### Schritt 1: Leeres Dashboard anlegen

1. Klicke links im Menü unter **SQL** auf **Dashboards**.
2. Klicke oben rechts auf **Create dashboard**.

**Das solltest du sehen:** eine leere Seite mit der Überschrift **„Create a dashboard with Genie“** und darunter ein Eingabefeld. Das ist der KI-Assistent.

### Schritt 2: Seite 1 „KI-Kosten und Freigaben“

1. Öffne im Git-Ordner die Datei **docs/prompts.md** und kopiere den Text unter **Anweisung 1**.
2. Füge ihn in das Eingabefeld ein und klicke auf den **Pfeil** rechts.
3. Warte, bis der Assistent fertig ist. Das kann ein bis zwei Minuten dauern.

**Das solltest du sehen:**

- Oben drei Kennzahlen: **281,52 €** KI-Kosten gesamt, **54.098** erfolgreiche Anfragen und **1 von 4** Hochrisiko-Anwendungsfällen konform.
- Darunter drei Diagramme: Die Kosten je Monat steigen von rund 12 € im Januar auf knapp 39 € im Dezember. Bei den Kosten je Abteilung liegt Kundenservice vorn, „Unbekannt“ ist grau. Bei der Konformität stehen minimal 100 %, begrenzt 40 % und hoch 25 %.
- Ganz unten eine Fußnote zum Datenstand.

### Schritt 3: Seite 2 „Datenqualität“

1. Klicke oben neben dem Seitennamen **KI-Kosten und Freigaben** auf das **+**. Eine neue, leere Seite mit dem Assistenten erscheint.
2. Kopiere aus **docs/prompts.md** den Text unter **Anweisung 2**, füge ihn ein und klicke auf den **Pfeil**.

**Das solltest du sehen:** oben eine Tabelle mit vier Prüfungen und farbiger Ampel, darunter alle 1.420 betroffenen Datensätze mit einem Filter nach Prüfung.

| Prüfung | Betroffen | Anteil | Ampel |
|---|---|---|---|
| Nutzer mit unbekannter Abteilung | 5 | 2,27 % | rot |
| Ereignisse ohne Anwendungsfall | 1.102 | 1,98 % | rot |
| Nutzung nach dem Austritt | 174 | 0,31 % | gelb |
| Doppelte Ereignisse | 139 | 0,25 % | gelb |

### Schritt 4: Fertigstellen

1. Klicke oben auf den Namen des Dashboards. Databricks hängt dort Datum und Uhrzeit an. Ändere ihn in **KI-Nutzung und -Kosten**.
2. Klicke oben rechts auf **Publish**. Damit wird aus dem Entwurf eine feste Fassung.

> **Warum zwei Seiten?** Wer Kosten steuert, braucht andere Informationen als jemand, der Stammdaten pflegt. Seite 1 ist für Geschäftsführung und Controlling, Seite 2 für die Verantwortlichen der Daten. Die Fußnote auf Seite 1 verbindet beide: Sie erklärt „Unbekannt“ und verweist auf die Details.

> **Gut zu wissen:** Ein KI-Assistent liefert bei derselben Anweisung nicht jedes Mal genau dasselbe Aussehen. Farben, Anordnung oder Beschriftungen können abweichen. Die Zahlen müssen aber stimmen, denn sie kommen immer aus denselben geprüften Gold-Tabellen. Vergleiche sie mit den Werten oben.

### Falls etwas nicht klappt

| Meldung oder Problem | Lösung |
|---|---|
| Eine Zahl weicht von den Werten oben ab | Klicke im Dashboard auf das betroffene Element und öffne seine Abfrage. Vergleiche sie mit der Rechenregel im [Datenkatalog](datenkatalog.md). Oder schreibe dem Assistenten, was falsch ist, zum Beispiel: „Die Kosten gesamt sollen aus fct_usage_events kommen, nicht aus mart_kosten_je_abteilung_monat.“ |
| Der Assistent fragt nach, welche Tabelle gemeint ist | Antworte mit dem vollen Namen, zum Beispiel `ki_nutzung.gold.fct_usage_events`. |
| Etwas sieht anders aus als gewünscht, etwa eine Farbe oder eine Überschrift | Schreibe dem Assistenten die Änderung in einem Satz, zum Beispiel: „Färbe den Balken Unbekannt grau.“ |
| Die Tabellen in `ki_nutzung.gold` fehlen | Die Pipeline aus Teil 6 ist noch nicht gelaufen. |

---

## Teil 9: Fragen in normaler Sprache mit Genie (ca. 20 Minuten)

Jetzt richtest du einen Genie Agent ein. Er beantwortet Fragen in normaler Sprache, etwa „Wie viele aktive Nutzer gab es im Dezember?“, und zeigt die Abfrage, mit der er gerechnet hat. Alles, was du dafür einträgst, steht fertig in [agent/genie_anweisungen.md](../agent/genie_anweisungen.md).

### Schritt 1: Agent per Beschreibung anlegen

1. Klicke links im Menü unter **SQL** auf **Genie Agents** und oben rechts auf **New**.
2. Es erscheint die Frage **„What should your Genie agent do?“** mit einem Eingabefeld.
3. Kopiere die Beschreibung aus Abschnitt 1 der Datei `agent/genie_anweisungen.md`, füge sie ein und klicke auf den **Pfeil**.

**Das solltest du sehen:** Genie legt den Agenten an. Unter **Configure → About** stehen eine Beschreibung und Beispielfragen („Common questions“), die Genie selbst formuliert hat.

### Schritt 2: Tabellen prüfen

Klicke auf **Configure** und dann auf den Reiter **Sources**.

**Das solltest du sehen:** genau sieben Tabellen, alle aus `ki_nutzung.gold`, von `fct_usage_events` bis `mart_datenqualitaet_details`.

### Schritt 3: Anweisungen ersetzen

1. Klicke auf den Reiter **Instructions**. Dort steht ein Entwurf, den Genie selbst geschrieben hat.
2. Lösche ihn und füge stattdessen den Text aus Abschnitt 3 der Datei `agent/genie_anweisungen.md` ein. Speichern.

> **Warum ersetzen?** Genies Entwurf ist gut, enthält aber zwei Fehler. Er würde zum Beispiel gerundete Monatswerte addieren und käme dann auf 281,49 € statt 281,52 € Gesamtkosten. In der Datei steht genau, was geändert wurde und warum. Das ist der wichtigste Schritt dieses Teils: Die KI schreibt schnell einen Entwurf, die fachliche Prüfung macht ihn verlässlich.

### Schritt 4: Testen

Klicke oben auf **Chat** und stelle die elf Testfragen aus Abschnitt 5 der Datei, eine nach der anderen. Vergleiche jede Antwort mit der richtigen Antwort in der Tabelle.

**Das solltest du sehen**, zum Beispiel:

| Frage | Richtige Antwort |
|---|---|
| Was hat KI 2025 insgesamt gekostet? | 281,52 € |
| Wie viele aktive Nutzer gab es im ganzen Jahr 2025? | 220, nicht 2.542 |
| Welcher Anwendungsfall kostet je erfolgreicher Anfrage am meisten? | Textzusammenfassung, 0,0083 €, mit Hinweis auf Anfragen ohne Anwendungsfall |
| Wie hoch ist die Zufriedenheit der Nutzer mit den KI-Anwendungen? | Genie sagt, dass es dazu keine Daten gibt |

Zwei der Fragen sind absichtlich Fallen. Bei den aktiven Nutzern im ganzen Jahr darf Genie die Monate nicht addieren. Bei der Zufriedenheit darf Genie nicht raten.

> **Gut zu wissen:** Genie formuliert die Antworten jedes Mal etwas anders. Entscheidend ist die Zahl. Unter jeder Antwort kannst du die Abfrage aufklappen, mit der Genie gerechnet hat.

### Falls etwas nicht klappt

| Problem | Lösung |
|---|---|
| Unter **Sources** fehlen Tabellen oder es sind andere dabei | Klicke auf **Sources** und füge die fehlenden Tabellen aus `ki_nutzung.gold` hinzu oder entferne die falschen. |
| Eine Antwort hat die falsche Zahl | Prüfe, ob die Anweisungen aus Abschnitt 3 gespeichert sind. Öffne unter der Antwort die Abfrage und vergleiche sie mit der Rechenregel im [Datenkatalog](datenkatalog.md). |
| Kosten je Anfrage erscheinen als „0,01 €“ | In den Anweisungen fehlt die Zeile zu vier Nachkommastellen. Ergänze sie aus Abschnitt 3. |
| Genie antwortet auf Englisch | Schreibe in die Frage „Antworte auf Deutsch“ oder prüfe, ob die Anweisungen gespeichert sind. |

---

## Begriffe zum Nachschlagen

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
| **Pipeline** | Eine Abfolge von Schritten, die Daten automatisch von den Rohdaten bis zur fertigen Auswertung bringt. Du startest sie mit einem Klick. |
| **Prüfregel** | Eine Regel, die bei jedem Lauf kontrolliert, ob die Daten stimmen, zum Beispiel „Jede Ereignisnummer kommt nur einmal vor“. Verstöße werden gemeldet, nicht still repariert. |
| **KI-Agent** | Ein Programm, das Fragen in normaler Sprache versteht, sich die Antwort aus den Gold-Tabellen holt und dazusagt, wie verlässlich die Daten sind. |
