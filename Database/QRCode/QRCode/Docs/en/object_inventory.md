# QR Code Project
# Object Inventory
# Version 1.0.0

## Purpose

This document contains a complete inventory of all database objects that belong to the QR Code project.

The inventory serves as the foundation for:

- Repository modernization
- SQL Database Project creation
- Deployment automation
- Dependency analysis
- Release management

---

# Summary

| Object Type | Count |
|-------------|------:|
| Tables | 27 |
| Views | 2 |
| Functions | 8 |
| Procedures | 39 |
| User Defined Types | 0 |
| Total | 76 |

---

# Tables

## Metadata

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[AlignmentPatternPosition] | Alignment pattern positions by QR version | Active |
| [QR].[Configuration] | Framework configuration settings | Active |
| [QR].[ErrorCorrectionLevel] | Error correction level definitions | Active |
| [QR].[VersionBlockStructure] | QR block structure definitions | Active |
| [QR].[VersionCapacity] | QR capacity reference data | Active |
| [QR].[VersionDefinition] | QR version definitions | Active |
| [QR].[VersionInformation] | Version information bit patterns | Active |
| [QR].[VersionRemainderBits] | Remainder bits per QR version | Active |

### Count

```text
8 Tables
```

---

## Reed-Solomon

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[ErrorCorrectionCodeword] | Error correction codewords | Active |
| [QR].[GeneratorPolynomial] | Generator polynomial definitions | Active |
| [QR].[GF256Exp] | GF(256) exponent lookup table | Review |
| [QR].[GF256Log] | GF(256) logarithm lookup table | Review |
| [QR].[GaloisExp] | GF(256) exponent lookup table | Review |
| [QR].[GaloisLog] | GF(256) logarithm lookup table | Review |

### Count

```text
6 Tables
```

---

## Generation

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[DataBlock] | Data block storage during generation | Active |
| [QR].[DataCodeword] | Generated data codewords | Active |
| [QR].[EccBlock] | ECC block storage | Active |
| [QR].[InterleavedCodeword] | Interleaved codewords | Active |
| [QR].[Module] | QR matrix module storage | Active |

### Count

```text
5 Tables
```

---

## Rendering

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[GeneratedSvg] | Generated SVG output storage | Active |
| [QR].[LogoArea] | Logo placement area definitions | Active |
| [QR].[LogoPattern] | Logo pattern templates | Active |
| [QR].[LogoPlacement] | Logo placement information | Active |

### Count

```text
4 Tables
```

---

## Testing

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[RegressionGoldenMatrix] | Reference QR matrices used for validation | Active |
| [QR].[RegressionTest] | Regression test definitions | Active |
| [QR].[RegressionTestResult] | Regression test execution results | Active |

### Count

```text
3 Tables
```

---

## Debug

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[DebugBitPlacement] | Bit placement diagnostics and troubleshooting | Review |

### Count

```text
1 Table
```

---

# Views

| Object Name | Category | Purpose | Status |
|-------------|----------|---------|--------|
| [QR].[vGeneratedSvgHistory] | Rendering | Historical access to generated SVG output | Active |
| [QR].[vLogoCandidates] | Logo Processing | Candidate selection for logo placement | Active |

---

# Functions

## Conversion

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[fnBinaryByteToInt] | Converts an 8-bit binary string to integer | Active |
| [QR].[fnByteToBinary] | Converts an integer value to an 8-bit binary string | Active |

---

## Reed-Solomon

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[fnGaloisMultiply] | Multiplication within GF(256) | Active |

---

## Capacity

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[fnGetDataCodewords] | Returns number of available data codewords | Active |
| [QR].[fnGetEccCodewords] | Returns number of ECC codewords | Active |

---

## Metadata

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[fnGetFormatBits_V1] | Returns format information bits | Active |
| [QR].[fnGetMatrixSize] | Calculates QR matrix dimensions | Active |

---

## Encoding

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[fnPadDataBits_V1] | Pads bit streams according to QR specification | Active |

---

# Procedures

