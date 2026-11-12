# Datenkatalog: alle Tabellen erklärt

Dieses Dokument beschreibt jede Tabelle des Projekts: wofür sie da ist, was eine Zeile bedeutet, woher die Daten kommen und was jede Spalte enthält. Es richtet sich an alle, die mit den Daten arbeiten, auch ohne SQL-Kenntnisse.

> **Warum das wichtig ist:** Eine Zahl ist nur so verlässlich wie das Wissen darüber, wie sie entstanden ist. „Kosten“ kann vieles heißen: mit oder ohne fehlgeschlagene Anfragen, mit oder ohne Duplikate. Dieser Katalog legt das fest. In der Praxis fehlt so eine Dokumentation oft. Dann steckt das Wissen in einzelnen Köpfen, und wer neu dazukommt, muss raten.

**Regel für dieses Projekt:** Wer eine Tabelle in `pipeline/` ändert, passt im selben Commit diesen Katalog an.

Stand: 12.11.2026 · Zeilenzahlen beziehen sich auf die Beispieldaten mit dem Startwert 42.

---

## Überblick

Die Daten durchlaufen drei Stufen im Katalog `ki_nutzung`:

| Stufe | Schema | Zweck | Wer arbeitet damit? |
|---|---|---|---|
| Bronze | `ki_nutzung.bronze` | Rohdaten, genau wie geliefert. Alle Spalten sind Text. | niemand direkt, nur zum Nachsehen |
| Silver | `ki_nutzung.silver` | saubere Datentypen, Prüfregeln, Markierungen für Fehler | Datenteam |
| Gold | `ki_nutzung.gold` | fertige Auswertungen | Fachbereiche, Dashboard, Genie, KI-Agent, BI-Werkzeuge |

| Tabelle | Stufe | Eine Zeile ist … | Zeilen |
|---|---|---|---:|
| `fct_usage_events` | Gold | eine KI-Anfrage (ohne Duplikate) | 55.722 |
| `mart_kosten_je_abteilung_monat` | Gold | eine Abteilung in einem Monat | 108 |
| `mart_aktive_nutzer_monat` | Gold | eine Abteilung in einem Monat | 108 |
| `mart_anwendungsfaelle_konformitaet` | Gold | eine Risikoklasse | 3 |
| `mart_kosten_je_anwendungsfall` | Gold | ein Anwendungsfall | 15 |
| `mart_datenqualitaet` | Gold | eine Datenqualitätsprüfung | 4 |
| `mart_datenqualitaet_details` | Gold | ein betroffener Datensatz | 1.420 |
| `usage_events` | Silver | eine gelieferte KI-Anfrage (mit Duplikaten) | 55.861 |
| `users` | Silver | ein Nutzer | 220 |
| `use_cases` | Silver | ein KI-Anwendungsfall | 15 |
| `ai_models` | Silver | ein KI-Modell mit Preis | 3 |
| `departments` | Silver | eine Abteilung | 8 |
| `usage_events`, `users`, `use_cases`, `ai_models`, `departments` | Bronze | wie Silver, aber unverändert als Text | wie Silver |

---

## Gold: die Auswertungen

### `fct_usage_events`

Die Grundlage aller Auswertungen. Jede KI-Anfrage steht genau einmal darin, angereichert mit Abteilung, Kosten und Markierungen für Datenqualitätsprobleme.

- **Eine Zeile:** eine KI-Anfrage
- **Schlüssel:** `event_id`
- **Zeitraum:** 01.01.2025 bis 31.12.2025
- **Quelle:** `silver.usage_events`, verknüpft mit `users`, `departments` und `ai_models`
- **Wichtige Entscheidungen:**
  - Doppelt gelieferte Anfragen zählen nur einmal.
  - Fehlgeschlagene Anfragen kosten nichts.
  - Anfragen mit Datenproblemen bleiben drin und sind markiert. Sie werden nicht aussortiert.

