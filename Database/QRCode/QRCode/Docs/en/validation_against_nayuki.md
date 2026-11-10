# Validation Against Nayuki Reference Implementation

## Purpose

This document describes the validation process used to verify the SQL Server QR Code implementation against the Nayuki QR Code Generator reference implementation.

Reference implementation:

- https://www.nayuki.io/page/qr-code-generator-library

The objective is to ensure that both implementations produce identical QR Code matrices for identical inputs.

---

# Validation Philosophy

QR codes should be validated layer by layer.

Never start by comparing final QR matrices.

Instead, validate each processing stage independently.

Validation order:

1. Data Bit Stream
2. Data Codewords
3. Reed-Solomon Error Correction Codewords
4. Block Structure
5. Interleaving
6. Final Codeword Stream
7. Bit Placement
8. Function Modules
9. Masking
10. Format Information
11. Version Information
12. Final Matrix

This approach dramatically reduces debugging complexity.

---

# Reference Test Case

Unless otherwise specified, validation should use the following baseline testcase:

| Property | Value |
|-----------|-----------|
| Payload | HELLO WORLD |
| Version | 7 |
| ECC Level | L |
| Mask | 2 |
| Mode | Byte Mode |

This testcase was used during the initial validation and debugging process.

---

# Step 1: Validate Data Bit Stream

## SQL Export

```sql
SELECT
      [Position]
    , [Value]
FROM [QR].[DataCodeword]
ORDER BY [Position];
```

## Nayuki Export

Export the payload codewords immediately after:

```python
# Create data codewords
```

and before:

```python
_add_ecc_and_interleave()
```

Expected result:

```text
SQL Data Codewords
=
Nayuki Data Codewords
```

---

# Step 2: Validate Reed-Solomon ECC

## SQL Export

```sql
SELECT
      [BlockNumber]
    , [Position]
    , [Value]
FROM [QR].[EccBlock]
ORDER BY
      [BlockNumber]
    , [Position];
```

## Nayuki Reference

Compare with the output generated inside:

```python
_add_ecc_and_interleave()
```

before interleaving is performed.

Expected result:

```text
ECC blocks identical
```

---

# Step 3: Validate Block Structure

## SQL Validation

```sql
SELECT
      [GroupNumber]
    , [BlockCount]
    , [DataCodewordsPerBlock]
FROM [QR].[VersionBlockStructure]
WHERE [VersionNumber] = 7
  AND [ErrorCorrectionLevel] = 'L';
```

Expected result:

```text
Group 1
BlockCount = 2
DataCodewordsPerBlock = 78
```

Verification must match the Nayuki implementation.

---

# Step 4: Validate Interleaving

## SQL Export

```sql
SELECT
      [Position]
    , [Value]
FROM [QR].[InterleavedCodeword]
ORDER BY [Position];
```

## Nayuki Export

Export:

```python
result
```

from:

```python
_add_ecc_and_interleave()
```

immediately before:

```python
return result
```

Expected result:

```text
Identical codeword sequence
```

---

# Step 5: Validate Final Codeword Stream

## SQL Export

```sql
SELECT
      [Position]
    , [Value]
FROM [QR].[InterleavedCodeword]
ORDER BY [Position];
```

## Expected Result

Data codewords, ECC codewords and interleaving must be identical to Nayuki.

Any difference found here must be fixed before continuing.

---

# Step 6: Validate Bit Placement

## SQL Export

```sql
SELECT
      [BitPosition]
    , [X]
    , [Y]
FROM [QR].[DebugBitPlacement]
ORDER BY [BitPosition];
```

## Nayuki Reference

Compare against the traversal logic inside:

```python
_draw_codewords()
```

Expected result:

```text
BitPosition -> (X,Y)
```

must be identical.

---

# Step 7: Validate Function Module Reservation

Function modules include:

- Finder Patterns
- Timing Patterns
- Alignment Patterns
- Version Information
- Format Information

## Validation Goal

Ensure that every module classified as a function module in Nayuki is also classified as a function module in SQL.

Expected result:

```text
No discrepancies
```

---

# Step 8: Validate Format Information

Reference:

Version 7  
ECC Level L  
Mask Pattern 2

Expected format information:

```text
111110110101010
```

## SQL Check

```sql
SELECT
    [QR].[fnGetFormatBits_V1]
    (
          'L'
        , 2
    );
```

Expected result:

```text
111110110101010
```

---

# Step 9: Validate Version Information