## Core Generation Pipeline

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[pCreateQrCode] | Main QR code generation orchestration | Active |
| [QR].[pInitializeMatrix] | Creates initial matrix structure | Active |
| [QR].[pCreateBaseMatrix] | Builds base QR matrix | Active |
| [QR].[pSetFinderPattern] | Places finder patterns | Active |
| [QR].[pSetSeparator] | Places separators around finder patterns | Active |
| [QR].[pSetTimingPatterns] | Places timing patterns | Active |
| [QR].[pSetAlignmentPattern] | Places a single alignment pattern | Active |
| [QR].[pSetAlignmentPatterns] | Places all alignment patterns | Active |
| [QR].[pReserveFormatModules] | Reserves modules for format information | Active |
| [QR].[pReserveVersionModules] | Reserves modules for version information | Active |
| [QR].[pCreateDataBitStream] | Builds encoded bit stream | Active |
| [QR].[pCreateDataCodewords] | Creates data codewords | Active |
| [QR].[pBuildDataBlocks] | Builds QR data blocks | Active |
| [QR].[pCreateEccBlocks] | Creates ECC blocks | Active |
| [QR].[pCreateEccForBlock] | Generates ECC for a block | Active |
| [QR].[pInterleaveCodewords] | Interleaves data and ECC codewords | Active |
| [QR].[pCreateFinalBitStream] | Builds final bit stream | Active |
| [QR].[pPlaceDataBits] | Places payload bits into matrix | Active |
| [QR].[pApplyMask] | Applies QR mask pattern | Active |
| [QR].[pCalculateMaskPenalty] | Calculates mask penalty score | Active |
| [QR].[pSelectBestMask] | Selects optimal mask | Active |
| [QR].[pSetFormatInformation] | Writes format information | Active |
| [QR].[pSetVersionInformation] | Writes version information | Active |
| [QR].[pSetDarkModule] | Writes mandatory dark module | Active |

---

## Reed-Solomon Infrastructure

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[pBuildGaloisTables] | Creates GF(256) lookup tables | Active |
| [QR].[pBuildGeneratorPolynomial] | Creates generator polynomials | Active |
| [QR].[pCreateErrorCorrectionCodewords] | ECC generation infrastructure | Active |

---

## Rendering

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[pGenerateSvg] | Generates SVG output | Active |
| [QR].[pCreateColoredQrCode] | Generates colored QR codes | Active |

---

## Logo Processing

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[pCreateLogoKnockout] | Creates logo exclusion zone | Active |
| [QR].[pProjectLogoPattern] | Projects logo pattern into matrix | Active |
| [QR].[pApplyLogoColors] | Applies logo colors | Active |
| [QR].[pDetermineLargestLogoArea] | Calculates largest usable logo area | Active |
| [QR].[pDeleteLogoPattern] | Removes logo pattern definitions | Active |

---

## Testing & Validation

| Object Name | Purpose | Status |
|-------------|---------|--------|
| [QR].[pCompareMatrices] | Compares generated matrices with references | Active |
| [QR].[pValidateRegressionResult] | Validates regression results | Active |
| [QR].[pExportRegressionMatrix] | Exports regression reference matrices | Active |
| [QR].[pRunRegressionTest] | Executes an individual regression test | Active |
| [QR].[pRunRegressionSuite] | Executes complete regression suite | Active |

---

# User Defined Types

No user-defined types exist in Version 1.0.0.

---

# Repository Target Structure

```text
database/
│
├── Tables/
│   ├── Debug/
│   ├── Generation/
│   ├── Metadata/
│   ├── ReedSolomon/
│   ├── Rendering/
│   └── Testing/
│
├── Functions/
│   ├── Capacity/
│   ├── Conversion/
│   ├── Encoding/
│   ├── Metadata/
│   └── ReedSolomon/
│
├── Procedures/
│   ├── Generation/
│   ├── Logo/
│   ├── ReedSolomon/
│   ├── Rendering/
│   └── Testing/
│
├── Views/
├── Types/
├── SeedData/
├── PreDeployment/
└── PostDeployment/
```

---

# Migration Status

| Area | Status |
|--------|--------|
| Tables Inventory | Complete |
| Views Inventory | Complete |
| Functions Inventory | Complete |
| Procedures Inventory | Complete |
| User Defined Types Inventory | Complete |
| Dependency Analysis | Pending |
| SQL Project Creation | Pending |
| Object Extraction | Pending |
| Build Validation | Pending |

---

# Notes

This inventory documents the complete object landscape of QR Code Project Version 1.0.0.

The inventory acts as the authoritative baseline for the Repository Modernization initiative (Version 1.0.1).

All future migration activities shall reference this document before object extraction and SQL Project creation begin.