| Spalte | Typ | Bedeutung |
|---|---|---|
| `event_id` | Text | eindeutige Nummer der Anfrage |
| `event_ts` | Zeitstempel | Zeitpunkt der Anfrage |
| `event_monat` | Datum | Monat der Anfrage, immer der 1. des Monats. Zum Gruppieren nach Monat. |
| `user_id` | Text | Nutzer, der die Anfrage gestellt hat |
| `department_name` | Text | Abteilung des Nutzers. „Unbekannt“, wenn die Abteilung in den Stammdaten fehlt. |
| `use_case_id` | Text | Anwendungsfall. Leer, wenn bei der Nutzung keiner angegeben wurde. |
| `model_id` | Text | verwendetes KI-Modell |
| `input_tokens` | Ganzzahl | Menge des gesendeten Texts in Token |
| `output_tokens` | Ganzzahl | Menge der Antwort in Token |
| `status` | Text | `erfolg` oder `fehler` |
| `ist_erfolg` | Ja/Nein | Ja, wenn `status` = `erfolg` |
| `kosten_eur` | Dezimalzahl | Kosten in Euro. Eingabe-Token × Eingabepreis / 1000 + Ausgabe-Token × Ausgabepreis / 1000. 0 bei fehlgeschlagenen Anfragen. Nicht gerundet. |
| `hat_anwendungsfall` | Ja/Nein | Nein, wenn kein Anwendungsfall angegeben ist (Datenproblem) |
| `ist_nach_austritt` | Ja/Nein | Ja, wenn die Anfrage nach dem Austrittsdatum des Nutzers liegt (Datenproblem) |
| `ist_bekannte_abteilung` | Ja/Nein | Nein, wenn die Abteilung des Nutzers unbekannt ist (Datenproblem) |

**Prüfregeln:** `anwendungsfall_zugeordnet` und `nutzung_vor_austritt` melden Verstöße. `kosten_berechnet` stoppt die Pipeline, wenn Kosten fehlen.

---

### `mart_kosten_je_abteilung_monat`

**Frage 1:** Was kostet KI pro Abteilung und Monat?

- **Eine Zeile:** eine Abteilung in einem Monat
- **Quelle:** `fct_usage_events`

| Spalte | Typ | Bedeutung |
|---|---|---|
| `event_monat` | Datum | Monat, immer der 1. des Monats |
| `department_name` | Text | Abteilung, einschließlich „Unbekannt“ |
| `erfolgreiche_anfragen` | Ganzzahl | Zahl der erfolgreichen Anfragen |
| `token_gesamt` | Ganzzahl | Eingabe- und Ausgabe-Token zusammen, auch von fehlgeschlagenen Anfragen |
| `kosten_eur` | Dezimalzahl | Kosten in Euro, auf 2 Stellen gerundet |

> **Achtung beim Summieren:** Weil jede Zeile einzeln gerundet ist, ergibt die Summe aller Zeilen 281,49 €. Die genauen Gesamtkosten sind 281,52 €. Für Gesamtsummen deshalb `fct_usage_events` verwenden.

---

### `mart_aktive_nutzer_monat`

**Frage 2:** Wie viele aktive Nutzer gibt es je Monat?

- **Eine Zeile:** eine Abteilung in einem Monat
- **Aktiv heißt:** mindestens eine erfolgreiche Anfrage im Monat. Anfragen nach dem Austritt zählen nicht.

| Spalte | Typ | Bedeutung |
|---|---|---|
| `event_monat` | Datum | Monat, immer der 1. des Monats |
| `department_name` | Text | Abteilung, einschließlich „Unbekannt“ |
| `aktive_nutzer` | Ganzzahl | Zahl der verschiedenen aktiven Nutzer |

> **Achtung beim Summieren:** Die Werte einzelner Monate dürfen nicht über das Jahr addiert werden. Wer im Januar und im Februar aktiv war, würde doppelt gezählt.

---

### `mart_anwendungsfaelle_konformitaet`

**Frage 3:** Welcher Anteil der Anwendungsfälle ist freigegeben und vollständig dokumentiert?

- **Eine Zeile:** eine Risikoklasse
- **Konform heißt:** Status `freigegeben` und Dokumentation vollständig
- **Nicht gezählt:** eingestellte Anwendungsfälle