Version information is required only for QR Version 7 and higher.

## Version 7 Expected Value

```text
000111110010010100
```

## SQL Check

```sql
SELECT
      [VersionBits]
FROM [QR].[VersionInformation]
WHERE [VersionNumber] = 7;
```

Expected result:

```text
000111110010010100
```

---

# Historical Defect: Version Information Mapping

## Symptom

The generated QR Code looked visually correct but could not be decoded.

## Investigation Result

Final codewords matched Nayuki exactly.

Difference analysis showed:

```text
DifferenceCount = 16
```

All differences were located inside the Version Information Areas.

Top-right:

```text
X = 34..36
Y = 0..5
```

Bottom-left:

```text
X = 0..5
Y = 34..36
```

## Root Cause

The SQL implementation mapped version-information bits to matrix coordinates using a column-major ordering.

The Nayuki implementation uses row-major ordering.

### Incorrect Mapping

```text
34,0
34,1
34,2
34,3
34,4
34,5

35,0
35,1
...
```

### Correct Nayuki Mapping

```text
34,0 35,0 36,0
34,1 35,1 36,1
34,2 35,2 36,2
34,3 35,3 36,3
34,4 35,4 36,4
34,5 35,5 36,5
```

## Resolution

The Version Information coordinate mapping was changed to match Nayuki.

Result:

```text
DifferenceCount = 0
```

Generated QR Codes became scannable.

---

# Step 10: Validate Final Matrix

## SQL Export

```sql
SELECT
      [X]
    , [Y]
    , CONVERT(TINYINT,[IsBlack]) AS [IsBlack]
FROM [QR].[Module]
ORDER BY
      [Y]
    , [X];
```

## Nayuki Export

```python
with open("nayuki_matrix.csv", "w") as f:
    f.write("X;Y;IsBlack\n")

    for y in range(qr.get_size()):
        for x in range(qr.get_size()):
            f.write(
                f"{x};{y};{1 if qr.get_module(x,y) else 0}\n"
            )
```

## Compare

```sql
SELECT
      COUNT(*) AS DifferenceCount
FROM SqlMatrix S
INNER JOIN NayukiMatrix N
    ON N.X = S.X
   AND N.Y = S.Y
WHERE S.IsBlack <> N.IsBlack;
```

Expected result:

```text
DifferenceCount = 0
```

---

# Common Failure Patterns

## Hundreds of Differences

Typically indicates:

- Bit placement error
- Masking error
- Interleaving error

---

## Differences Only in Format Areas

Typically indicates:

- Format bit generation issued- Wrong mask identifier
- Incorrect format information placement

---
## Differences Only in Version Areas

Typically indicates:

- Version information bit order issue
- Version information coordinate mapping issue

---

## Differences Everywhere After One Position

Typically indicates:

- Incorrect function-module reservation
- One incorrectly classified module causing a data-bit-shift

---

# Initialization Requirements

Before generating QR codes, ensure that all Reed-Solomon support structures exist.

Required lookup tables:

- QR.GaloisLog
- QR.GaloisExp

Required generator polynomials:

- QR.GeneratorPolynomial

Recommended startup validation:

```sql
IF NOT EXISTS (SELECT 1 FROM [QR].[GaloisLog])
   OR NOT EXISTS (SELECT 1 FROM [QR].[GaloisExp])
BEGIN
    EXEC [QR].[pBuildGaloisTables];
END;
```

and

```sql
DECLARE @EccCodewords INT;

SET @EccCodewords =
    [QR].[fnGetEccCodewords]
    (
          @VersionNumber
        , @ErrorCorrectionLevel
    );

IF NOT EXISTS
(
    SELECT 1
    FROM [QR].[GeneratorPolynomial]
    WHERE [EccCodewords] = @EccCodewords
)
BEGIN
    EXEC [QR].[pBuildGeneratorPolynomial]
         @EccCodewords = @EccCodewords;
END;
```

---

# Success Criteria

A QR implementation is considered validated when:

- Data codewords match Nayuki
- ECC codewords match Nayuki
- Interleaving matches Nayuki
- Bit placement matches Nayuki
- Function modules match Nayuki
- Final matrix comparison returns:

```text
DifferenceCount = 0
```

and the generated QR Code can be decoded successfully by standard QR scanners.



# Reproducible Matrix Comparison Workflow

This section describes a complete and repeatable process for comparing the SQL Server QR implementation against the Nayuki reference implementation.

The process calculates all matrix differences and pinpoints the exact coordinates of every mismatch.

