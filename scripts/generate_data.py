"""Erzeugt vollständig synthetische Beispieldaten zur KI-Nutzung und zu KI-Kosten.

Alle Namen, Modelle, Preise und Mengen sind frei erfunden. Es gibt keinen Bezug
zu realen Unternehmen, Anbietern oder Personen.

Aufruf:
    python scripts/generate_data.py            # schreibt nach data/raw/
    python scripts/generate_data.py --seed 7   # anderer Zufallsstart

Bewusst eingebaute Datenqualitätsprobleme (für dbt-Tests und Doku):
  1. doppelte event_id in usage_events
  2. Events ohne use_case_id
  3. Events von Nutzern nach ihrem Austrittsdatum
  4. Nutzer mit unbekannter department_id
"""

import argparse
import csv
import math
import random
from datetime import date, datetime, timedelta
from pathlib import Path

START = date(2025, 1, 1)
END = date(2025, 12, 31)
N_USERS = 220

DEPARTMENTS = [
    ("D01", "Vertrieb", "KST-1100"),
    ("D02", "Marketing", "KST-1200"),
    ("D03", "Kundenservice", "KST-1300"),
    ("D04", "Finanzen", "KST-1400"),
    ("D05", "Personal", "KST-1500"),
    ("D06", "IT", "KST-1600"),
    ("D07", "Produktentwicklung", "KST-1700"),
    ("D08", "Recht und Compliance", "KST-1800"),
]

# Erfundene Modelle: (id, Name, Preis je 1.000 Eingabe-Token, je 1.000 Ausgabe-Token in EUR)
MODELS = [
    ("M1", "modell-klein", 0.0002, 0.0008),
    ("M2", "modell-mittel", 0.0015, 0.0060),
    ("M3", "modell-gross", 0.0100, 0.0300),
]

USE_CASE_NAMES = [
    "Textzusammenfassung", "E-Mail-Entwurf", "Kundenchat-Assistent",
    "Vertragsprüfung", "Marketingtexte", "Code-Assistent",
    "Dokumentensuche", "Rechnungsprüfung", "Bewerbungs-Vorauswahl",
    "Übersetzung", "Berichtserstellung", "Wissensdatenbank-Antworten",
    "Ticket-Klassifikation", "Prognose-Erläuterung", "Schulungsmaterial",
]
RISK_CLASSES = ["minimal", "begrenzt", "hoch"]


def month_weight(d: date) -> float:
    """Nutzung wächst über das Jahr: Faktor 1,0 im Januar bis etwa 3,5 im Dezember."""
    return 1.0 + (d.month - 1) * 0.23


def main(seed: int, out: Path) -> None:
    rng = random.Random(seed)
    out.mkdir(parents=True, exist_ok=True)

    # departments
    with open(out / "departments.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["department_id", "department_name", "cost_center"])
        w.writerows(DEPARTMENTS)

    # ai_models
    with open(out / "ai_models.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["model_id", "model_name", "price_per_1k_input_eur", "price_per_1k_output_eur"])
        w.writerows(MODELS)

    # users
    dept_ids = [d[0] for d in DEPARTMENTS]
    dept_weights = [18, 10, 25, 8, 6, 14, 12, 7]
    users = []
    for i in range(1, N_USERS + 1):
        uid = f"U{i:04d}"
        dept = rng.choices(dept_ids, weights=dept_weights)[0]
        hired = START - timedelta(days=rng.randint(30, 2500))
        left = None
        if rng.random() < 0.08:
            left = START + timedelta(days=rng.randint(90, 330))
        # Qualitätsproblem 4: wenige Nutzer mit unbekannter Abteilung
        if rng.random() < 0.015:
            dept = "D99"
        users.append((uid, dept, hired, left))
    with open(out / "users.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["user_id", "department_id", "hired_date", "left_date"])
        for u in users:
            w.writerow([u[0], u[1], u[2].isoformat(), u[3].isoformat() if u[3] else ""])

    # use_cases
    use_cases = []
    for i, name in enumerate(USE_CASE_NAMES, start=1):
        ucid = f"UC{i:03d}"
        dept = rng.choice(dept_ids)
        risk = rng.choices(RISK_CLASSES, weights=[55, 30, 15])[0]
        status = rng.choices(["pilot", "freigegeben", "eingestellt"], weights=[25, 65, 10])[0]
        approved = ""
        if status != "pilot":
            approved = (START + timedelta(days=rng.randint(0, 200))).isoformat()
        doc_ok = rng.random() < (0.6 if risk == "hoch" else 0.85)
        use_cases.append((ucid, name, dept, risk, status, approved, doc_ok))
    with open(out / "use_cases.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["use_case_id", "use_case_name", "department_id", "risk_class",
                    "status", "approved_date", "documentation_complete"])
        for u in use_cases:
            w.writerow([*u[:6], str(u[6]).lower()])

    # usage_events
    events = []
    n_days = (END - START).days + 1
    eid = 0
    for day_idx in range(n_days):
        d = START + timedelta(days=day_idx)
        if d.weekday() >= 5 and rng.random() < 0.8:
            continue  # am Wochenende deutlich weniger Nutzung
        base_users = int(N_USERS * 0.12 * month_weight(d))
        for uid, dept, hired, left in rng.sample(users, min(base_users, len(users))):
            if hired > d:
                continue
            ended = left is not None and d > left
            # Qualitätsproblem 3: einige Events nach Austritt durchlassen
            if ended and rng.random() > 0.05:
                continue
            for _ in range(rng.randint(1, 6)):
                eid += 1
                uc = rng.choice(use_cases)
                # große Modelle werden bei Hochrisiko-Fällen häufiger genutzt
                mw = [50, 35, 15] if uc[3] != "hoch" else [20, 45, 35]
                model = rng.choices(MODELS, weights=mw)[0]
                tok_in = int(min(rng.lognormvariate(6.2, 0.9), 60000))
                tok_out = int(min(rng.lognormvariate(5.6, 0.8), 20000))
                ts = datetime(d.year, d.month, d.day, rng.randint(7, 19), rng.randint(0, 59), rng.randint(0, 59))
                status = "fehler" if rng.random() < 0.03 else "erfolg"
                use_case_id = uc[0]
                # Qualitätsproblem 2: fehlende Zuordnung
                if rng.random() < 0.02:
                    use_case_id = ""
                events.append([f"E{eid:08d}", ts.isoformat(sep=" "), uid, use_case_id,
                               model[0], tok_in, tok_out,
                               int(rng.lognormvariate(7.0, 0.5)), status])

    # Qualitätsproblem 1: Duplikate
    for row in rng.sample(events, max(1, len(events) // 400)):
        events.append(list(row))
    rng.shuffle(events)

    with open(out / "usage_events.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["event_id", "event_ts", "user_id", "use_case_id", "model_id",
                    "input_tokens", "output_tokens", "latency_ms", "status"])
        w.writerows(events)

    print(f"users={len(users)} use_cases={len(use_cases)} events={len(events)} -> {out}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--out", type=Path, default=Path("data/raw"))
    args = ap.parse_args()
    main(args.seed, args.out)