| Spalte | Typ | Bedeutung |
|---|---|---|
| `risikoklasse` | Text | `minimal`, `begrenzt` oder `hoch` |
| `anzahl_anwendungsfaelle` | Ganzzahl | Anwendungsfälle dieser Risikoklasse, ohne eingestellte |
| `anzahl_konform` | Ganzzahl | davon konform |
| `konform_prozent` | Dezimalzahl | Anteil konform in Prozent, eine Nachkommastelle |

---

### `mart_kosten_je_anwendungsfall`

**Frage 4:** Welche Anwendungsfälle kosten je erfolgreicher Anfrage am meisten?

- **Eine Zeile:** ein Anwendungsfall
- **Nur:** Anwendungsfälle mit mindestens 100 Anfragen. Anfragen ohne Anwendungsfall fehlen hier.

| Spalte | Typ | Bedeutung |
|---|---|---|
| `use_case_name` | Text | Name des Anwendungsfalls |
| `risikoklasse` | Text | `minimal`, `begrenzt` oder `hoch` |
| `erfolgreiche_anfragen` | Ganzzahl | Zahl der erfolgreichen Anfragen |
| `kosten_eur` | Dezimalzahl | Kosten in Euro, auf 2 Stellen gerundet |
| `kosten_je_erfolgreicher_anfrage_eur` | Dezimalzahl | Kosten geteilt durch erfolgreiche Anfragen, 4 Nachkommastellen |

---

### `mart_datenqualitaet`

**Frage 5:** Wo liegen Datenqualitätsprobleme?

- **Eine Zeile:** eine Prüfung
- **Ampel:** grün = nichts gefunden, gelb = weniger als 1 % betroffen, rot = 1 % oder mehr

| Spalte | Typ | Bedeutung |
|---|---|---|
| `pruefung` | Text | Name der Prüfung |
| `betroffene_zeilen` | Ganzzahl | Zahl der betroffenen Datensätze |
| `geprueft` | Ganzzahl | Zahl der geprüften Datensätze |
| `anteil_prozent` | Dezimalzahl | betroffene in Prozent der geprüften, 2 Nachkommastellen |
| `ampel` | Text | `grün`, `gelb` oder `rot` |
| `erklaerung` | Text | was das Problem bedeutet, in Alltagssprache |
| `empfehlung` | Text | was man dagegen tun kann |
| `zustaendig` | Text | wer sich darum kümmern sollte |

| Prüfung | Geprüft wird in | Grundgesamtheit |
|---|---|---|
| Doppelte Ereignisse | `bronze.usage_events` | alle gelieferten Anfragen (55.861) |
| Ereignisse ohne Anwendungsfall | `gold.fct_usage_events` | Anfragen ohne Duplikate (55.722) |
| Nutzung nach dem Austritt | `gold.fct_usage_events` | Anfragen ohne Duplikate (55.722) |
| Nutzer mit unbekannter Abteilung | `silver.users` | alle Nutzer (220) |

---

### `mart_datenqualitaet_details`

Die einzelnen Datensätze hinter jeder Prüfung, damit Fachbereich und IT gezielt nachsehen können.

- **Eine Zeile:** ein betroffener Datensatz
- **Zeilen:** 139 + 1.102 + 174 + 5 = 1.420

| Spalte | Typ | Bedeutung |
|---|---|---|
| `pruefung` | Text | Name der Prüfung, wie in `mart_datenqualitaet` |
| `objekt_typ` | Text | `Ereignis` oder `Nutzer` |
| `objekt_id` | Text | `event_id` oder `user_id` des betroffenen Datensatzes |
| `detail` | Text | Hinweis zum Nachsehen, zum Beispiel wie oft ein Ereignis geliefert wurde |

---

## Silver: geprüfte Daten

In Silver bekommen die Rohdaten die richtigen Datentypen. Fehlerhafte Zeilen bleiben erhalten und sind markiert.

### `usage_events`

Alle gelieferten KI-Anfragen, **einschließlich der Duplikate**.

