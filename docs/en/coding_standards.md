# Coding Standards

## Purpose

This document defines the mandatory coding, documentation and quality standards for all database objects within the QR schema.

The objective is to ensure:

- Consistent code quality
- Maintainable object definitions
- Predictable deployments
- Efficient troubleshooting
- Reproducible validation results
- Long-term maintainability

These standards apply to:

- Tables
- Views
- Functions
- Procedures
- Test objects
- Helper structures
- Metadata tables

---

# General Principles

## Readability Over Cleverness

Code must be written for maintainers.

Prefer:

```sql
SET @DataCodewords =
    [QR].[fnGetDataCodewords]
    (
          @VersionNumber
        , @ErrorCorrectionLevel
    );
```

over:

```sql
SET @DataCodewords=[QR].[fnGetDataCodewords](@VersionNumber,@ErrorCorrectionLevel)
```

---

## Explicit Naming

Object names must clearly describe their purpose.

Examples:

```text
pCreateDataBitStream
pCreateDataCodewords
pPlaceDataBits
fnGetFormatBits_V1
```

Avoid:

```text
pCreateData
pSetInfo
fnGetBits
```

---

## Schema Qualification

All object references must be schema-qualified.

Correct:

```sql
SELECT *
FROM [QR].[Module];
```

Avoid:

```sql
SELECT *
FROM Module;
```

---

## Bracket Convention

All database object names shall be enclosed in square brackets.

Correct:

```sql
SELECT *
FROM [QR].[Module];

EXEC [QR].[pCreateQrCode];
```

Avoid:

```sql
SELECT *
FROM QR.Module;
```

---

# Documentation Standards

## Mandatory Rule

No database object may be committed without a complete header documentation block.

This requirement applies to:

- Tables
- Views
- Functions
- Procedures

---

## Standard Header Structure

Every object must begin with:

```sql
-- ##############################################################################
-- ### Object Type: [Schema].[ObjectName]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Description                                                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### Additional information                                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Metadata                                                               ###
-- ##############################################################################
```

---

# Table Documentation Standard

Example:

```sql
-- ##############################################################################
-- ### Table: [QR].[RegressionTest]                                           ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores predefined QR regression test cases.                            ###
-- ###                                                                        ###
-- ### Each row represents a reproducible validation scenario consisting of   ###
-- ### payload text, QR version and error correction level.                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
```

---

# Procedure Documentation Standard

Example:

```sql
-- ##############################################################################
-- ### Procedure: [QR].[pCreateQrCode]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates a QR matrix according to the QR specification.                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Public                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                        Text to be encoded                       ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        Error correction level                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
```

---

# Function Documentation Standard

Example:

```sql
-- ##############################################################################
-- ### Function: [QR].[fnGetFormatBits_V1]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates the QR format-information bit sequence.                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @MaskPattern                                                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Format-information bit string                                          ###
-- ##############################################################################
```

---

# Error Handling Standards

## Never Ignore Invalid States

Incorrect data must fail fast.

Use:

```sql
RAISERROR(...)
```

or

```sql
THROW ...
```

Do not silently continue.

---

## Validate Inputs

All procedures shall validate:

- NULL inputs
- Invalid ranges
- Unsupported values

Example:

```sql
IF @VersionNumber NOT BETWEEN 1 AND 40
BEGIN
    THROW 70000,
          'Invalid QR Version.',
          1;
END;
```

---

# Validation Standards

## Mandatory Validation

Each major processing step must validate its own result.

Example:

```sql
IF LEN(@FinalBitStream) <> @ExpectedBits
BEGIN
    ...
END;
```

---

## Sanity Checks

Use explicit validation checks whenever possible*)
```

```sql
LEN(...)
```

```sql
EXISTS(...)
```

---

# Regression Testing Standards

## Mandatory Requirement

Every bug fix must be accompanied by at least one regression-test scenario if feasible.

The objective is to prevent reintroduction of known defects.

---

## Regression Test Storage

Regression scenarios shall be stored in:

```sql
[QR].[RegressionTest]
```

Execution results shall be stored in:

```sql
[QR].[RegressionTestResult]
```

---

## Reference Validation

The SQL implementation shall be validated against:

```text
Nayuki QR Code Generator
```

Reference:

```text
https://www.nayuki.io/page/qr-code-generator-library
```

---

# Matrix Validation

Final validation is based on matrix comparison.

Expected result:

```text
DifferenceCount = 0
```

between:

```text
SQL Matrix
```

and

```text
Nayuki Matrix
```

---

# Initialization Requirements

The following lookup structures must exist before QR generation:

```text
QR.GaloisLog
QR.GaloisExp
QR.GeneratorPolynomial
```

Implementations shall verify availability before use.

---

# Change Management

## Changelog

Every user-visible or algorithmic change shall be documented in:

```text
CHANGELOG.md
```

---

## Root Cause Documentation

Each resolved defect shall include:

- Symptom
- Root Cause
- Resolution
- Validation Method

in a dedicated documentation file whenever the defect required significant investigation.

---

# Known Good Validation Process

Reference document:

```text
docs/Validation_Against_Nayuki.md
```

This document is considered the authoritative validation process for the QR implementation.

No substantial QR algorithm change should be merged without successful completion of the documented validation workflow.

---

# Commit Requirement

A change should only be committed when all of the following are true:

- Object documentation complete
- Code compiles
- Validation checks pass
- Regression suite passes
- Changelog updated if required

---

# Definition of Done

A QR-related change is considered complete when:

- Implementation finished
- Documentation finished
- Regression tests updated
- Validation against Nayuki completed
- Generated QR codes are successfully decoded by external scanners


# SQL Formatting Standards

## Purpose

The objective of these formatting rules is to improve:

- readability
- maintainability
- code reviews
- diff quality
- consistency across all QR schema objects

Formatting rules are mandatory for all:

- tables
- views
- functions
- procedures
- scripts
- migration files

---

# General Layout

## One Clause Per Line

Correct:

```sql
SELECT
      [X]
    , [Y]
    , [IsBlack]
