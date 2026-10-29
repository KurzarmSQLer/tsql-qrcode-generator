# Logo-Import

## Überblick

Der QR-Code-Generator speichert Logos als Pixelmuster in der Tabelle

    [QR].[LogoPattern]

Der Import erfolgt über das Hilfsskript

    examples/ImportLogo.py

---

## Ablauf

PNG-Datei

↓

ImportLogo.py

↓

SQL-Skript

↓

[QR].[LogoPattern]

↓

[QR].[pProjectLogoPattern]

↓

SVG-Ausgabe

---

## Unterstützte Formate

Empfohlen:

- PNG
- Transparenter Hintergrund
- Quadratisches Seitenverhältnis

Beispiele:

- 64 x 64
- 128 x 128
- 256 x 256

Die Projektion in den QR-Code erfolgt automatisch.

---

## Transparente Pixel

Transparente Pixel werden nicht gespeichert.

Dadurch enthält die Tabelle nur tatsächlich sichtbare
Bildpunkte.

---

## Farbinformationen

Die ursprünglichen Farben werden übernommen und während
der SVG-Erzeugung wieder verwendet.

---

## Empfehlungen

- Hoher Kontrast
- Transparente Hintergründe
- Möglichst quadratische Logos
- Scanbarkeit mit einem Smartphone testen
- Bei größeren Logos Fehlerkorrekturlevel H verwenden