| Spalte | Typ | Bedeutung |
|---|---|---|
| `event_id` | Text | Nummer der Anfrage. Kann mehrfach vorkommen. |
| `event_ts` | Zeitstempel | Zeitpunkt |
| `user_id` | Text | Nutzer |
| `use_case_id` | Text | Anwendungsfall, leer wenn nicht angegeben |
| `model_id` | Text | KI-Modell |
| `input_tokens`, `output_tokens` | Ganzzahl | Token der Eingabe und der Antwort |
| `latency_ms` | Ganzzahl | Antwortzeit in Millisekunden |
| `status` | Text | `erfolg` oder `fehler` |
| `zeilen_nr` | Ganzzahl | 1 = erste Lieferung dieser `event_id`, ab 2 = Duplikat |

**Prüfregeln:** `event_id_eindeutig` meldet Duplikate. `event_id_vorhanden` und `status_gueltig` stoppen die Pipeline.

### `users`

| Spalte | Typ | Bedeutung |
|---|---|---|
| `user_id` | Text | Nummer des Nutzers |
| `department_id` | Text | Abteilung laut Stammdaten |
| `hired_date` | Datum | Eintrittsdatum |
| `left_date` | Datum | Austrittsdatum, leer wenn noch im Unternehmen (18 Nutzer sind ausgetreten) |
| `ist_bekannte_abteilung` | Ja/Nein | Nein, wenn `department_id` nicht in `departments` steht |

**Prüfregeln:** `abteilung_bekannt` meldet Verstöße. `nutzer_id_vorhanden` stoppt die Pipeline.

### `use_cases`

| Spalte | Typ | Bedeutung |
|---|---|---|
| `use_case_id` | Text | Nummer des Anwendungsfalls |
| `use_case_name` | Text | Name, zum Beispiel „Vertragsprüfung“ |
| `department_id` | Text | verantwortliche Abteilung |
| `risk_class` | Text | `minimal`, `begrenzt` oder `hoch` |
| `status` | Text | `pilot`, `freigegeben` oder `eingestellt` |
| `approved_date` | Datum | Freigabedatum, leer bei Piloten |
| `documentation_complete` | Ja/Nein | Dokumentation vollständig |

**Prüfregeln:** `anwendungsfall_id_vorhanden` und `risikoklasse_gueltig` stoppen die Pipeline.

### `ai_models`

| Spalte | Typ | Bedeutung |
|---|---|---|
| `model_id` | Text | `M1`, `M2` oder `M3` |
| `model_name` | Text | `modell-klein`, `modell-mittel`, `modell-gross` |
| `price_per_1k_input_eur` | Dezimalzahl | Preis je 1.000 Eingabe-Token in Euro |
| `price_per_1k_output_eur` | Dezimalzahl | Preis je 1.000 Ausgabe-Token in Euro |

**Prüfregeln:** `modell_id_vorhanden` und `preise_vorhanden` stoppen die Pipeline.

### `departments`

| Spalte | Typ | Bedeutung |
|---|---|---|
| `department_id` | Text | `D01` bis `D08` |
| `department_name` | Text | zum Beispiel „Vertrieb“, „Kundenservice“ |
| `cost_center` | Text | Kostenstelle, zum Beispiel `KST-1100` |

**Prüfregeln:** `abteilungs_id_vorhanden` stoppt die Pipeline.

---

## Bronze: Rohdaten

Die fünf Tabellen in Bronze enthalten die CSV-Dateien aus `/Volumes/ki_nutzung/bronze/rohdaten` unverändert. Alle Spalten sind Text, es gibt keine Prüfregeln. Spaltennamen wie in Silver, ohne die zusätzlichen Spalten `zeilen_nr` und `ist_bekannte_abteilung`.

Bronze ist dafür da, jederzeit nachsehen zu können, was die Quelle tatsächlich geliefert hat.

---

## Begriffe

| Begriff | Bedeutung |
|---|---|
| Token | Maßeinheit für Textmenge bei KI-Modellen, grob ein Wortteil. Danach wird abgerechnet. |
| Anwendungsfall | ein festgelegter Zweck, für den KI genutzt werden darf, zum Beispiel „Vertragsprüfung“ |
| Risikoklasse | Einstufung eines Anwendungsfalls nach Risiko: `minimal`, `begrenzt`, `hoch`. Angelehnt an die Stufen des EU AI Act, in den Beispieldaten aber zufällig vergeben. |
| Konform | freigegeben und vollständig dokumentiert |
| Duplikat | dieselbe Anfrage, mehrfach geliefert |
