# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-11-06

### Added

- Complete QR Code generation engine
- Reed-Solomon error correction support
- SVG renderer
- QR matrix comparison utilities
- Regression test framework

### Documentation

- Coding Standards
- Validation Against Nayuki
- QR Code Parameter Guide

### Validation

- Matrix output validated against reference implementation by Nayuki
- Scanability verified
- 
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

## v0.3

### Added

- Introduced configuration table [QR].[Configuration].
- Added configurable Alignment Pattern protection.
- Added STRICT and RELAXED logo placement modes.
- Added technical documentation:
  - docs/qr-code-structure.md

### Changed

- Logo area calculation no longer requires Alignment Pattern protection.
- Largest logo area can now expand across Alignment Patterns when configured.

## [Unreleased]

### Fixed

#### QR Code Generation

Fixed version-information placement for QR versions 7 and higher.

The version-information bits were previously written using an incorrect coordinate mapping, resulting in non-decodable QR codes despite otherwise correct payload, ECC and masking.

The implementation now follows the bit-placement behavior of the Nayuki QR Code Generator reference implementation.

#### Reed-Solomon Initialization

Improved robustness of QR generation by ensuring required lookup structures are initialized before ECC generation:

- GaloisLog
- GaloisExp
- GeneratorPolynomial