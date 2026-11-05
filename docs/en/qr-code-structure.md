# QR Code Structure

## Overview

A QR Code (Quick Response Code) does not consist solely of user data. A significant portion of the matrix is reserved for structural, control, and error correction information.

These elements allow scanners to:

- detect the QR code
- determine its orientation
- compensate for distortion
- reconstruct damaged data
- decode the payload reliably

As QR Code versions increase, both data capacity and the number of structural elements grow.

Understanding these components is essential when designing QR Codes with embedded logos or custom graphics.

---

# Finder Patterns

## Purpose

Finder Patterns are responsible for the initial detection of a QR Code.

They allow scanners to determine:

- the presence of a QR Code
- orientation
- rotation
- module size
- overall grid alignment

Without functioning Finder Patterns, most scanners cannot even recognize the symbol as a QR Code.

---

## Location

Every QR Code contains exactly three Finder Patterns:

```text
┌─────┐             ┌─────┐
│     │             │     │
│     │             │     │
└─────┘             └─────┘


┌─────┐
│     │
│     │
└─────┘
```

Located at:

- top-left
- top-right
- bottom-left

---

## Criticality

★★★★★ Critical

Finder Patterns must never be modified or covered by a logo.

---

# Separators

## Purpose

Separators create a white buffer zone around each Finder Pattern.

They ensure that nearby data modules do not interfere with Finder Pattern detection.

---

## Location

Directly surrounding each Finder Pattern.

```text
███████□
███████□
███████□
□□□□□□□
```

The white modules represent the separator area.

---

## Criticality

★★★★★ Critical

Separators must never be modified or covered.

---

# Timing Patterns

## Purpose

Timing Patterns define the QR Code grid.

They enable scanners to determine:

- exact module positions
- module dimensions
- matrix alignment

---

## Appearance

Typical pattern:

```text
1010101010101010
```

or visually:

```text
█ □ █ □ █ □ █ □
```

---

## Location

Two Timing Patterns exist:

### Horizontal Timing Pattern

Between the upper Finder Patterns.

### Vertical Timing Pattern

Between the left Finder Patterns.

---

## Criticality

★★★★★ Critical

Timing Patterns must never be modified.

---

# Dark Module

## Purpose

The Dark Module is a permanently fixed black module defined by the QR Code specification.

It serves as an additional reference point during decoding.

---

## Location

Its position depends on the QR Code version.

Typically:

```text
row = (4 × Version) + 9
column = 8
```

---

## Criticality

★★★★★ Critical

The Dark Module must never be modified.

---

# Format Information

## Purpose

Format Information stores:

- Error Correction Level (ECC)
- Mask Pattern Identifier

Without this information, the scanner cannot correctly interpret the encoded data.

---

## Contents

### Error Correction Level

- L
- M
- Q
- H

### Mask Pattern

- Mask 0
- Mask 1
- Mask 2
- Mask 3
- Mask 4
- Mask 5
- Mask 6
- Mask 7

---

## Storage

Format Information is stored redundantly in multiple locations near the Finder Patterns.

---

## Criticality

★★★★★ Critical

Format Information must never be modified.

---

# Version Information

## Purpose

Version Information stores the QR Code version number.

---

## Availability

Only present in:

```text
Version 7 and above
```

Versions 1 through 6 do not contain Version Information.

---

## Storage

Stored redundantly in two locations:

- near the upper-right Finder Pattern
- near the lower-left Finder Pattern

---

## Criticality

★★★★★ Critical

Version Information must never be modified.

---

# Alignment Patterns

## Purpose

Alignment Patterns compensate for geometric distortion.

They improve decoding reliability for:

- large QR Codes
- skewed camera angles
- perspective distortion
- curved surfaces
- print imperfections

---

## Appearance

An Alignment Pattern resembles a miniature Finder Pattern:

```text
□□□□□
□███□
□█▄█□
□███□
□□□□□
```

---

## Availability