FROM [QR].[Module]
WHERE [ModuleType] = 'Data'
ORDER BY
      [Y]
    , [X];
```

Avoid:

```sql
SELECT [X],[Y],[IsBlack]
FROM [QR].[Module]
WHERE [ModuleType]='Data'
ORDER BY [Y],[X];
```

---

## Uppercase SQL Keywords

SQL keywords shall be written in uppercase.

Correct:

```sql
SELECT
FROM
WHERE
GROUP BY
ORDER BY
INSERT
UPDATE
DELETE
EXEC
```

Avoid:

```sql
select
from
where
```

---

## Object Names in Brackets

All database object names must use square brackets.

Correct:

```sql
FROM [QR].[Module]
```

Avoid:

```sql
FROM QR.Module
```

---

# SELECT Formatting

## Leading Comma Style

Columns shall use leading commas.

Correct:

```sql
SELECT
      [X]
    , [Y]
    , [IsBlack]
    , [ModuleType]
FROM [QR].[Module];
```

Avoid:

```sql
SELECT
      [X],
      [Y],
      [IsBlack],
      [ModuleType]
FROM [QR].[Module];
```

Reason:

- Cleaner diffs
- Easier reordering
- Easier commenting

---

## ORDER BY Formatting

Correct:

```sql
ORDER BY
      [Y]
    , [X];
```

Avoid:

```sql
ORDER BY [Y], [X];
```

---

## GROUP BY Formatting

Correct:

```sql
GROUP BY
      [VersionNumber]
    , [ErrorCorrectionLevel];
```

---

# JOIN Formatting

Each join condition shall be placed on its own line.

Correct:

```sql
INNER JOIN [QR].[Module] AS [M]
    ON 1 = 1
        AND [M].[X] = [F].[X]
        AND [M].[Y] = [F].[Y]
```

Preferred QR-project style:

```sql
INNER JOIN [QR].[Module] AS [M]
    ON 1 = 1
        AND [M].[X] = [F].[X]
        AND [M].[Y] = [F].[Y]
```

---

# INSERT Formatting

Correct:

```sql
INSERT INTO [QR].[Module]
(
      [X]
    , [Y]
    , [IsBlack]
)
VALUES
(
      @X
    , @Y
    , @IsBlack
);
```

---

# UPDATE Formatting

Correct:

```sql
UPDATE [M]
SET
      [IsBlack]    = 1
    , [ModuleType] = 'Finder'
FROM [QR].[Module] AS [M]
WHERE [X] = 0;
```

---

# Variable Formatting

## One Declaration Per Logical Group

Correct:

```sql
DECLARE
      @VersionNumber        TINYINT
    , @ErrorCorrectionLevel CHAR(1)
    , @MaskPattern          TINYINT;
```

---

## Assignment Formatting

Correct:

```sql
SET @VersionBits =
    (
        SELECT [VersionBits]
        FROM [QR].[VersionInformation]
        WHERE [VersionNumber] = @VersionNumber
    );
```

or

```sql
SELECT
    @VersionBits = [VersionBits]
FROM [QR].[VersionInformation]
WHERE [VersionNumber] = @VersionNumber;
```

---

# Procedure Calls

Correct:

```sql
EXEC [QR].[pCreateQrCode]
     @Text                 = @Text
   , @VersionNumber        = @VersionNumber
   , @ErrorCorrectionLevel = @ErrorCorrectionLevel;
```

All named parameters shall be aligned.

---

# IF Formatting

Correct:

```sql
IF @VersionNumber < 7
BEGIN
    RETURN;
END;
```

Avoid:

```sql
IF @VersionNumber < 7 RETURN;
```

---

# BEGIN / END

Always use BEGIN/END blocks.

Correct:

```sql
IF @Success = 0
BEGIN
    THROW 70000,
          'Validation failed.',
          1;
END;
```

---

# Comments

## Block Comments

Use separator blocks for larger sections.

Correct:

```sql
-------------------------------------------------------------------------
-- Version Information
-------------------------------------------------------------------------
```

---

## Explain Why, Not What

Prefer:

```sql
-- Version information is required only for QR versions >= 7.
```

over:

```sql
-- Set VersionNumber variable.
```

---

# Aliases

Table aliases shall use brackets.

Correct:

```sql
FROM [QR].[Module] AS [M]
```

Avoid:

```sql
FROM [QR].[Module] M
```

---

# NULL Handling

Use explicit NULL checks.

Correct:

```sql
IF @VersionBits IS NULL
BEGIN
    ...
END;
```

Never use:

```sql
IF @VersionBits = NULL
```

---

# Validation Queries

Prefer explicit validation counts.

Correct:

```sql
SELECT
    COUNT(*) AS [DifferenceCount]
FROM [#SqlMatrix]      AS [S]
INNER JOIN [#NayukiMatrix] AS [N]
    ON  N.[X] = [S].[X]
    AND N.[Y] = [S].[Y]
WHERE [S].[IsBlack] <> [N].[IsBlack];
```

---

# Line Length

Target:

```next
<= 120 characters
```

Long expressio*s should be wrapped across multiple lines.

---

# Definition*of Formatted SQL

A SQL object is considered properly formatted only when:

- header documentation exists
- SQL keywords are uppercase
- leading-comma style is used
- object names use brackets
- joins are vertically aligned
- BEGIN/END blocks a*e explicit
- named procedure param*ters are aligned
- comments explain intent and rationale