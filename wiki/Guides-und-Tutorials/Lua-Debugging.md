# Lua Script Debugging

Beim Entwickeln von Skripten (z. B. wenn ein Bildschirm eingeschaltet ist oder eine Fahrzeugkamera aktiv ist) können `print()`-Anweisungen genutzt werden, um interne Zustände zu überwachen.

## Developer Mode (`-dev`)
Wenn CC2 mit dem Startparameter `-dev` gestartet wird, werden zusätzliche Funktionen für Mod-Entwickler aktiviert:
*   **Hot-Reloading**: CC2 lädt lokale Lua-Skripte bei jeder Änderung neu. Dies ermöglicht schnelles Iterieren ohne Neustart.
*   **Warnung**: Das Bearbeiten von Game-Object-XML-Dateien im laufenden Betrieb kann zum Absturz führen.

## Debug-Ausgabe anzeigen
Standardmäßig sind `print()`-Ausgaben im Spiel nicht sichtbar. Die einfachste Methode, sie zu sehen, ist die Nutzung einer Konsole wie **Git Bash**.

### Git Bash Einrichtung
1.  [Git for Windows](https://gitforwindows.org/) installieren.
2.  Im Explorer zum Steam-Ordner navigieren: `Steam\steamapps\common\Carrier Command 2`.
3.  Rechtsklick im Ordner -> **Git Bash Here**.
4.  CC2 im Dev-Modus starten:
    ```bash
    $ ./carrier_command.exe -dev
    ```
5.  Nun werden alle `print()`-Ausgaben in Echtzeit in der Konsole angezeigt.

## Formatierung von Ausgaben
Für komplexe Datenstrukturen sollte `string.format()` verwendet werden:
```lua
print(string.format("heading = %d", math.floor(heading_degrees)))
-- Ausgabe: heading = 74
```

## Fehler abfangen mit `pcall()`
Um zu verhindern, dass ein Lua-Fehler das gesamte Skript lautlos abbricht oder den Bildschirm einfriert, sollte `pcall()` (Protected Call) verwendet werden:

```lua
status, err = pcall(function() 
    print("hello") 
    x = 10 / 0 
    print(string.format("x = %d", x)) 
end) 

if not status then 
    print(string.format("error - %s", err)) 
end
```
Dies gibt im Fehlerfall eine detaillierte Meldung aus, anstatt das Skript abstürzen zu lassen.
