# Public API

## Overview

The T-SQL QR Code Generator exposes a deliberately small public API.

Most procedures in the project are internal implementation details and may
change without notice.

Consumers of the project should only rely on the public entry points
documented below.

---

# Supported Entry Points

## [QR].[pCreateQrCode]

### Status

Stable

### API Level

Public

### Purpose

Creates a complete QR code matrix.

The procedure performs all QR generation steps required to construct a
standards-compliant QR code, including:

- Matrix initialization
- Fixed pattern placement
- Data encoding
- Reed-Solomon error correction
- Block interleaving
- Data placement
- Mask selection
- Format information generation

### Intended Usage

Use this procedure when:

- The QR matrix itself is required
- Internal QR structures shall be inspected
- Research and educational scenarios require access to intermediate data

### Output

The generated QR code is stored in:

- [QR].[Module]
- [QR].[DataCodeword]
- [QR].[DataBlock]
- [QR].[EccBlock]
- [QR].[InterleavedCodeword]

### Example

```sql
EXEC [QR].[pCreateQrCode]
      @Text                 = 'Hello World'
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M';
```

---

## [QR].[pCreateColoredQrCode]

### Status

Stable

### API Level

Public

### Purpose

Creates a complete QR code including logo projection and SVG rendering.

This procedure represents the primary entry point of the project.

In addition to the functionality provided by
[QR].[pCreateQrCode], the procedure also performs:

- Logo area detection
- Logo projection
- Logo color mapping
- SVG generation
- SVG persistence

### Intended Usage

Use this procedure when:

- A complete SVG shall be generated
- A logo shall be embedded into the QR code
- A presentation-ready QR code is required

### Output

The generated SVG is returned through:

```sql
@Svg OUTPUT
```

and is additionally persisted in:

```sql
[QR].[GeneratedSvg]
```

### Example

```sql
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'Hello Conference'
    , @LogoName             = 'TA'
    , @VersionNumber        = 6
    , @ErrorCorrectionLevel = 'H'
    , @ModuleSize           = 10
    , @QuietZone            = 4
    , @ForegroundColor      = '#000000'
    , @BackgroundColor      = '#FFFFFF'
    , @RoundDataModulesOnly = 0
    , @Svg                  = @Svg OUTPUT;
```

---

# Internal Procedures

All remaining procedures should be considered internal implementation details.

Examples:

- [QR].[pCreateDataBitStream]
- [QR].[pCreateDataCodewords]
- [QR].[pBuildDataBlocks]
- [QR].[pCreateEccBlocks]
- [QR].[pInterleaveCodewords]
- [QR].[pPlaceDataBits]
- [QR].[pApplyMask]
- [QR].[pSelectBestMask]
- [QR].[pProjectLogoPattern]
- [QR].[pGenerateSvg]

These procedures are documented and may be useful for learning purposes,
but they are not considered part of the supported public API.

Future versions may change their behavior, parameters, or implementation
without maintaining backward compatibility.

---

# Design Principle

The project follows the principle:

> Expose only a small public API and keep implementation details internal.

This approach allows the internal QR generation pipeline to evolve while
providing a stable interface for users, conference participants, and future
application integrations.

---

# Future Public APIs

Potential future public APIs may include:

- SVG export services
- PNG export services
- Azure-hosted web endpoints
- REST APIs
- .NET integration libraries

These interfaces are part of the long-term roadmap and are not available
in the current release.