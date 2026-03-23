# 📟 CC2 Modding Command Center

> **Willkommen im Zentrallabor!** Dies ist die systematische Wissensdatenbank und das technische Herzstück des CC2-Modding-Projekts. 

## 🗺️ Was ist dieses Wiki?

Dieses Wiki dient als zentraler Anlaufpunkt für Entwickler, Forscher und Modder von Carrier Command 2. Unser primäres Ziel ist es, das stark fragmentierte Wissen über Spielmechaniken, Lua-Scripte und XML-Dateien an einem einzigen Ort zu bündeln, kritisch zu analysieren und hochgradig strukturiert zugänglich zu machen. 

Egal, ob du verstehen willst, wie die interne Wegfindung funktioniert, eigene UI-Elemente schreiben möchtest oder schlichtweg nach den korrekten Waffen-IDs suchst – hier findest du gesichertes und stetig wachsendes Wissen.

---

## 📚 Die Enzyklopädie (Alle Bereiche im Detail)

Unser Wissen ist in logische Themenkomplexe unterteilt. Hier ist der komplette Überblick darüber, was dich in den jeweiligen Bereichen erwartet:

### 1. 🧭 Einstieg & Philosophie
*   **📘 [[System-Guide|Was-ist-was]]**: Die perfekte Einführung. Erklärt unsere Projektstruktur, die Hierarchie der Repositorys und wie du dich am besten im Labor zurechtfindest.

### 2. 🏗️ Das theoretische Fundament
Bevor der erste Code geschrieben wird, braucht es Verständnis für das Spiel:
*   **[[CC2-Architektur]]**: Wie Carrier Command 2 unter der Haube tickt.
*   **[[Modding-Grundlagen]]**: Struktur von Mods im Spielordner.
*   **[[Bekannte Grenzen|Bekannte-Grenzen]]**: Was die Engine unmöglich macht (Hard-Coding) und wo wir Kompromisse schließen.
*   **[[XML-Grundlagen]]** & **[[Lua-Hook-System]]**: Die grundlegenden Technologien, in denen CC2-Mods geschrieben sind.
*   **[[Save-Editing]]** & **[[Git-Quickstart]]**.

### 3. 🔍 Was ist möglich?
*   **[[Modding-Tiefen|Modding-Tiefen-Uebersicht]]**: Eine Übersicht, wie tief wir in einzelne Spielsysteme (Waffen, Fahrphysik, Radar) eingreifen können.

### 4. 📖 Game-Referenz (Die Datenbank)
Dein ständiger Begleiter beim Modden. Pures Datenwissen:
*   **XML**: [[Waffen-XML|Waffen-XML-Referenz]], [[XML-Parameter|XML-Parameter-Typen]], [[Attachment-System]], [[Spezial-Objekte]].
*   **Lua**: [[Lua-Kernfunktionen]] (Alle nativen CC2-Funktionen), [[Globaler Scope|Globaler-Scope]], [[Lua-Script-Analyse|Lua-Script-Analysis]].
*   **Listen**: [[Einheiten|Einheiten-Uebersicht]] (Fahrzeug IDs, Waffen IDs) und die globale [[Constants|Constants-Vollreferenz]].

### 5. 🛠️ Guides & Code-Standards
Regeln für sauberes und kompatibles Arbeiten:
*   **[[Guides & Tutorials|Guides-und-Tutorials]]**: Praktische Workflows wie das [[Lua-Debugging]] oder der [[Entwickler-Guide-Index]].
*   **[[Code-Standards]]**: Unsere goldenen Regeln. Betrifft [[Allgemeine Regeln|Allgemeine-Regeln]], das [[Technisches Handbuch|Technisches-Handbuch]] für Repo-Strukturen und die [[YAML-Frontmatter]] Vorgaben für Analysen.

### 6. 🔬 Die Forschungsstation
Das Herz des Labors: Hier nehmen wir Mods, Code und Mechaniken auseinander.
*   **[[Mod-Galerie]]**: Enthält unsere kuratierten Analysen von existierenden Mods (Tiefenblicke in Waffen-, Audio- und UI-Mods), die [[Kategorien-Liste]] aller bekannten Mods und automatische [[Statistiken]].
*   **[[Labor-Experimente]]**: Dokumentierte Versuchsreihen (z.B. A/B Tests von Parametern) und Problemlösungen.
*   **[[Kategorienübergreifende Mods|Kategorienuebergreifende-Mods]]**: Analysen von riesigen Frameworks wie "Revolution".
*   **[[Eigene Mods|Eigene-Mods]]**: Entwicklungsberichte zu unseren eigenen Modding-Projekten.

### 7. 🏗️ Praktische Ressourcen
Wenn du selbst arbeiten willst:
*   **[[Sandkasten]]**: Deine Sammlung an wiederverwendbaren Snippets, Boilerplate-Codes und entpackten Vanilla-Originaldateien zum schnellen Kopieren.
*   **[[Automatisierung]]**: Dokumentation unserer GitHub-Bots und Skripte (u.a. [[Projekt-Entwicklung]]).

### 8. 🌍 News, Updates & Community
Werde Teil des Ganzen und bleib auf dem Laufenden:
*   **[[Spiel-Updates|CHANGELOG]]**: Protokoll über neue CC2-Updates und deren Auswirkungen auf Mods.
*   **[[Community|Beitragen]]**: Wie du per Pull Request mitmachen oder eine eigene [[Analyse einreichen|Analyse-einreichen]] kannst.

---

## 📰 Automatisierte Labor-News

Unser Projekt hält sich selbst in Schuss! Hier siehst du die Live-Statistiken, die durch unsere GitHub-Actions dynamisch aus allen Analyse-Dokumenten generiert werden.

<!-- BEGIN:stats -->
| 📦 Mods analysiert | **13** |
| ✅ Wiki-ready | **13** |
| 🔄 In Bearbeitung | **0** |
| 📅 Zuletzt aktualisiert | **2026-03-23** |
<!-- END:stats -->

### 🚀 Aktuelle Meilensteine (März 2026)
*   **Waffen-Forschung abgeschlossen**: 12 Weapons-Mods und 1 Audio-Mod wurden erfolgreich detailanalysiert und in das strukturierte YAML-Frontmatter System überführt.
*   **Struktureller Umbau beendet**: Die Infrastruktur steht! Das Wiki hat jetzt eine lückenlose Seitenarchitektur, die mit dem Haupt-Projektboard perfekt verzahnt ist. 
