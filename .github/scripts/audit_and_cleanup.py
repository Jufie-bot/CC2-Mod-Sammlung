# -*- coding: utf-8 -*-
"""
audit_and_cleanup.py
=====================
System-Audit: Analysiert alle Issues und bereinigt:
  - Alte Legacy-Titel-Format Issues (doppelt zu neuen)
  - Test-Issues
  - Issues ohne Labels
  - Falsche Label-Kombinationen

Ergebnis: Bericht + optionale Aktion (--fix um wirklich zu bereinigen)
"""

import subprocess
import json
import sys
from collections import defaultdict


def get_all_issues() -> list[dict]:
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "all",
         "--json", "number,title,labels,state,createdAt",
         "--limit", "500"],
        capture_output=True, text=True, encoding="utf-8"
    )
    if result.returncode != 0:
        print(f"[FEHLER] {result.stderr}")
        return []
    return json.loads(result.stdout)


def analyze_issues(issues: list[dict]) -> dict:
    """Analysiert die Issues und gibt einen Bericht zurueck."""
    report = {
        "total":           len(issues),
        "open":            sum(1 for i in issues if i["state"] == "OPEN"),
        "closed":          sum(1 for i in issues if i["state"] == "CLOSED"),
        "no_labels":       [],
        "legacy_titles":   [],   # Alte Titel-Format "[ANALYSE] X-Mod untersuchen: Y"
        "new_titles":      [],   # Neue Titel-Format "[ANALYSE] X-Mod: Y"
        "duplicates":      [],   # Issues deren Mod-Name schon im neuen Format existiert
        "test_issues":     [],   # Issues die als Test markiert sind
        "wiki_issues":     [],   # [WIKI] Issues
        "wrong_labels":    [],   # Status-Label ohne Typ-Label
    }

    # Index: Mod-Name → Issue-Nummern (fuer Duplikat-Erkennung)
    mod_index: dict[str, list[int]] = defaultdict(list)

    for issue in issues:
        num    = issue["number"]
        title  = issue["title"]
        labels = [l["name"] for l in issue["labels"]]
        state  = issue["state"]

        # Test-Issues identifizieren
        if "Test" in title or "test" in title or "Probe" in title:
            report["test_issues"].append({"number": num, "title": title, "state": state})

        # Wiki-Issues
        if title.startswith("[WIKI]"):
            report["wiki_issues"].append({"number": num, "title": title, "state": state})

        # Kein Label
        if not labels:
            report["no_labels"].append({"number": num, "title": title, "state": state})

        # Legacy-Titel: "[ANALYSE] X-Mod untersuchen: Y"
        if "[ANALYSE]" in title and "untersuchen:" in title:
            # Extrahiere Mod-Name
            parts = title.split("untersuchen:")
            if len(parts) > 1:
                mod_name = parts[1].strip()
                report["legacy_titles"].append({
                    "number": num, "title": title,
                    "state": state, "mod_name": mod_name
                })
                mod_index[mod_name].append(num)

        # Neues Titel-Format: "[ANALYSE] X-Mod: Y"
        elif "[ANALYSE]" in title and "untersuchen:" not in title and ":" in title:
            parts = title.split(":")
            if len(parts) > 1:
                mod_name = ":".join(parts[1:]).strip()
                report["new_titles"].append({
                    "number": num, "title": title,
                    "state": state, "mod_name": mod_name
                })
                mod_index[mod_name].append(num)

    # Duplikate: Mod-Name in BEIDEN Formaten vorhanden
    for mod_name, nums in mod_index.items():
        if len(nums) > 1:
            report["duplicates"].append({
                "mod_name": mod_name,
                "issues": nums
            })

    return report


