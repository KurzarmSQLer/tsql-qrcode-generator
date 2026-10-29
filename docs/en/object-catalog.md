# Object Catalog

This document provides an overview of all database objects
contained in the T-SQL QR Code Generator.

Detailed technical descriptions will gradually be added to
the object headers inside the source code.

---

# Tables

## QR.Module

Status: Stable

Purpose:

Stores the QR matrix and all module information.

Examples:

- Data modules
- Finder patterns
- Timing patterns
- Alignment patterns
- Format information
- Logo colors

---

## QR.DataCodeword

Status: Stable

Purpose:

Stores generated data codewords before block distribution.

---

## QR.DataBlock

Status: Stable

Purpose:

Stores QR data codewords distributed across QR blocks.

---

## QR.EccBlock

Status: Stable

Purpose:

Stores Reed-Solomon error correction codewords.

---

## QR.InterleavedCodeword

Status: Stable

Purpose:

Stores interleaved data and ECC codewords.

---

## QR.GeneratedSvg

Status: Stable

Purpose:

Stores generated SVG output together with metadata.

---

## QR.LogoPattern

Status: Stable

Purpose:

Stores logo source pixels.

---

## QR.LogoPlacement

Status: Stable

Purpose:

Stores projected logo positions within the QR matrix.

---

## QR.LogoArea

Status: Stable

Purpose:

Stores detected logo placement areas.

---

## QR.VersionCapacity

Status: Stable

Purpose:

Stores QR capacities per version and ECC level.

---

## QR.VersionBlockStructure

Status: Stable

Purpose:

Stores QR block definitions per version and ECC level.

---

## QR.VersionDefinition

Status: Stable

Purpose:

Stores QR version metadata.

---

## QR.VersionRemainderBits

Status: Stable

Purpose:

Stores the number of remainder bits per QR version.

---

## QR.AlignmentPatternPosition

Status: Stable

Purpose:

Stores alignment pattern coordinates.

---

## QR.GaloisLog

Status: Stable

Purpose:

Lookup table for Galois field logarithms.

---

## QR.GaloisExp

Status: Stable

Purpose:

Lookup table for Galois field exponents.

---

## QR.GeneratorPolynomial

Status: Stable

Purpose:

Stores Reed-Solomon generator polynomials.

---

# Views

## QR.vLogoCandidates

Status: Stable

Purpose:

Exposes potential logo placement candidates.

---

## QR.vGeneratedSvgHistory

Status: Stable

Purpose:

Provides an extended view on stored SVG history.

---

# Functions

## Capacity Functions

### QR.fnGetMatrixSize

Returns QR matrix size for a given version.

### QR.fnGetDataCodewords

Returns the number of data codewords.

### QR.fnGetEccCodewords

Returns the number of ECC codewords.

---

## Binary Conversion Functions

### QR.fnByteToBinary

Converts a byte value into an 8-bit binary string.

### QR.fnBinaryByteToInt

Converts an 8-bit binary string into an integer value.

---

## Reed-Solomon Functions

### QR.fnGaloisMultiply

Performs multiplication inside GF(256).

---

## QR Specification Functions

### QR.fnGetFormatBits_V1

Generates QR format information bits.

### QR.fnPadDataBits_V1

Applies QR padding and pad codewords.

---

# Procedures

## Public API

### QR.pCreateQrCode

Creates a complete QR matrix.

### QR.pCreateColoredQrCode

Creates a complete QR code including logo projection
and SVG rendering.

---

## Matrix Construction

### QR.pInitializeMatrix

Creates an empty matrix.

### QR.pCreateBaseMatrix

Builds all fixed QR structures.

### QR.pSetFinderPattern

Places finder patterns.

### QR.pSetSeparator

Places separator areas.

### QR.pSetTimingPatterns

Places timing patterns.

### QR.pSetAlignmentPattern

Places a single alignment pattern.

### QR.pSetAlignmentPatterns

Places all required alignment patterns.

### QR.pSetDarkModule

Places the mandatory dark module.

### QR.pReserveFormatModules

Reserves format information modules.

### QR.pSetFormatInformation

Writes format information.

---

## Data Encoding

### QR.pCreateDataBitStream

Creates the QR data bit stream.

### QR.pCreateDataCodewords

Creates data codewords.

---

## Reed-Solomon Error Correction

### QR.pBuildDataBlocks

Creates QR data blocks.

### QR.pCreateEccForBlock

Creates ECC codewords for a block.

### QR.pCreateEccBlocks

Creates ECC codewords for all blocks.

### QR.pBuildGaloisTables

Builds Galois lookup tables.

---

## Interleaving

### QR.pInterleaveCodewords

Performs QR interleaving.

### QR.pCreateFinalBitStream

Creates the final QR bit stream.

---

## Data Placement

### QR.pPlaceDataBits

Places data bits into the matrix.

---

## Mask Selection

### QR.pApplyMask

Applies a QR mask.

### QR.pCalculateMaskPenalty

Calculates QR penalty scores.

### QR.pSelectBestMask

Chooses the best QR mask.

---

## Logo System

### QR.pDetermineLargestLogoArea

Finds the largest available logo area.

### QR.pProjectLogoPattern

Projects logo pixels into the QR matrix.

### QR.pApplyLogoColors

Applies logo color mappings.

### QR.pDeleteLogoPattern

Deletes stored logo patterns.

---

## SVG Rendering

### QR.pGenerateSvg

Generates SVG output.

---

# Object Statistics

The object catalog intentionally groups objects by
their architectural responsibility rather than by
their creation order.

This reflects the actual QR generation pipeline:

Matrix Creation
→ Encoding
→ ECC
→ Interleaving
→ Placement
→ Masking
→ Logo Projection
→ SVG Rendering
