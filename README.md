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

```text
src/
    Main SQL implementation

docs/
    Project documentation

examples/
    Example calls, SVG files and screenshots