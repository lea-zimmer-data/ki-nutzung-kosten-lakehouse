# Vergleich: Snowflake und Databricks

**Ergebnis:** Beide Plattformen liefern für alle 21 geprüften Kennzahlen exakt dieselben Werte.

Geprüft am 11.11.2026 mit den Beispieldaten aus `scripts/generate_data.py` (Startwert 42).

## Was verglichen wurde

Dieselben Daten und dieselben fünf Fachfragen gibt es in zwei Projekten:

| | Snowflake-Projekt | Dieses Projekt |
|---|---|---|
| Repo | [ki-nutzung-kosten-analytics](https://github.com/lea-zimmer-data/ki-nutzung-kosten-analytics) | ki-nutzung-kosten-lakehouse |
| Plattform | Snowflake | Databricks (Free Edition) |
| Aufbereitung | dbt-Modelle | Pipeline mit SQL-Dateien |
| Prüfung | dbt-Tests | Prüfregeln in der Pipeline |
| Ort der Auswertungen | `KI_NUTZUNG.MARTS` | `ki_nutzung.gold` |

Der Datengenerator ist in beiden Repos dieselbe Datei. Die sieben Auswertungstabellen heißen gleich und folgen denselben Rechenregeln.

## So wurde verglichen

Eine Abfrage berechnet 21 Kennzahlen über alle sieben Auswertungen: Zeilenzahlen, Summen und einzelne Werte. Die Abfrage ist für beide Plattformen Wort für Wort gleich, nur der Ort der Tabellen unterscheidet sich:

- [auswertungen/abgleich_snowflake.sql](../auswertungen/abgleich_snowflake.sql)
- [auswertungen/abgleich_databricks.sql](../auswertungen/abgleich_databricks.sql)

Beide Abfragen wurden auf der jeweiligen Plattform ausgeführt und die Ergebnisse nebeneinandergelegt.

## Die Ergebnisse

| Nr. | Kennzahl | Snowflake | Databricks | Gleich? |
|---|---|---|---|---|
| 01 | fct_usage_events: Zeilen | 55.722 | 55.722 | ✅ |
| 02 | fct_usage_events: erfolgreiche Anfragen | 54.098 | 54.098 | ✅ |
| 03 | fct_usage_events: Summe Kosten in Euro | 281,524039 | 281,524039 | ✅ |
| 04 | fct_usage_events: Summe Token | 61.860.978 | 61.860.978 | ✅ |
| 05 | Frage 1: Zeilen | 108 | 108 | ✅ |
| 06 | Frage 1: Summe der gerundeten Kosten in Euro | 281,49 | 281,49 | ✅ |
| 07 | Frage 1: Kosten Kundenservice im Dezember in Euro | 9,65 | 9,65 | ✅ |
| 08 | Frage 2: Zeilen | 108 | 108 | ✅ |
| 09 | Frage 2: Summe aktive Nutzer | 2.542 | 2.542 | ✅ |
| 10 | Frage 3: Zeilen | 3 | 3 | ✅ |
| 11 | Frage 3: Summe konforme Anwendungsfälle | 7 | 7 | ✅ |
| 12 | Frage 3: Summe Konform-Prozent | 165,0 | 165,0 | ✅ |
| 13 | Frage 4: Zeilen | 15 | 15 | ✅ |
| 14 | Frage 4: Summe Kosten in Euro | 275,91 | 275,91 | ✅ |
| 15 | Frage 4: Summe Kosten je Anfrage in Euro | 0,078 | 0,078 | ✅ |
| 16 | Frage 5: Doppelte Ereignisse | 139 | 139 | ✅ |
| 17 | Frage 5: Ereignisse ohne Anwendungsfall | 1.102 | 1.102 | ✅ |
| 18 | Frage 5: Nutzung nach dem Austritt | 174 | 174 | ✅ |
| 19 | Frage 5: Nutzer mit unbekannter Abteilung | 5 | 5 | ✅ |
| 20 | Frage 5: Summe Anteil-Prozent | 4,81 | 4,81 | ✅ |
| 21 | Frage 5 Details: Zeilen | 1.420 | 1.420 | ✅ |

## Was der Vergleich aussagt und was nicht

- Er zeigt, dass beide Plattformen bei gleichen Daten und gleichen Rechenregeln zu denselben Zahlen kommen, bis auf die sechste Nachkommastelle.
- Er vergleicht Kennzahlen, also Zeilenzahlen und Summen, und nicht jede einzelne Zeile. Ein Zeile-für-Zeile-Vergleich würde einen Export aus beiden Systemen erfordern.
- Er sagt nichts über Geschwindigkeit oder Kosten der Plattformen aus. Rund 56.000 Zeilen sind dafür zu wenig.

## Worauf bei der Übertragung zu achten war

Die Rechenregeln sind gleich, die SQL-Dialekte nicht. Drei Stellen brauchten Aufmerksamkeit:

| Thema | Snowflake | Databricks |
|---|---|---|
| Text in Zahl oder Datum umwandeln | `try_to_decimal`, `try_to_date`, `try_to_timestamp` | `try_cast(... AS ...)` |
| Geteilt-Rechnung mit ganzen Zahlen | ergibt eine exakte Dezimalzahl | ergibt eine Gleitkommazahl. Die Kosten werden deshalb erst mit dem Preis multipliziert und dann durch 1000 geteilt, damit das Ergebnis exakt bleibt. |
| Duplikate | werden beim Aufbereiten entfernt und gezählt | bleiben in Silver erhalten und sind markiert. Erst die Faktentabelle zählt jedes Ereignis einmal. |

Der zweite Punkt ist der wichtigste: Ohne diese Anpassung hätten sich Kostensummen in hinteren Nachkommastellen unterscheiden können. Solche Unterschiede fallen nur auf, wenn man die Ergebnisse tatsächlich nebeneinanderlegt.

## Selbst nachprüfen

1. Snowflake-Projekt nach dessen Anleitung einrichten und die Pipeline ausführen.
2. `abgleich_snowflake.sql` in Snowflake ausführen.
3. Dieses Projekt nach dem [Schnellstart](schnellstart-anfaenger.md) einrichten.
4. `abgleich_databricks.sql` in Databricks ausführen.
5. Beide Ergebnisse mit der Tabelle oben vergleichen.
