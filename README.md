# T-SQL QR Code Generator

A QR Code Generator implemented entirely in Microsoft SQL Server T-SQL.

---

## Features

- QR Code Versions 1-10
- Reed-Solomon Error Correction
- Automatic Mask Selection
- SVG Generation
- Colorized Logo Support
- Logo Projection
- SVG Persistence

---

## Documentation

- docs/qr-code-structure.md
- docs/logoimport.md
- docs/known-issues.md
- CHANGELOG.md

---

## Example Output

### Basic QR Code

A minimal Version 1 QR code generated entirely in T-SQL.

![Basic QR Code](examples/screenshots/version1-basic.png)

---

### Logo Projection

Automatic logo area detection, logo projection and color mapping.

![Logo Projection](examples/screenshots/version6-logo.png)

---

### Conference Showcase

Higher QR versions, Reed-Solomon error correction, automatic mask selection,
logo projection and SVG rendering implemented entirely in T-SQL.

![Conference Showcase](examples/screenshots/version6-showcase.png)

---
## SVG Sources

The SVG files shown above are included in the repository:

- examples/svg/version1-basic.svg
- examples/svg/version6-logo.svg
- examples/svg/version6-showcase.svg

---

## Included Documentation

- Architecture
- Processing Pipeline
- Object Catalog
- Public API
- Project Goals
- Roadmap
- Example Calls

---

## Repository Structure

src/
    Main SQL implementation

docs/
    Project documentation

examples/
    Example calls, SVG files and screenshots

## Project Design Decisions

The T-SQL QR Code Generator intentionally protects all critical QR Code structures:

- Finder Patterns
- Separators
- Timing Patterns
- Dark Module
- Format Information
- Version Information

Alignment Pattern protection is configurable.

This design allows users to choose between:

- STRICT mode for maximum standards compliance
- RELAXED mode for larger logo placement areas

Practical testing has shown that many modern QR Code readers can successfully decode QR Codes with partially covered Alignment Patterns when sufficient error correction is used.

## Development Resources

See:

- docs/qr-code-structure.md
- docs/logo-placement-modes.md
- docs/qr-development-tools.md