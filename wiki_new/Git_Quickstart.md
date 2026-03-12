# 🛠️ Git & Quellcodeverwaltung: Der Schnelleinstieg

Dieses Handbuch erklärt dir die wichtigsten Begriffe und Knöpfe in deiner Quellcodeverwaltung (Git), damit du deine Änderungen sicher speichern und hochladen kannst.

---

## 🔑 Die wichtigsten Begriffe

| Begriff | Deutsche Bedeutung | Was passiert da? |
| :--- | :--- | :--- |
| **Commit** | Speichern / Einreichen | Du erstellst einen "Schnappschuss" deiner aktuellen Änderungen. |
| **Push** | Hochladen | Deine lokalen Commits werden auf den GitHub-Server übertragen. |
| **Pull** | Herunterladen | Du holst dir die neuesten Änderungen von GitHub auf deinen PC. |
| **Stage (+)** | Bereitstellen | Du wählst aus, welche Dateien in den nächsten *Commit* sollen. |
| **Sync** | Synchronisieren | Ein kombinierter Befehl aus *Pull* und *Push*. |
| **Discard** | Verwerfen | Du machst alle Änderungen an einer Datei rückgängig (Vorsicht!). |

---

## 🚦 Status-Markierungen in der IDE

- **M (Modified / Gelb oder Blau)**: Die Datei wurde geändert.
- **A (Added / Grün)**: Eine ganz neue Datei, die Git jetzt kennt.
- **D (Deleted / Rot)**: Die Datei wurde gelöscht.
- **U (Untracked / Grau)**: Eine neue Datei, die Git noch *nicht* überwacht.
- **Farbe im Code-Rand**: Zeigt direkt im Code an, welche Zeilen neu (Grün) oder geändert (Blau/Gelb) sind.

---

## 🧭 Die Repository-Übersicht

In deinem Git-Tab siehst du oft Begriffe wie **"main"** oder **"origin/main"**:

- **main (Lokal)**: Deine Version des Projekts auf deinem PC.
- **origin/main (Server)**: Die Version, die aktuell auf GitHub liegt.
- **Blau/Lila Balken im Graph**: Diese visualisieren den Verlauf. Jeder Punkt ist ein Speicherzeitpunkt.
- **Checkout**: "Aktivieren" einer bestimmten Version oder eines Zweigs (Branch).

---

## 🛠️ Dein Workflow (Schritt für Schritt)

1.  **Ändern**: Du bearbeitest deine Mods.
2.  **Staging**: Klicke auf das **+** neben den Dateien. Sie wandern zu "Staged Changes".
3.  **Commit**: Gib eine Nachricht ein und klicke auf den Haken.
4.  **Push/Sync**: Übertrage alles auf GitHub.

---

## 🌪️ Notfall-Hilfe

> [!TIP]
> **"Ich habe etwas falsch gemacht und will zurück!"**
> - Vor dem Commit: Rechtsklick -> **Discard Changes**.
> - Nach dem Commit (vor dem Push): **Undo Last Commit**.

> [!IMPORTANT]
> **Merge Conflict**: Wenn Git nicht weiß, welche Änderung wichtiger ist. Wähle im Fenster die richtige Version aus und bestätige mit "Accept".