Version 1 contains no Alignment Patterns.

Alignment Patterns begin appearing in Version 2 and increase in number as the QR Code version grows.

---

## Examples

### Version 2

```text
Single Alignment Pattern
```

### Version 7

```text
Multiple Alignment Patterns
```

### Version 20

```text
Alignment Pattern grid
```

### Version 40

```text
Large number of Alignment Patterns distributed throughout the matrix
```

---

## Criticality

★★★☆☆ Important

Alignment Patterns significantly improve decoding robustness.

However, unlike Finder Patterns, they are not primarily responsible for QR Code detection.

Many modern scanners remain capable of decoding a QR Code even when one or more Alignment Patterns are partially covered.

---

## Observations from the T-SQL QR Code Generator Project

Practical tests have shown that:

- Alignment Patterns can sometimes be partially covered by a logo.
- Modern QR readers frequently remain capable of decoding the symbol.
- Error correction further increases tolerance to such modifications.

This is particularly true when using Error Correction Level H.

---

## Logo Placement Rules

### STRICT Mode

Alignment Patterns are protected.

```text
Logo placement is not allowed to overlap Alignment Patterns.
```

---

### RELAXED Mode

Alignment Patterns may be covered.

```text
Logo placement may overlap Alignment Patterns.
```

All critical QR structures remain protected.

---

# Data Modules

## Purpose

Data Modules contain the actual user payload.

Typical examples include:

- URLs
- text
- contact cards
- Wi-Fi credentials
- configuration data
- binary content

---

## Special Considerations

Data Modules are protected by Reed-Solomon error correction.

As a result, portions of the encoded data can be lost while remaining recoverable.

---

## Criticality

★☆☆☆☆ Low

Data Modules may be replaced by logos or graphics as long as error correction capacity is not exceeded.

---

# Error Correction (ECC)

## Background

QR Codes use Reed-Solomon error correction.

This allows damaged modules to be reconstructed during decoding.

---

## ECC Level L

```text
Approximately 7%
```

Lowest protection.

Maximum data capacity.

---

## ECC Level M

```text
Approximately 15%
```

Standard QR Code protection level.

---

## ECC Level Q

```text
Approximately 25%
```

Increased protection.

Well suited for branded QR Codes.

---

## ECC Level H

```text
Approximately 30%
```

Maximum protection.

Recommended for QR Codes containing logos.

---

# Module Protection Modes in the T-SQL QR Code Generator

## STRICT Mode

Protected modules:

- Finder Patterns
- Separators
- Timing Patterns
- Dark Module
- Format Information
- Version Information
- Alignment Patterns

Logo placement is restricted to data modules only.

---

## RELAXED Mode

Protected modules:

- Finder Patterns
- Separators
- Timing Patterns
- Dark Module
- Format Information
- Version Information

Logo placement may additionally overlap:

- Alignment Patterns
- Data Modules

---

# Logo Placement Recommendations

## Small Logos

Recommended ECC level:

```text
M or Q
```

---

## Medium Logos

Recommended ECC level:

```text
Q
```

---

## Large Logos

Recommended ECC level:

```text
H
```

Using RELAXED Mode is recommended to take advantage of additional logo area available in higher QR Code versions.

---

# Summary

| Element | Criticality | May Be Covered By Logo |
|----------|----------|----------|
| Finder Pattern | ★★★★★ | No |
| Separator | ★★★★★ | No |
| Timing Pattern | ★★★★★ | No |
| Dark Module | ★★★★★ | No |
| Format Information | ★★★★★ | No |
| Version Information | ★★★★★ | No |
| Alignment Pattern | ★★★☆☆ | Optional |
| Data Modules | ★☆☆☆☆ | Yes |

The most practical strategy for logo-enabled QR Codes is to permanently protect only truly critical structures while making Alignment Pattern protection configurable. This allows logo size to scale with QR Code version without unnecessarily reducing readability for modern QR scanners.