def print_report(report: dict):
    print("\n" + "="*60)
    print("SYSTEM-AUDIT BERICHT")
    print("="*60)
    print(f"Gesamt Issues:       {report['total']}")
    print(f"  Offen:             {report['open']}")
    print(f"  Geschlossen:       {report['closed']}")
    print(f"  Ohne Labels:       {len(report['no_labels'])}")
    print(f"  Legacy-Formate:    {len(report['legacy_titles'])}")
    print(f"  Neue Formate:      {len(report['new_titles'])}")
    print(f"  Duplikate:         {len(report['duplicates'])}")
    print(f"  Test-Issues:       {len(report['test_issues'])}")
    print(f"  Wiki-Issues:       {len(report['wiki_issues'])}")

    if report["duplicates"]:
        print("\n--- Duplikate (bitte pruefen) ---")
        for d in report["duplicates"][:10]:
            print(f"  Mod: '{d['mod_name']}' -> Issues: {d['issues']}")

    if report["test_issues"]:
        print("\n--- Test-Issues ---")
        for t in report["test_issues"]:
            print(f"  #{t['number']} [{t['state']}] {t['title']}")

    if report["no_labels"]:
        print(f"\n--- Ohne Labels (erste 10) ---")
        for i in report["no_labels"][:10]:
            print(f"  #{i['number']} [{i['state']}] {i['title']}")

    print("\n" + "="*60)


def close_legacy_duplicates(report: dict, dry_run: bool = True):
    """Schliesst Legacy-Issues die ein Duplikat im neuen Format haben."""
    new_mod_names = {i["mod_name"] for i in report["new_titles"]}

    to_close = []
    for legacy in report["legacy_titles"]:
        if legacy["mod_name"] in new_mod_names and legacy["state"] == "OPEN":
            to_close.append(legacy)

    print(f"\n[CLEANUP] Legacy-Issues zum Schliessen: {len(to_close)}")

    for issue in to_close:
        if dry_run:
            print(f"  [DRY-RUN] Wuerde schliessen: #{issue['number']} - {issue['title']}")
        else:
            subprocess.run(
                ["gh", "issue", "close", str(issue["number"]),
                 "--comment", "Automatisch geschlossen: neueres Issue mit gleicher Mod existiert (neues Titel-Format)."],
                check=True
            )
            print(f"  [OK] Geschlossen: #{issue['number']}")

    return len(to_close)


def fix_missing_labels(report: dict, dry_run: bool = True):
    """Setzt fehlende Labels auf Issues ohne Labels."""
    fixed = 0
    for issue in report["no_labels"]:
        title = issue["title"]
        num   = issue["number"]

        # Label basierend auf Titel-Prefix bestimmen
        if "[ANALYSE]" in title:
            label = "Typ: Forschung & Analyse"
        elif "[WIKI]" in title:
            label = "Wiki & Doku"
        elif "[BUG]" in title:
            label = "Typ: Bug / Fix"
        else:
            continue

        if dry_run:
            print(f"  [DRY-RUN] Label '{label}' setzen auf #{num}")
        else:
            subprocess.run(
                ["gh", "issue", "edit", str(num), "--add-label", label],
                capture_output=True
            )
            print(f"  [OK] Label gesetzt: #{num} -> {label}")
        fixed += 1

    return fixed


def main():
    fix_mode = "--fix" in sys.argv
    print(f"[INFO] Modus: {'LIVE (erstellt Aenderungen)' if fix_mode else 'DRY-RUN (nur Analyse)'}")

    print("[INFO] Lade alle Issues...")
    issues = get_all_issues()
    if not issues:
        print("[FEHLER] Keine Issues geladen.")
        return

    report = analyze_issues(issues)
    print_report(report)

    print(f"\n[ACTION] Legacy-Duplikate bereinigen...")
    closed = close_legacy_duplicates(report, dry_run=not fix_mode)

    print(f"\n[ACTION] Fehlende Labels fixen...")
    fixed = fix_missing_labels(report, dry_run=not fix_mode)

    if not fix_mode:
        print(f"\n[FAZIT] DRY-RUN abgeschlossen.")
        print(f"  Wuerde schliessen:    {closed} Issues")
        print(f"  Wuerde Labels setzen: {fixed} Issues")
        print(f"\n  Starte mit '--fix' um Aenderungen wirklich durchzufuehren.")
    else:
        print(f"\n[FAZIT] Bereinigung abgeschlossen.")
        print(f"  Geschlossen:           {closed} Issues")
        print(f"  Labels korrigiert:     {fixed} Issues")


if __name__ == "__main__":
    main()
