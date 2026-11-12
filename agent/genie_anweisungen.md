# Genie Agent „KI-Kosten fragen“

Mit dem Genie Agent stellen Fachbereiche ihre Fragen zu KI-Kosten und -Nutzung in normaler Sprache. Genie übersetzt die Frage in eine Abfrage auf die Gold-Tabellen und zeigt die Antwort samt der verwendeten Abfrage. Programmiert wird dafür nichts: Genie bekommt die Tabellen, eine Beschreibung der Rechenregeln und Beispielfragen.

Diese Datei enthält alles, was beim Einrichten eingetragen wird, und die Testfragen mit den richtigen Antworten.

---

## 1. Name und Beschreibung

| Feld | Inhalt |
|---|---|
| Name | KI-Kosten fragen |
| Beschreibung | Fragen zu KI-Kosten, KI-Nutzung, Freigaben und Datenqualität. Beispieldaten für 2025. |

## 2. Tabellen

Alle sieben Tabellen aus `ki_nutzung.gold`:

- `fct_usage_events`
- `mart_kosten_je_abteilung_monat`
- `mart_aktive_nutzer_monat`
- `mart_anwendungsfaelle_konformitaet`
- `mart_kosten_je_anwendungsfall`
- `mart_datenqualitaet`
- `mart_datenqualitaet_details`

## 3. Anweisungen

Dieser Text kommt in das Feld für allgemeine Anweisungen (Instructions):

```
Du beantwortest Fragen zur Nutzung und zu den Kosten von KI in einem Unternehmen. Alle Daten sind erfundene Beispieldaten für das Jahr 2025. Antworte auf Deutsch, kurz und mit der Zahl zuerst. Beträge in Euro mit zwei Nachkommastellen und Komma, zum Beispiel 281,52 €.

Rechenregeln:
- Kosten immer aus fct_usage_events als Summe von kosten_eur berechnen. Für Gesamtsummen nie die gerundeten Werte aus mart_kosten_je_abteilung_monat oder mart_kosten_je_anwendungsfall addieren, das ergibt Rundungsabweichungen.
- Fehlgeschlagene Anfragen kosten nichts. Doppelte Lieferungen sind in fct_usage_events bereits entfernt.
- Eine Anfrage ist erfolgreich, wenn ist_erfolg = true.
- Aktive Nutzer: verschiedene user_id mit mindestens einer erfolgreichen Anfrage, ohne Anfragen nach dem Austritt (ist_nach_austritt = false). Aktive Nutzer mehrerer Monate nie addieren, sondern über den ganzen Zeitraum neu zählen.
- Monate stehen in event_monat, immer als erster Tag des Monats.
- Konform heißt: Status freigegeben und Dokumentation vollständig. Dafür mart_anwendungsfaelle_konformitaet verwenden.
- Die Abteilung „Unbekannt“ steht für Nutzer ohne gültige Abteilungszuordnung. Erwähne das, wenn „Unbekannt“ in einer Antwort vorkommt.
- Anfragen ohne Anwendungsfall (hat_anwendungsfall = false) sind in den Gesamtkosten enthalten, fehlen aber bei Auswertungen je Anwendungsfall. Weise darauf hin, wenn nach Kosten je Anwendungsfall gefragt wird.

Datenqualität:
- Bei Fragen zur Datenqualität mart_datenqualitaet verwenden, für einzelne Datensätze mart_datenqualitaet_details.
- Wenn eine Frage Daten betrifft, die von einer roten Prüfung berührt sind, nenne das in einem Satz am Ende der Antwort.

Wenn eine Frage mit diesen Tabellen nicht zu beantworten ist, sag das, statt zu raten.
```

## 4. Beispielfragen

Diese Fragen werden als Beispielfragen (Sample questions) eingetragen. Sie erscheinen als Vorschläge, wenn jemand Genie öffnet:

1. Was hat KI 2025 insgesamt gekostet?
2. Welche Abteilung hatte im Dezember die höchsten KI-Kosten?
3. Wie viele aktive Nutzer gab es im Dezember?
4. Welche Anwendungsfälle kosten je erfolgreicher Anfrage am meisten?
5. Welche Datenqualitätsprobleme gibt es und wer ist zuständig?

## 5. Testfragen mit richtigen Antworten

Nach dem Einrichten werden diese Fragen gestellt und die Antworten mit der Tabelle verglichen. Die Werte sind aus den Gold-Tabellen berechnet und mit dem Dashboard abgeglichen.

| Nr. | Frage | Richtige Antwort | Worauf achten |
|---|---|---|---|
| 1 | Was hat KI 2025 insgesamt gekostet? | 281,52 € | nicht 281,49 € (Summe gerundeter Werte) |
| 2 | Welche Abteilung hatte im Dezember die höchsten KI-Kosten? | Kundenservice mit 9,65 € | |
| 3 | In welchem Monat waren die KI-Kosten am höchsten? | Dezember 2025 mit 38,82 € | |
| 4 | Wie viele aktive Nutzer gab es im Dezember? | 202 | |
| 5 | Wie viele aktive Nutzer gab es im ganzen Jahr 2025? | 220 | **Falle:** Wer die Monate addiert, kommt auf 2.542 |
| 6 | Was hat der Vertrieb im Oktober für KI ausgegeben? | 4,89 € | |
| 7 | Welcher Anwendungsfall kostet je erfolgreicher Anfrage am meisten? | Textzusammenfassung mit 0,0083 € (Risikoklasse hoch) | Hinweis, dass Anfragen ohne Anwendungsfall fehlen |
| 8 | Wie viel kosten Anfragen ohne Anwendungsfall? | 5,63 € bei 1.102 Anfragen | |
| 9 | Wie viele Hochrisiko-Anwendungsfälle sind freigegeben und dokumentiert? | 1 von 4 | |
| 10 | Welche Datenqualitätsprobleme gibt es? | 2 rot (unbekannte Abteilung 2,27 %, ohne Anwendungsfall 1,98 %), 2 gelb (nach Austritt 0,31 %, doppelt 0,25 %) | Zuständigkeiten genannt |
| 11 | Wie hoch ist die Zufriedenheit der Nutzer mit den KI-Anwendungen? | Genie sagt, dass das mit den Daten nicht zu beantworten ist | **Falle:** Es gibt keine Daten zur Zufriedenheit. Genie darf nicht raten. |

Eine falsche Antwort ist kein Grund zur Sorge, sondern der Sinn des Tests. Dann wird die Anweisung in Abschnitt 3 so ergänzt, dass Genie die Regel kennt, und die Frage noch einmal gestellt.
