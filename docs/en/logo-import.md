# Logo Import

## Overview

The QR generator stores logos as pixel patterns inside
the table:

    [QR].[LogoPattern]

A logo is imported from a PNG image with a transparent
background using the helper script:

    examples/ImportLogo.py

---

## Workflow

PNG Image

↓

ImportLogo.py

↓

Generated SQL Script

↓

[QR].[LogoPattern]

↓

[QR].[pProjectLogoPattern]

↓

SVG Output

---

## Design Goals

The logo import process follows these principles:

- No external image libraries inside SQL Server
- Fully reproducible imports
- Color preservation
- Transparent background support
- Resolution independence

---

## Supported Image Format

Recommended:

- PNG
- Transparent background
- Square aspect ratio

Examples:

- 64 x 64
- 128 x 128
- 256 x 256

The projection engine automatically scales the logo
to the detected logo area.

---

## Example

Input:

    TA_Logo.png

Output:

    TA_Logo.sql

The generated SQL script contains INSERT statements for:

    [QR].[LogoPattern]

The script can then be executed directly in SQL Server.

---

## Transparent Pixels

Transparent pixels are ignored.

Only visible pixels are imported into:

    [QR].[LogoPattern]

This significantly reduces storage requirements.

---

## Color Mapping

The importer stores the original RGB color information.

The QR generator later applies these colors during
logo projection and SVG rendering.

---

## Best Practices

- Use high-contrast logos.
- Use transparent backgrounds.
- Prefer square images.
- Test QR readability using a smartphone scanner.
- Use higher ECC levels when larger logos are projected.