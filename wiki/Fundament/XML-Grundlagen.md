---
title: XML-Grundlagen für CC2-Modding
section: Fundament
status: Welle-1
game-version: 2026-03
---

# XML-Grundlagen

CC2-Mods basieren auf XML-Override-Dateien. Diese Seite erklärt die grundlegende Syntax.

---

## Grundstruktur einer XML-Mod-Datei

```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions>
  <definition
    name="mein_objekt"
    type="missile">

    <!-- Parameter hier -->
    <body mass="5" drag="0.1" />

  </definition>
</definitions>
```

## Wichtige Parameter-Typen

| Typ | Beispiel | Bedeutung |
|:---|:---|:---|
| Float | `mass="5.0"` | Dezimalzahl |
| Integer | `barrel_count="2"` | Ganzzahl |
| Boolean | `enabled="true"` | true/false |
| String | `name="my_mod"` | Text |
| Vector | `offset="0 0 1"` | 3D-Koordinate (x y z) |

## Override-Prinzip

```
data/[mod_id]/definitions/[dateiname].xml
```

Nur die **veränderten Parameter** müssen angegeben werden — der Rest wird vom Vanilla-Wert übernommen.

> Weiterführend: [[Game-Referenz/XML-Referenz/Waffen-XML-Referenz]]
