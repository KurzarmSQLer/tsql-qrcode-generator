# QR Code Project
# Dependency Analysis
# Version 1.0.0

## Purpose

This document describes the dependency structure of the QR Code framework.

It serves as the foundation for:

- Repository modernization (v1.0.1)
- SQL Database Project creation
- Deployment ordering
- Build validation
- Impact analysis
- Future refactoring activities

---

# Overview

The QR Code project consists of 76 database objects organized into several logical layers.

```text
Metadata
    ↓
Functions
    ↓
Core QR Generation
    ↓
Rendering
    ↓
Logo Processing
    ↓
Testing & Validation
```

The architecture follows a largely hierarchical design with a single primary entry point:

```text
[QR].[pCreateQrCode]
```

---

# Primary Generation Pipeline

The main QR generation process is orchestrated by:

```text
[QR].[pCreateQrCode]
```

Dependency graph:

```text
pCreateQrCode
│
├─ pBuildGaloisTables
├─ pBuildGeneratorPolynomial
│
├─ pCreateBaseMatrix
│   │
│   ├─ pInitializeMatrix
│   ├─ pSetFinderPattern
│   ├─ pSetSeparator
│   ├─ pSetTimingPatterns
│   ├─ pSetAlignmentPatterns
│   │   └─ pSetAlignmentPattern
│   ├─ pReserveFormatModules
│   ├─ pReserveVersionModules
│   └─ pSetDarkModule
│
├─ pCreateDataBitStream
├─ pCreateDataCodewords
├─ pBuildDataBlocks
│
├─ pCreateEccBlocks
│   └─ pCreateEccForBlock
│
├─ pInterleaveCodewords
├─ pCreateFinalBitStream
│
├─ pPlaceDataBits
│
├─ pSelectBestMask
│   ├─ pApplyMask
│   ├─ pCalculateMaskPenalty
│   └─ pSetFormatInformation
│
└─ pSetVersionInformation
```

---

# Core Processing Layers

## Layer 1: Metadata

This layer provides the static configuration data required by the QR standard.

### Objects

```text
AlignmentPatternPosition
Configuration
ErrorCorrectionLevel
VersionBlockStructure
VersionCapacity
VersionDefinition
VersionInformation
VersionRemainderBits
```

Responsibilities:

- QR version definitions
- Capacity lookup
- Alignment pattern locations
- Block structures
- Version information bits

---

## Layer 2: Reed-Solomon Infrastructure

This layer provides Galois Field arithmetic and generator polynomials.

### Tables

```text
GaloisExp
GaloisLog
GeneratorPolynomial
ErrorCorrectionCodeword
```

### Functions

```text
fnGaloisMultiply
```

### Procedures

```text
pBuildGaloisTables
pBuildGeneratorPolynomial
```

Responsibilities:

- GF(256) arithmetic
- Generator polynomial creation
- Error correction support

---

## Layer 3: Encoding

Responsible for converting input text into QR payload bits.

### Functions

```text
fnGetDataCodewords
fnGetEccCodewords
fnPadDataBits_V1
fnBinaryByteToInt
fnByteToBinary
```

### Procedures

```text
pCreateDataBitStream
pCreateDataCodewords
```

Responsibilities:

- Bit stream generation
- Padding
- Capacity calculations
- Codeword generation

---

## Layer 4: Matrix Construction

Responsible for creating the physical QR matrix.

### Procedures

```text
pInitializeMatrix
pCreateBaseMatrix

pSetFinderPattern
pSetSeparator
pSetTimingPatterns

pSetAlignmentPattern
pSetAlignmentPatterns

pReserveFormatModules
pReserveVersionModules

pSetDarkModule
```

Primary storage:

```text
Module
```

Responsibilities:

- Matrix initialization
- Functional patterns
- Reserved areas
- QR infrastructure modules

---

## Layer 5: Error Correction

Responsible for Reed-Solomon error correction generation.

### Procedures

```text
pBuildDataBlocks
pCreateEccBlocks
pCreateEccForBlock
pInterleaveCodewords
```

Primary tables:

```text
DataBlock
DataCodeword
EccBlock
InterleavedCodeword
```

Responsibilities:

- Block generation
- ECC calculation
- Interleaving

---

## Layer 6: Payload Placement

Responsible for positioning payload bits within the matrix.

### Procedures

```text
pCreateFinalBitStream
pPlaceDataBits
```

Responsibilities:

- Final bit stream generation
- Zig-zag placement
- Remainder bit handling

---

## Layer 7: Mask Selection

Responsible for QR mask optimization.

### Procedures

```text
pApplyMask
pCalculateMaskPenalty
pSelectBestMask
```

Responsibilities:

- Mask application
- Penalty calculation
- Best mask selection

---

## Layer 8: Finalization

Responsible for writing QR metadata into the matrix.

### Procedures

```text
pSetFormatInformation
pSetVersionInformation
```

### Functions

```text
fnGetFormatBits_V1
fnGetMatrixSize
```

Responsibilities:

- Format information
- Version information
- Final QR compliance

---

# Rendering Layer

