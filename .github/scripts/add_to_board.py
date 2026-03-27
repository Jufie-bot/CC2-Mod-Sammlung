# -*- coding: utf-8 -*-
"""
add_to_board.py
===============
Weist GitHub Issues automatisch den richtigen Projekt-Boards zu.
Basiert auf der GitHub GraphQL API (addProjectV2ItemById).

WICHTIG: Benoetigt GH_TOKEN mit project:write Berechtigung.
Beim Aufruf aus GitHub Actions: GITHUB_TOKEN reicht aus, wenn
'permissions: projects: write' im Workflow gesetzt ist.

Board-Struktur:
  Board 1 - Forschungs-Labor    (#14) - fuer Analyse-Issues
  Board 2 - Mod-Entwicklung     (#15) - fuer Feature/Bug-Issues der eigenen Mods
  Board 3 - GitHub-Infrastruktur(#16) - fuer Automatisierungs-Issues
  Board 4 - Wiki                (#17) - fuer Wiki-Aufgaben
"""

import os
import subprocess
import json
from typing import Optional


# ============================================================
# BOARD IDs (GitHub Projects V2)
# ============================================================
BOARDS = {
    "forschung":        "PVT_kwHODHDu1M4BRuPG",   # Board 1: Forschungs-Labor
    "mod-entwicklung":  "PVT_kwHODHDu1M4BRuQB",   # Board 2: Mod-Entwicklung
    "infrastruktur":    "PVT_kwHODHDu1M4BRuQf",   # Board 3: GitHub-Infrastruktur
    "wiki":             "PVT_kwHODHDu1M4BRuRp",   # Board 4: Wiki
}


# ============================================================
# LABEL → BOARD ROUTING
# Welches Label → welches Board?
# ============================================================
LABEL_TO_BOARD = {
    "Typ: Forschung & Analyse":  "forschung",
    "Typ: Bug / Fix":            "mod-entwicklung",
    "Typ: Mod-Feature":          "mod-entwicklung",
    "Wiki & Doku":               "wiki",
    "Automatisierung":           "infrastruktur",
    "Sandkasten & Snippets":     "forschung",
    # Bereichs-Labels → Forschungs-Labor
    "Audio & Sounds":            "forschung",
    "Gameplay & Balancing":      "forschung",
    "UI / HUD":                  "forschung",
    "Fahrzeuge & Schiffe":       "forschung",
    "Waffen & Geschutze":        "forschung",
    "Waffen & Gesc\u00fctze":    "forschung",
    "KI & Skynet":               "forschung",
}

DEFAULT_BOARD = "forschung"  # Fallback


def get_issue_node_id(issue_number: int) -> Optional[str]:
    """Gibt die GraphQL Node-ID eines Issues zurueck."""
    result = subprocess.run(
        ["gh", "issue", "view", str(issue_number), "--json", "id"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"  [FEHLER] Issue #{issue_number} konnte nicht abgefragt werden")
        return None
    data = json.loads(result.stdout)
    return data.get("id")


def get_issue_labels(issue_number: int) -> list[str]:
    """Gibt die Labels eines Issues zurueck."""
    result = subprocess.run(
        ["gh", "issue", "view", str(issue_number), "--json", "labels"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        return []
    data = json.loads(result.stdout)
    return [label["name"] for label in data.get("labels", [])]


def determine_board(labels: list[str]) -> str:
    """Bestimmt das richtige Board basierend auf den Labels."""
    for label in labels:
        if label in LABEL_TO_BOARD:
            return LABEL_TO_BOARD[label]
    return DEFAULT_BOARD


def add_issue_to_board(node_id: str, board_key: str) -> Optional[str]:
    """
    Fuegt ein Issue zu einem Projekt-Board hinzu.
    Returns: Item-ID des erstellten Board-Eintrags oder None bei Fehler.
    """
    project_id = BOARDS.get(board_key)
    if not project_id:
        print(f"  [FEHLER] Unbekannter Board-Key: {board_key}")
        return None

    result = subprocess.run(
        ["gh", "api", "graphql",
         "-F", f"projectId={project_id}",
         "-F", f"contentId={node_id}",
         "-f", "query=mutation($projectId: ID!, $contentId: ID!) { addProjectV2ItemById(input: { projectId: $projectId, contentId: $contentId }) { item { id } } }"],
        capture_output=True, text=True
    )

    if result.returncode != 0:
        # Bereits im Board → kein Fehler
        if "already" in result.stderr.lower() or "duplicate" in result.stderr.lower():
            print(f"  [INFO] Issue bereits im Board '{board_key}'")
            return "already_added"
        print(f"  [FEHLER] GraphQL Mutation fehlgeschlagen: {result.stderr.strip()}")
        return None

    try:
        data = json.loads(result.stdout)
        item_id = data["data"]["addProjectV2ItemById"]["item"]["id"]
        print(f"  [OK] Board '{board_key}' -> Item-ID: {item_id}")
        return item_id
    except (KeyError, json.JSONDecodeError) as e:
        # Board-Item existiert bereits -> ist kein Fehler
        if "already" in result.stdout:
            print(f"  [INFO] Issue bereits im Board '{board_key}'")
            return "already_added"
        print(f"  [FEHLER] Antwort nicht parsierbar: {e}")
        return None


def process_issue(issue_number: int):
    """Hauptfunktion: Weist ein einzelnes Issue dem richtigen Board zu."""
    print(f"\n[BOARD] Verarbeite Issue #{issue_number}...")

    node_id = get_issue_node_id(issue_number)
    if not node_id:
        return

    labels     = get_issue_labels(issue_number)
    board_key  = determine_board(labels)

    print(f"  Labels: {labels}")
    print(f"  -> Ziel-Board: {board_key}")

    add_issue_to_board(node_id, board_key)


def process_all_open_issues():
    """Verarbeitet alle offenen Issues und weist sie dem richtigen Board zu."""
    print("[INFO] Lade alle offenen Issues...")
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "open", "--json", "number,labels", "--limit", "500"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"[FEHLER] {result.stderr}")
        return

    issues = json.loads(result.stdout)
    print(f"[INFO] {len(issues)} offene Issues gefunden.")

    for issue in issues:
        number = issue["number"]
        labels = [l["name"] for l in issue.get("labels", [])]
        board_key = determine_board(labels)

        node_id = get_issue_node_id(number)
        if node_id:
            print(f"  Issue #{number} -> Board: {board_key}")
            add_issue_to_board(node_id, board_key)

    print("\n[OK] Board-Sync abgeschlossen.")


def main():
    import sys
    if len(sys.argv) > 1:
        # Einzelnes Issue verarbeiten: python add_to_board.py 42
        issue_number = int(sys.argv[1])
        process_issue(issue_number)
    else:
        # Alle offenen Issues verarbeiten
        process_all_open_issues()


if __name__ == "__main__":
    main()
