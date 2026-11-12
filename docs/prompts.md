# Anweisungen an die KI-Assistenten

Teile dieses Projekts sind nicht programmiert, sondern entstehen durch eine Anweisung in normaler Sprache an einen KI-Assistenten in Databricks. Damit jeder nachvollziehen und wiederholen kann, wie sie entstanden sind, stehen die Anweisungen hier im Wortlaut.

Ein KI-Assistent liefert bei derselben Anweisung nicht jedes Mal genau dasselbe Ergebnis. Die Zahlen kommen aber immer aus denselben geprüften Gold-Tabellen. Deshalb steht unter jeder Anweisung, welche Werte im Ergebnis stehen müssen.

---

## Dashboard: KI-Kosten, Freigaben und Datenqualität

Das Dashboard hat zwei Seiten für zwei Zielgruppen. Seite 1 ist für Geschäftsführung und Controlling, Seite 2 für die Verantwortlichen der Daten. Auf Seite 1 steht die Datenqualität nur als kurze Fußnote, damit niemand über „Unbekannt“ stolpert oder Summen nicht nachvollziehen kann.

**Wo:** Databricks → Dashboards → Create dashboard → KI-Assistent

**Anweisung:**

> Erstelle ein Dashboard mit dem Titel „KI-Nutzung und -Kosten 2025“ und zwei Seiten. Verwende nur Tabellen aus dem Schema ki_nutzung.gold.
>
> **Seite 1: „KI-Kosten und Freigaben“**
>
> Oben drei Kennzahlen:
> 1. KI-Kosten gesamt in Euro: Summe von kosten_eur aus fct_usage_events, zwei Nachkommastellen.
> 2. Erfolgreiche Anfragen: Anzahl der Zeilen in fct_usage_events mit ist_erfolg = true.
> 3. Hochrisiko-Anwendungsfälle konform: anzahl_konform und anzahl_anwendungsfaelle aus mart_anwendungsfaelle_konformitaet für risikoklasse = 'hoch', angezeigt als „1 von 4“.
>
> Darunter drei Diagramme:
> 1. Säulendiagramm: Kosten je Monat aus fct_usage_events, x-Achse event_monat, y-Achse Summe kosten_eur.
> 2. Balkendiagramm: Kosten je Abteilung aus fct_usage_events nach department_name, absteigend sortiert. Alle Balken in derselben Farbe, die Abteilung „Unbekannt“ in Grau.
> 3. Balkendiagramm: konform_prozent je risikoklasse aus mart_anwendungsfaelle_konformitaet, Reihenfolge minimal, begrenzt, hoch.
>
> Keine Ampelfarben auf dieser Seite. Unter den Titel klein: „Beispieldaten · Databricks Lakehouse“.
>
> Ganz unten eine Fußnote als Text: „Datenstand: 2 Prüfungen rot, 2 gelb. „Unbekannt“ = Nutzer ohne Abteilungszuordnung. Anfragen ohne Anwendungsfall sind in den Gesamtkosten enthalten. Details auf Seite 2.“
>
> **Seite 2: „Datenqualität“**
>
> Eine Tabelle aus mart_datenqualitaet mit den Spalten pruefung, betroffene_zeilen, geprueft, anteil_prozent, ampel, zustaendig und empfehlung, sortiert nach anteil_prozent absteigend. Die Spalte ampel farbig: rot, gelb, grün.
>
> Darunter eine Tabelle aus mart_datenqualitaet_details mit den Spalten pruefung, objekt_typ, objekt_id und detail, mit einem Filter nach pruefung.

**Diese Werte müssen im Ergebnis stehen:**

| Seite | Kennzahl | Wert |
|---|---|---|
| 1 | KI-Kosten gesamt | 281,52 € |
| 1 | Erfolgreiche Anfragen | 54.098 |
| 1 | Hochrisiko konform | 1 von 4 |
| 1 | Kosten Januar / Dezember 2025 | 11,90 € / 38,82 € |
| 1 | Konform je Risikoklasse | minimal 100 %, begrenzt 40 %, hoch 25 % |
| 2 | Prüfungen | 2 rot (Nutzer mit unbekannter Abteilung 2,27 %, Ereignisse ohne Anwendungsfall 1,98 %), 2 gelb (Nutzung nach dem Austritt 0,31 %, doppelte Ereignisse 0,25 %) |
| 2 | Detailzeilen | 1.420 |

Weicht ein Wert ab, hat der Assistent die Anweisung anders verstanden. Dann im Dashboard die Abfrage des betroffenen Elements öffnen und mit der Rechenregel im [Datenkatalog](datenkatalog.md) vergleichen.

> **Hinweis zur Fußnote:** Die Zahlen „2 rot, 2 gelb“ stehen fest im Text. Ändern sich die Daten, muss die Fußnote angepasst werden. Sie ist bewusst kurz gehalten, damit die Kostenseite ruhig bleibt.
