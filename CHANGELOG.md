# Changelog

All notable changes to this project will be documented in this file.

---

# v0.2

## Added

### Documentation

- Architecture documentation
- Processing pipeline documentation
- Public API documentation
- Object catalog
- Project goals documentation
- Roadmap documentation
- Known issues documentation
- Logo import documentation

### Examples

- ExampleCalls.sql
- SVG example output
- PNG screenshots for repository presentation

### Logo Support

- ImportLogo.py utility
- PNG logo import workflow
- Transparent background support
- Color-preserving logo imports

### QR Specification Support

- Reservation of version-information modules for QR versions 7 and above
- Writing of BCH-protected version-information bits
- VersionInformation specification table

---

## Changed

### Documentation Quality

- Added standardized object headers to procedures
- Added standardized object headers to functions
- Added standardized object headers to tables
- Added standardized object headers to views

### Matrix Construction

- Extended matrix construction pipeline with version-information support
- Updated matrix-generation documentation

---

## Fixed

### QR Versions 7-10

Fixed incorrect remainder-bit validation for QR versions 7 through 10.

Root cause:

- Version-information areas defined by the QR specification were not reserved.
- This resulted in 36 falsely available data modules for QR versions 7 and above.

Resolution:

- Added reservation of version-information modules.
- Added placement of version-information bits.
- Corrected matrix construction for QR versions 7 and above.

---

## Validation

Successfully tested:

- QR Version 1
- QR Version 2
- QR Version 3
- QR Version 4
- QR Version 5
- QR Version 6
- QR Version 7
- QR Version 8
- QR Version 9
- QR Version 10

All tested versions generate valid QR matrices and SVG output.

---

# v0.1

## Initial Public Repository

First public release of the project.

### Features

- QR Code generation
- Reed-Solomon error correction
- Interleaving
- Automatic mask selection
- SVG generation
- Logo projection
- SVG persistence