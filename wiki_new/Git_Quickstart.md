# 🛠️ Git & Quellcodeverwaltung: Das Master-Handbuch

Dieses Handbuch erklärt dir alles, was du wissen musst, um deine Mods sicher zu verwalten. Nach unserer Umbenennung arbeitest du mit **"Lokale-Dateien"** (dein PC) und **"GitHub"** (der Server).

---

## 🔑 1. Die Grundbegriffe (Was ist was?)

| Begriff | Deutsche Bedeutung | Zweck |
| :--- | :--- | :--- |
| **Commit** | Speichern / Meilenstein | Erstellt einen permanenten Speicherpunkt deines aktuellen Stands. |
| **Push** | Hochladen | Schickt deine lokalen Speicherpunkte an **GitHub**. |
| **Pull** | Herunterladen | Holt neue Änderungen von **GitHub** auf deinen PC. |
| **Stage (+)** | Vormerken | Wählt aus, welche Dateien im nächsten Commit landen sollen. |
| **Branch** | Zweig | Eine eigene Arbeitskopie (deine heißt jetzt `Lokale-Dateien`). |
| **Remote** | Server | Der Ort, an dem der Code online liegt (deiner heißt jetzt `GitHub`). |

---

## 🚦 2. Status-Symbole & Farben

In der Liste "Änderungen" (Changes) siehst du diese Buchstaben:
- 🟡 **M (Modified)**: Du hast eine existierende Datei bearbeitet.
- 🟢 **A (Added)**: Du hast eine neue Datei erstellt.
- 🔴 **D (Deleted)**: Du hast eine Datei gelöscht.
- ⚪ **U (Untracked)**: Eine neue Datei, die Git noch nicht "beobachtet" (Klicke auf **+**, um sie zu tracken).

---

## 🛠️ 3. Dein Workflow: So arbeitest du richtig

### Schritt 1: Änderungen vorbereiten (Stage)
Wenn du fertig bist, klicke im Git-Tab auf das kleine **+** neben den Dateien.
- Sie wandern nach oben zu **"Staged Changes"**. 
- Nur Dateien, die hier liegen, werden im nächsten Schritt gespeichert!

### Schritt 2: Speichern (Commit)
Gib oben im Textfeld eine kurze Nachricht ein (z.B. "Turbo-Missile Reichweite erhöht").
- Klicke auf den **Haken (Checkmark)** oder den Button **Commit**.
- Deine Änderungen sind jetzt sicher auf deinem PC gespeichert.

### Schritt 3: Veröffentlichen (Push / Sync)
Klicke auf den blauen Button **Sync Changes** oder auf die kleine Wolke/Pfeil nach oben.
- Deine lokalen Speicherpunkte werden zu **GitHub** hochgeladen.

---

## 🔄 4. Rückgängig machen & Fehler beheben

### "Ich habe mich verschrieben/etwas kaputt gemacht" (Vor dem Commit)
- Rechtsklick auf die Datei im Git-Tab -> **Discard Changes**.
- Die Datei springt auf den Stand der letzten Speicherung zurück.

### "Ich will den letzten Speicherpunkt löschen" (Nach dem Commit)
- Suche im Git-Menü (drei Punkte `...`) nach **Commit** -> **Undo Last Commit**.
- Dein Code bleibt erhalten, aber der Meilenstein wird gelöscht, sodass du ihn bearbeiten kannst.

### "Alles auf Anfang" (Hard Reset)
- Wenn gar nichts mehr geht: Rechtsklick auf den letzten Meilenstein im Graph -> **Reset Branch to here** -> **Hard**.
- **Achtung**: Das löscht ALLE ungespeicherten Änderungen unwiderruflich!

---

## 🏷️ 5. Umbenennen & Priorisieren

### Einen Zweig (Branch) umbenennen
Das haben wir gerade getan. Im Terminal geht das so:
`git branch -m alter-name neuer-name`

### Konflikte lösen (Wenn zwei Leute dasselbe ändern)
Wenn du einen **Pull** machst und Git sagt "Konflikt":
1.  Öffne die Datei. Du siehst Markierungen wie `<<<< HEAD`.
2.  In der IDE gibt es meist Knöpfe: **"Accept Incoming"** (GitHub behalten) oder **"Accept Current"** (Deine behalten).
3.  Wähle das Richtige aus, speichere die Datei und klicke wieder auf das **+** (Stage).

---
> [!TIP]
> **Goldene Regel**: Mache lieber viele kleine Commits ("Schneidbrenner angepasst", "Textur korrigiert") als einen riesigen am Ende des Tages. Das macht das Rückgängigmachen viel einfacher!