Rendering transforms a completed matrix into output artifacts.

### Procedures

```text
pGenerateSvg
pCreateColoredQrCode
```

### Tables

```text
GeneratedSvg
```

### Views

```text
vGeneratedSvgHistory
```

Responsibilities:

- SVG generation
- Colored QR rendering
- Output persistence

---

# Logo Processing Layer

Optional functionality for embedding logos.

### Procedures

```text
pCreateLogoKnockout
pProjectLogoPattern
pApplyLogoColors
pDetermineLargestLogoArea
pDeleteLogoPattern
```

### Tables

```text
LogoArea
LogoPattern
LogoPlacement
```

### Views

```text
vLogoCandidates
```

Responsibilities:

- Logo placement calculation
- Exclusion zones
- Logo rendering

---

# Testing and Validation Layer

Provides automated validation and regression testing.

### Tables

```text
RegressionTest
RegressionGoldenMatrix
RegressionTestResult
```

### Procedures

```text
pCompareMatrices
pValidateRegressionResult
pExportRegressionMatrix
pRunRegressionTest
pRunRegressionSuite
```

Responsibilities:

- Matrix comparison
- Golden matrix validation
- Automated regression testing

Regression execution chain:

```text
pRunRegressionSuite
    ↓
pRunRegressionTest
    ↓
pCreateQrCode
    ↓
pCompareMatrices
    ↓
pValidateRegressionResult
```

---

# High Dependency Objects

The following objects form the architectural core of the framework.

## Critical Entry Point

```text
[QR].[pCreateQrCode]
```

This procedure orchestrates the complete QR generation pipeline.

---

## Core Matrix Storage

```text
[QR].[Module]
```

Referenced by:

```text
pApplyLogoColors
pApplyMask
pCalculateMaskPenalty
pCompareMatrices
pCreateLogoKnockout
pDetermineLargestLogoArea
pExportRegressionMatrix
pGenerateSvg
pInitializeMatrix
pPlaceDataBits
pReserveFormatModules
pReserveVersionModules
pSelectBestMask
pSetAlignmentPattern
pSetDarkModule
pSetFinderPattern
pSetFormatInformation
pSetSeparator
pSetTimingPatterns
pSetVersionInformation
pValidateRegressionResult

vLogoCandidates
```

This is the most heavily referenced table in the project.

---

## Capacity Metadata

```text
[QR].[VersionCapacity]
```

Referenced by:

```text
fnGetDataCodewords
fnGetEccCodewords
```

Capacity management depends entirely on this table.

---

# Technical Debt Candidates

The following objects require review during repository modernization.

## GF256 Tables

```text
GF256Exp
GF256Log
```

Observation:

No active dependencies were detected during inventory analysis.

Action:

```text
Review usage before migration.
Retain until confirmed obsolete.
```

Risk:

```text
Potential duplicate implementation of:

GaloisExp
GaloisLog
```

---

## Debug Objects

```text
DebugBitPlacement
```

Observation:

Created during QR validation troubleshooting.

Action:

```text
Evaluate whether object remains
part of production deployment
or should move into testing/debugging.
```

---

# Recommended Deployment Order

## Phase 1

Metadata Tables

```text
AlignmentPatternPosition
Configuration
ErrorCorrectionLevel
VersionBlockStructure
VersionCapacity
VersionDefinition
VersionInformation
VersionRemainderBits
```

---

## Phase 2

Reed-Solomon Tables

```text
GaloisExp
GaloisLog
GeneratorPolynomial
ErrorCorrectionCodeword
```

---

## Phase 3

Runtime Tables

```text
DataCodeword
DataBlock
EccBlock
InterleavedCodeword
Module

GeneratedSvg

LogoArea
LogoPattern
LogoPlacement
```

---

## Phase 4

Testing Tables

```text
RegressionTest
RegressionGoldenMatrix
RegressionTestResult
```

---

## Phase 5

Views

```text
vGeneratedSvgHistory
vLogoCandidates
```

---

## Phase 6

Functions

```text
fnBinaryByteToInt
fnByteToBinary
fnGaloisMultiply
fnGetDataCodewords
fnGetEccCodewords
fnGetFormatBits_V1
fnGetMatrixSize
fnPadDataBits_V1
```

---

## Phase 7

Procedures

Deploy helper procedures before orchestrating procedures.

Final deployment order:

```text
Infrastructure
    ↓
Generation
    ↓
Rendering
    ↓
Logo
    ↓
Testing
    ↓
pCreateQrCode
```

---

# Modernization Recommendations

## Repository Layout

Recommended target structure:

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

# Conclusion

The QR Code Project Version 1.0.0 exhibits a well-structured layered architecture centered around a single orchestration procedure (`pCreateQrCode`).

The dependency analysis confirms that the project is suitable for migration from a monolithic SQL script to an object-oriented SQL Database Project structure with manageable risk.

Primary migration focus areas:

1. Object extraction
2. SQL Project creation
3. Deployment validation
4. Review of duplicate GF(256) lookup tables
5. Classification of debug objects

No major architectural blockers were identified during the dependency analysis.