---

# 1. Generate SQL Reference Matrix

Create the QR code in SQL Server:

```sql
EXEC [QR].[pCreateQrCode]
     @Text                 = 'HELLO WORLD',
     @VersionNumber        = 7,
     @ErrorCorrectionLevel = 'L';
```

Export the matrix:

```sql
SELECT
      [X]
    , [Y]
    , CONVERT(TINYINT,[IsBlack]) AS [IsBlack]
FROM [QR].[Module]
ORDER BY
      [Y]
    , [X];
```

Save as:

```text
sql_matrix.csv
```

Format:

```text
X;Y;IsBlack
0;0;1
1;0;1
...
```

---

# 2. Generate Nayuki Reference Matrix

Python script:

```python
from qrcodegen import QrCode
from qrcodegen import QrSegment

data = b"HELLO WORLD"

segs = [
    QrSegment.make_bytes(data)
]

qr = QrCode.encode_segments(
    segs,
    QrCode.Ecc.LOW,
    minversion=7,
    maxversion=7,
    mask=2,
    boostecl=False
)

with open(
    "nayuki_matrix.csv",
    "w",
    encoding="utf-8"
) as f:

    f.write("X;Y;IsBlack\n")

    for y in range(qr.get_size()):
        for x in range(qr.get_size()):
            f.write(
                f"{x};{y};{1 if qr.get_module(x, y) else 0}\n"
            )
```

Output:

```text
nayuki_matrix.csv
```

---

# 3. Import Both Matrices into SQL Server

Reference implementation:

```sql
CREATE TABLE #SqlMatrix
(
      X       INT NOT NULL
    , Y       INT NOT NULL
    , IsBlack BIT NOT NULL
);

CREATE TABLE #NayukiMatrix
(
      X       INT NOT NULL
    , Y       INT NOT NULL
    , IsBlack BIT NOT NULL
);
```

Import both CSV files using:

- BULK INSERT
- OPENROWSET(BULK...)
- SSMS Import Wizard

---

# 4. Calculate Difference Count

```sql
SELECT
    COUNT(*) AS DifferenceCount
FROM #SqlMatrix      AS S
INNER JOIN #NayukiMatrix AS N
    ON  N.X = S.X
    AND N.Y = S.Y
WHERE S.IsBlack <> N.IsBlack;
```

Expected result:

```text
DifferenceCount = 0
```

---

# 5. List Every Difference

```sql
SELECT
      S.X
    , S.Y
    , S.IsBlack AS SqlValue
    , N.IsBlack AS NayukiValue
FROM #SqlMatrix AS S
INNER JOIN #NayukiMatrix AS N
    ON  N.X = S.X
    AND N.Y = S.Y
WHERE S.IsBlack <> N.IsBlack
ORDER BY
      S.Y
    , S.X;
```

---

# 6. Locate the First Difference

```sql
SELECT TOP (1)
      S.X
    , S.Y
    , S.IsBlack AS SqlValue
    , N.IsBlack AS NayukiValue
FROM #SqlMatrix AS S
INNER JOIN #NayukiMatrix AS N
    ON  N.X = S.X
    AND N.Y = S.Y
WHERE S.IsBlack <> N.IsBlack
ORDER BY
      S.Y
    , S.X;
```

This query identifies the first mismatch in matrix order.

---

# 7. Classification of Differences

## Differences only inside format-information areas

Typical causes:

- format information generation
- mask identifier mismatch
- format bit placement

Affected areas:

```text
(8,0..5)
(8,7)
(8,8)
(7,8)
(5..0,8)

and mirrored copy
```

---

## Differences only inside version-information areas

Typical causes:

- version bit ordering
- version bit placement
- incorrect mapping between Bitindex and matrix coordinates

Affected areas (Version >= 7):

```text
top Right:
X = Size-11 .. Size-9
Y = 0 .. 5

Bottom Left:
X = 0 .. 5
Y = Size-11 .. Size-9
```

---

## Large Number of Differences

Typical causes:

- masking error
- data placement error
- interleaving error
- ECC generation error

---

# 8. Validation Success Criteria

The implementation is considered fully validated if:

```text
DifferenceCount = 0
```

and

```text
the generated QR code is successfully decoded
`*`

using at least one independent decoder:

- Smartphone Camera
- ZXing
- zxing.org Decoder
- QR Scanner App

The SQL implementation should then be considered functionally equivalent to the Nayuki reference implementation for the tested configuration.