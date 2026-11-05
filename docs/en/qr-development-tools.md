# QR Code Development Tools

## Overview

This document lists external tools that are useful when developing, debugging and validating QR Codes.

The tools listed here have proven valuable during the development of the T-SQL QR Code Generator project.

---

# QRazyBox

## Website

https://qrazybox.com/

## Purpose

QRazyBox is one of the most powerful QR Code analysis tools available.

Unlike common QR Code generators, QRazyBox exposes the internal QR matrix and visualizes structural elements.

## Useful Features

### Matrix Visualization

Displays the QR matrix module by module.

Useful for:

- verifying data placement
- verifying mask application
- identifying damaged areas
- comparing generated QR Codes

### Structure Analysis

Highlights QR structures such as:

- Finder Patterns
- Timing Patterns
- Alignment Patterns
- Format Information
- Version Information

This is extremely useful when validating a custom QR implementation.

### Error Correction Analysis

Allows investigation of damaged QR Codes and recovery behavior.

### Manual Editing

Modules can be edited manually.

Useful when testing robustness against damage or logo placement.

## Use Cases in This Project

### Version Information Debugging

During investigation of a Version 7 decoding issue, QRazyBox showed that:

- Finder areas matched a reference implementation
- Structural areas appeared correct
- Data regions differed significantly

This helped narrow the investigation from matrix construction to payload generation logic.

### Logo Placement Validation

Useful for visually inspecting whether a logo overlaps:

- Alignment Patterns
- Timing Patterns
- Format Information
- Version Information

---

# ZXing Decoder

## Website

https://zxing.org/w/decode.jspx

## Purpose

Reference QR decoder based on the ZXing project.

## Useful Features

- QR decoding
- Validation of generated QR Codes
- Cross-checking smartphone scan results

## Recommended Usage

Always test generated QR Codes here in addition to smartphone cameras.

---

# Nayuki QR Code Generator

## Website

https://www.nayuki.io/page/qr-code-generator-library

## Purpose

Reference implementation of the QR specification.

Useful for generating comparison matrices during debugging.

## Useful Features

- Deterministic QR generation
- Supports version pinning
- Supports fixed ECC levels
- Produces standards-compliant output

## Recommended Usage

When debugging:

```text
Version 7
ECC L
HELLO WORLD
```

generate the same QR Code in Nayuki and compare the resulting matrix against this project.

---

# QRCode Monkey

## Website

https://www.qrcode-monkey.com/

## Purpose

Popular QR Code generator with strong logo support.

## Useful Features

- Logo overlays
- Styling experiments
- Visual comparison

## Recommended Usage

Good for benchmarking user expectations for branded QR Codes.

---

# Smartphone Readers

The following readers have proven useful for real-world validation:

- iOS Camera
- Google Lens
- Microsoft Authenticator
- QR Scanner Plus
- Samsung Camera QR Scanner

Testing with multiple readers is recommended because decoder tolerance differs between implementations.

---

# Debugging Strategy

When a QR Code fails to decode:

1. Verify with multiple readers.
2. Verify with ZXing.
3. Inspect structure in QRazyBox.
4. Compare against a reference implementation (Nayuki).
5. Compare matrix contents, not SVG output.
6. Investigate the first point where the generated matrix diverges from the reference matrix.

This approach has proven significantly more effective than visual SVG comparison alone.