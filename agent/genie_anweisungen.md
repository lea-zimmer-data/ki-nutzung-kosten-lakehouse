# Genie Agent „KI-Kosten fragen“

Mit dem Genie Agent stellen Fachbereiche ihre Fragen zu KI-Kosten und -Nutzung in normaler Sprache. Genie übersetzt die Frage in eine Abfrage auf die Gold-Tabellen und zeigt die Antwort samt der verwendeten Abfrage. Programmiert wird dafür nichts: Genie bekommt die Tabellen, eine Beschreibung der Rechenregeln und Beispielfragen.

Diese Datei enthält alles, was beim Einrichten eingetragen wird, und die Testfragen mit den richtigen Antworten.

---

## 1. Agent per Beschreibung anlegen

Databricks → **Genie Agents** → **New**. Es erscheint die Frage „What should your Genie agent do?“ mit einem Eingabefeld. Dort kommt diese Beschreibung hinein:

```
Beantworte Fragen zur Nutzung und zu den Kosten von KI in einem Unternehmen: Kosten je Abteilung und Monat, aktive Nutzer, Freigabe und Dokumentation der KI-Anwendungsfälle je Risikoklasse, Kosten je Anwendungsfall und Datenqualität. Verwende genau diese sieben Tabellen aus dem Schema ki_nutzung.gold: fct_usage_events, mart_kosten_je_abteilung_monat, mart_aktive_nutzer_monat, mart_anwendungsfaelle_konformitaet, mart_kosten_je_anwendungsfall, mart_datenqualitaet, mart_datenqualitaet_details.
```

Genie legt daraufhin den Agenten an, wählt die Tabellen aus und schreibt selbst eine Beschreibung, Beispielfragen und einen Entwurf für die Anweisungen.

## 2. Tabellen prüfen

Unter **Configure → Sources** müssen genau diese sieben Tabellen aus `ki_nutzung.gold` stehen:

- `fct_usage_events`
- `mart_kosten_je_abteilung_monat`
- `mart_aktive_nutzer_monat`
- `mart_anwendungsfaelle_konformitaet`
- `mart_kosten_je_anwendungsfall`
- `mart_datenqualitaet`
- `mart_datenqualitaet_details`

## 3. Anweisungen

Genie schlägt beim Anlegen selbst Anweisungen vor. Der Vorschlag war in weiten Teilen gut, enthielt aber zwei Fehler, die zu falschen Zahlen führen:

| Genies Vorschlag | Problem | Korrektur |
|---|---|---|
| Kosten je Abteilung und Monat immer aus `mart_kosten_je_abteilung_monat` | Die Werte dort sind je Zeile gerundet. Summiert ergibt das 281,49 € statt 281,52 €. | Summen immer aus `fct_usage_events` |
| Nutzer können in mehreren Abteilungen aktiv sein | Stimmt nicht, jeder Nutzer gehört zu genau einer Abteilung. Die Regel „nicht addieren“ ist trotzdem richtig, aber wegen der Monate. | Begründung korrigiert, Regel für das ganze Jahr ergänzt |
| konform = Freigabedatum gesetzt | Auch eingestellte Anwendungsfälle haben ein Freigabedatum. | Status `freigegeben` statt Datum |

Nach dem ersten Test wurden zwei Zeilen nachgeschärft (siehe Abschnitt 6). Übernommen wurden Genies gute Ideen, etwa der Hinweis auf die Prozentskalen. Ergänzt wurden die Hinweise auf Anwendungsfälle ohne Zuordnung, auf rote Datenqualitätsprüfungen und die Regel, nicht zu raten. Dieser Text ersetzt Genies Entwurf unter **Configure → Instructions**:

```
Dieser Agent beantwortet Fragen zur Nutzung und zu den Kosten von KI im Unternehmen. Alle Daten sind erfundene Beispieldaten für Januar bis Dezember 2025. Antworte auf Deutsch, kurz und mit der Zahl zuerst. Beträge in Euro mit zwei Nachkommastellen und Komma, zum Beispiel 281,52 €. Kosten je Anfrage mit vier Nachkommastellen, zum Beispiel 0,0083 €.

Kosten:
- Kosten immer aus fct_usage_events als Summe von kosten_eur berechnen, auch je Abteilung, Monat oder Anwendungsfall. Die Tabellen mart_kosten_je_abteilung_monat und mart_kosten_je_anwendungsfall enthalten je Zeile gerundete Werte. Sie nie für Summen verwenden, sonst entstehen Rundungsabweichungen (281,49 € statt richtig 281,52 €).
- Fehlgeschlagene Anfragen (status "fehler") kosten 0 €. Doppelte Lieferungen sind in fct_usage_events bereits entfernt.
- Eine Anfrage ist erfolgreich, wenn ist_erfolg = true.

Aktive Nutzer:
- Aktiv = verschiedene user_id mit mindestens einer erfolgreichen Anfrage, ohne Anfragen nach dem Austritt (ist_nach_austritt = false).
- Jeder Nutzer gehört zu genau einer Abteilung. Abteilungswerte eines Monats dürfen addiert werden.
- Werte mehrerer Monate nie addieren, denn dieselbe Person wäre mehrfach gezählt. Für einen Zeitraum aus mehreren Monaten, etwa das ganze Jahr, die Nutzer in fct_usage_events über den Zeitraum neu zählen.

Monate:
- event_monat ist immer der Monatserste, zum Beispiel 2025-06-01 für Juni 2025. Monatsfilter auf den Monatsersten setzen.

Freigaben:
- Konform = Status freigegeben und Dokumentation vollständig. Eingestellte Anwendungsfälle zählen nicht mit. Dafür mart_anwendungsfaelle_konformitaet verwenden. Risikoklassen: minimal, begrenzt, hoch.

Prozentwerte:
- konform_prozent und anteil_prozent liegen auf einer Skala von 0 bis 100: 40 bedeutet 40 %, 1.98 bedeutet 1,98 %.

Hinweise in Antworten:
- Kommt die Abteilung "Unbekannt" vor, erkläre in einem Satz: Nutzer ohne gültige Abteilungszuordnung.
- Bei Kosten je Anwendungsfall diesen Hinweis geben: „Anfragen ohne Anwendungsfall sind in den Gesamtkosten enthalten, aber keinem Anwendungsfall zugeordnet. Sie fehlen deshalb in dieser Auswertung.“ Dazu die Risikoklasse des Anwendungsfalls nennen.
- Bei Fragen zur Datenqualität mart_datenqualitaet verwenden, für einzelne Datensätze mart_datenqualitaet_details. Betrifft eine Antwort Daten, die von einer roten Prüfung berührt sind, das in einem Satz am Ende nennen.

Wenn eine Frage mit diesen Tabellen nicht zu beantworten ist, sag das, statt zu raten.
```

## 4. Beispielfragen

Genie schlägt beim Anlegen selbst passende Beispielfragen vor (Reiter **About**, „Common questions“). Diese können bleiben. Wer eigene eintragen will, nimmt diese:

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

## 6. Testergebnis vom 12.11.2026

**Ergebnis: 11 von 11 Fragen mit richtiger Zahl.** Eine Antwort musste nachgeschärft werden, zwei haben kleine Lücken im Wortlaut.

| Nr. | Ergebnis | Bemerkung |
|---|---|---|
| 1 | ✅ 281,52 € | nicht die gerundeten 281,49 € |
| 2 | ✅ Kundenservice, 9,65 € | |
| 3 | ✅ Dezember 2025, 38,82 € | |
| 4 | ✅ 202 | |
| 5 | ✅ 220 | Falle erkannt: jeder Nutzer nur einmal gezählt, nicht 2.542 |
| 6 | ✅ 4,89 € | |
| 7 | ✅ Textzusammenfassung, 0,0083 €, Risikoklasse hoch | Im ersten Versuch „0,01 €“ und ein verdrehter Hinweis. Nach zwei Zeilen mehr in der Anweisung richtig. |
| 8 | ✅ 5,63 € | Hinweis auf die rote Prüfung fehlt |
| 9 | ✅ 1 | „von 4“ fehlt in der Antwort |
| 10 | ✅ 4 Prüfungen, Werte und Ampeln richtig | Empfehlungen genannt, Zuständigkeiten nicht |
| 11 | ✅ keine Daten zur Zufriedenheit | Falle erkannt: kein Raten |

**Was der Test zeigt:** Genies eigener Entwurf der Anweisungen hätte bei Summen über Abteilungen zu Rundungsfehlern geführt. Erst die fachliche Prüfung hat das verhindert. Ein KI-Agent ist so gut wie die Regeln, die ihm ein Mensch mitgibt, und wie die Tests, mit denen ein Mensch ihn prüft.
