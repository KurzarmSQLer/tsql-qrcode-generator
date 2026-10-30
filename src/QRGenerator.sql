-- ##############################################################################
-- ### Project: T-SQL QR Code Generator                                       ###
-- ### Author:  Torsten Ahlemeyer                                             ###
-- ##############################################################################
-- ### Do you want to learn how professional QR codes are structured? Can     ###
-- ### special characters be encoded this way? Can I really integrate my      ###
-- ### company’s colored logo into the QR code without reducing my            ###
-- ### smartphone’s recognition rate for that QR code? What percentage of the ###
-- ### code can a coffee stain theoretically cover without affecting its      ###
-- ### functionality? Do all pixels really have to be square? How do you      ###
-- ### create scalable graphics using pure T-SQL?                             ###
-- ### ---------------------------------------------------------------------- ###
-- ### GitHub:      KurzarmSQLer                                              ###
-- ### Repository:  tsql-qrcode-generator                                     ###
-- ### License:     T-SQL QR Code Generator Educational License 1.0           ###
-- ### Copyright:   (c) 2026 Torsten Ahlemeyer                                ###
-- ##############################################################################
USE [Kopfnuesse]
GO

IF SCHEMA_ID(N'QR') IS NULL
    EXEC(N'CREATE SCHEMA [QR]');
GO

-- ##############################################################################
-- ### Table: [QR].[DataCodeword]                                             ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores QR data codewords generated from the encoded payload bit        ###
-- ### stream before distribution into Reed-Solomon blocks.                   ###
-- ###                                                                        ###
-- ### Each record represents a single 8-bit data codeword.                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[DataCodeword];
GO

CREATE TABLE [QR].[DataCodeword]
(
      [Position]        INTEGER     NOT NULL
    , [Value]           TINYINT     NOT NULL
    CONSTRAINT [PK_QR_DataCodeword]
        PRIMARY KEY ([Position])
);
GO

-- ##############################################################################
-- ### Table: [QR].[GeneratedSvg]                                             ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores generated SVG documents together with metadata, hashes and      ###
-- ### historical information useful for testing and analysis.                ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
IF OBJECT_ID('QR.GeneratedSvg') IS NULL
BEGIN
    CREATE TABLE [QR].[GeneratedSvg]
    (
          [SvgID]                   BIGINT          IDENTITY(1,1)
        , [CreatedAt]               DATETIME2(0)                    NOT NULL
        , [VersionNumber]           TINYINT                         NULL
        , [SvgContent]              NVARCHAR(MAX)                   NOT NULL
        , [TextEncoded]             VARCHAR(255)                    NULL
        , [LogoName]                VARCHAR(50)                     NULL
        , [ErrorCorrectionLevel]    CHAR(1)                         NULL
        , [SvgLength]               INTEGER                         NULL
        , [SvgHash]                 VARBINARY(32)                   NULL
        , [TextLength]              INTEGER                         NULL
        , [InputHash]               VARBINARY(32)                   NULL
        CONSTRAINT [PK_QR_GeneratedSvg]
                PRIMARY KEY ([SvgID])
        );
END;
GO

-- ##############################################################################
-- ### Table: [QR].[InterleavedCodeword]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores data and ECC codewords after QR interleaving.                   ###
-- ###                                                                        ###
-- ### The resulting sequence is used to construct the final QR bit stream.   ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[InterleavedCodeword];
GO

CREATE TABLE [QR].[InterleavedCodeword]
(
      [Position]    INTEGER     NOT NULL
    , [Value]       INTEGER     NOT NULL
    CONSTRAINT [PK_QR_InterleavedCodeword]
        PRIMARY KEY ([Position])
);
GO

-- ##############################################################################
-- ### Table: [QR].[DataBlock]                                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores data codewords distributed into QR specification data blocks.   ###
-- ###                                                                        ###
-- ### The block structure depends on QR version and error correction level.  ###
-- ### These blocks serve as input for Reed-Solomon ECC generation.           ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[DataBlock];
GO

CREATE TABLE [QR].[DataBlock]
(
      [BlockNumber]     INTEGER     NOT NULL
    , [Position]        INTEGER     NOT NULL
    , [Value]           INTEGER     NOT NULL
    PRIMARY KEY
    (
        [BlockNumber],
        [Position]
    )
);

-- ##############################################################################
-- ### Table: [QR].[EccBlock]                                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores Reed-Solomon error correction codewords generated for each      ###
-- ### QR data block.                                                         ###
-- ###                                                                        ###
-- ### The contents of this table are later interleaved with data codewords   ###
-- ### before placement into the QR matrix.                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[EccBlock];
GO

CREATE TABLE [QR].[EccBlock]
(
      [BlockNumber]     INTEGER     NOT NULL
    , [Position]        INTEGER     NOT NULL
    , [Value]           INTEGER     NOT NULL
    PRIMARY KEY
    (
        [BlockNumber],
        [Position]
    )
);

-- ##############################################################################
-- ### Table: [QR].[Module]                                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Central QR matrix. Stores all modules and their rendering metadata.    ###
-- ### The complete QR generation process operates on this table.             ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[Module];
GO

CREATE TABLE [QR].[Module]
(
    [X]             TINYINT         NOT NULL,
    [Y]             TINYINT         NOT NULL,
    [IsBlack]       BIT             NULL,
    [ModuleType]    VARCHAR(20)     NULL,
    [ColorHex]      CHAR(7)         NULL,
    CONSTRAINT [PK_QR_Module]       PRIMARY KEY ([Y], [X])
);
GO

-- ##############################################################################
-- ### Table: [QR].[LogoArea]                                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores candidate logo placement areas detected inside the QR matrix.   ###
-- ###                                                                        ###
-- ### The currently preferred area is identified by the name                 ###
-- ### 'LargestFreeRectangle'.                                                ###
-- ###                                                                        ###
-- ### The area information is used by logo projection and scaling.           ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
IF OBJECT_ID('QR.LogoArea') IS NULL
BEGIN
    CREATE TABLE [QR].[LogoArea]
    (
          [AreaName]    VARCHAR(50)     NOT NULL
        , [StartX]      TINYINT         NOT NULL
        , [StartY]      TINYINT         NOT NULL
        , [EndX]        TINYINT         NOT NULL
        , [EndY]        TINYINT         NOT NULL
        , [Width]       SMALLINT        NOT NULL
        , [Height]      SMALLINT        NOT NULL
        , [Area]        INTEGER         NOT NULL
        CONSTRAINT [PK_QR_LogoArea]
            PRIMARY KEY ([AreaName])
    )
END;
GO

-- ##############################################################################
-- ### Table: [QR].[GeneratorPolynomial]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores Reed-Solomon generator polynomials for the supported ECC        ###
-- ### lengths.                                                               ###
-- ###                                                                        ###
-- ### These coefficients are used during ECC generation to calculate         ###
-- ### QR error correction codewords.                                         ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
IF OBJECT_ID('QR.GeneratorPolynomial') IS NULL
BEGIN
    CREATE TABLE [QR].[GeneratorPolynomial]
    (
          [EccCodewords] INT NOT NULL
        , [Position]     INT NOT NULL
        , [Coefficient]  INT NOT NULL

        CONSTRAINT [PK_QR_GeneratorPolynomial]
            PRIMARY KEY
            (
                [EccCodewords],
                [Position]
            )
    )

    INSERT INTO QR.GeneratorPolynomial
    (
          EccCodewords
        , Position
        , Coefficient
    )
    VALUES
        --------------------------------------------------
        -- ECC = 10   (Level M)
        -------------------------------------------------- 
         ( 10,  0,  1)       ,( 10,  1,216)       ,( 10,  2,194)       ,( 10,  3,159)
        ,( 10,  4,111)       ,( 10,  5,199)       ,( 10,  6, 94)       ,( 10,  7, 95)
        ,( 10,  8,113)       ,( 10,  9,157)       ,( 10, 10,193)

        -------------------------------------------------- 
        -- ECC = 7   (Level L)
        --------------------------------------------------
        ,(  7,  0,   1)      ,(  7,  1, 127)      ,(  7,  2, 122)      ,(  7,  3, 154)
        ,(  7,  4, 164)      ,(  7,  5,  11)      ,(  7,  6,  68)      ,(  7,  7, 117)

        --------------------------------------------------
        -- ECC = 13  (Level Q)
        --------------------------------------------------
        ,( 13, 0,   1)       ,( 13,  1, 137)      ,( 13,  2,  73)      ,( 13, 3, 227)
        ,( 13, 4,  17)       ,( 13,  5, 177)      ,( 13,  6,  17)      ,( 13, 7,  52)
        ,( 13, 8,  13)       ,( 13,  9,  46)      ,( 13, 10,  43)      ,( 13,11,  83)
        ,( 13,12, 132)       ,( 13, 13, 120)

        --------------------------------------------------
        -- ECC = 17  (Level H)
        --------------------------------------------------
        ,( 17, 0,   1)       ,( 17, 1, 119)      ,( 17, 2,  66)        ,( 17, 3,  83)
        ,( 17, 4, 120)       ,( 17, 5, 119)      ,( 17, 6,  22)        ,( 17, 7, 197)
        ,( 17, 8,  83)       ,( 17, 9, 249)      ,( 17,10,  41)        ,( 17,11, 143)
        ,( 17,12, 134)       ,( 17,13,  85)      ,( 17,14,  53)        ,( 17,15, 125)
        ,( 17,16,  99)       ,( 17,17,  79)

        --------------------------------------------------
        -- ECC = 18 
        --------------------------------------------------
        ,( 18, 0,   1)       ,( 18, 1, 239)      ,( 18, 2, 251)        ,( 18, 3, 183)
        ,( 18, 4, 113)       ,( 18, 5, 149)      ,( 18, 6, 175)        ,( 18, 7, 199)
        ,( 18, 8, 215)       ,( 18, 9, 240)      ,( 18,10, 220)        ,( 18,11,  73)
        ,( 18,12,  82)       ,( 18,13, 173)      ,( 18,14,  75)        ,( 18,15,  32)
        ,( 18,16,  67)       ,( 18,17, 217)      ,( 18,18, 146)

        --------------------------------------------------
        -- ECC = 15
        --------------------------------------------------
        ,( 15,  0,  1)       ,( 15,  1, 29)      ,( 15,  2,196)        ,( 15,  3,111)
        ,( 15,  4,163)       ,( 15,  5,112)      ,( 15,  6, 74)        ,( 15,  7, 10)
        ,( 15,  8,105)       ,( 15,  9,105)      ,( 15, 10,139)        ,( 15, 11,132)
        ,( 15, 12,151)       ,( 15, 13, 32)      ,( 15, 14,134)        ,( 15, 15, 26)

        --------------------------------------------------
        -- ECC = 16
        --------------------------------------------------
        ,( 16,  0,  1)       ,( 16,  1, 59)      ,( 16,  2, 13)        ,( 16,  3,104)
        ,( 16,  4,189)       ,( 16,  5, 68)      ,( 16,  6,209)        ,( 16,  7, 30)
        ,( 16,  8,  8)       ,( 16,  9,163)      ,( 16, 10, 65)        ,( 16, 11, 41)
        ,( 16, 12,229)       ,( 16, 13, 98)      ,( 16, 14, 50)        ,( 16, 15, 36)
        ,( 16, 16, 59)

        --------------------------------------------------
        -- ECC = 20
        --------------------------------------------------
        ,( 20,  0,  1)       ,( 20,  1,152)      ,( 20,  2,185)        ,( 20,  3,240)
        ,( 20,  4,  5)       ,( 20,  5,111)      ,( 20,  6, 99)        ,( 20,  7,  6)
        ,( 20,  8,220)       ,( 20,  9,112)      ,( 20, 10,150)        ,( 20, 11, 69)
        ,( 20, 12, 36)       ,( 20, 13,187)      ,( 20, 14, 22)        ,( 20, 15,228)
        ,( 20, 16,198)       ,( 20, 17,121)      ,( 20, 18,121)        ,( 20, 19,165)
        ,( 20, 20,174)

        --------------------------------------------------
        -- ECC = 22
        --------------------------------------------------
        ,( 22,  0,  1)       ,( 22,  1, 89)      ,( 22,  2,179)        ,( 22,  3,131)
        ,( 22,  4,176)       ,( 22,  5,182)      ,( 22,  6,244)        ,( 22,  7, 19)
        ,( 22,  8,189)       ,( 22,  9, 69)      ,( 22, 10, 40)        ,( 22, 11, 28)
        ,( 22, 12,137)       ,( 22, 13, 29)      ,( 22, 14,123)        ,( 22, 15, 67)
        ,( 22, 16,253)       ,( 22, 17, 86)      ,( 22, 18,218)        ,( 22, 19,230)
        ,( 22, 20, 26)       ,( 22, 21,145)      ,( 22, 22,245)

        --------------------------------------------------
        -- ECC = 24
        --------------------------------------------------
        ,( 24,  0,  1)       ,( 24,  1,122)      ,( 24,  2,118)        ,( 24,  3,169)
        ,( 24,  4, 70)       ,( 24,  5,178)      ,( 24,  6,237)        ,( 24,  7,216)
        ,( 24,  8,102)       ,( 24,  9,115)      ,( 24, 10,150)        ,( 24, 11,229)
        ,( 24, 12, 73)       ,( 24, 13,130)      ,( 24, 14, 72)        ,( 24, 15, 61)
        ,( 24, 16, 43)       ,( 24, 17,206)      ,( 24, 18,  1)        ,( 24, 19,237)
        ,( 24, 20,247)       ,( 24, 21,127)      ,( 24, 22,217)        ,( 24, 23,144)
        ,( 24, 24,117)

        --------------------------------------------------
        -- ECC = 26
        --------------------------------------------------
        ,( 26,  0,  1)       ,( 26,  1,246)      ,( 26,  2, 51)        ,( 26,  3,183)
        ,( 26,  4,  4)       ,( 26,  5,136)      ,( 26,  6, 98)        ,( 26,  7,199)
        ,( 26,  8,152)       ,( 26,  9, 77)      ,( 26, 10, 56)        ,( 26, 11,206)
        ,( 26, 12, 24)       ,( 26, 13,145)      ,( 26, 14, 40)        ,( 26, 15,209)
        ,( 26, 16,117)       ,( 26, 17,233)      ,( 26, 18, 42)        ,( 26, 19,135)
        ,( 26, 20, 68)       ,( 26, 21, 70)      ,( 26, 22,144)        ,( 26, 23,146)
        ,( 26, 24, 77)       ,( 26, 25, 43)      ,( 26, 26, 94)

        --------------------------------------------------
        -- ECC = 28
        --------------------------------------------------
        ,( 28,  0,  1)      ,( 28,  1,252)      ,( 28,  2,  9)          ,( 28,  3, 28)
        ,( 28,  4, 13)      ,( 28,  5, 18)      ,( 28,  6,251)          ,( 28,  7,208)
        ,( 28,  8,150)      ,( 28,  9,103)      ,( 28, 10,174)          ,( 28, 11,100)
        ,( 28, 12, 41)      ,( 28, 13,167)      ,( 28, 14, 12)          ,( 28, 15,247)
        ,( 28, 16, 56)      ,( 28, 17,117)      ,( 28, 18,119)          ,( 28, 19,233)
        ,( 28, 20,127)      ,( 28, 21,181)      ,( 28, 22,100)          ,( 28, 23,121)
        ,( 28, 24,147)      ,( 28, 25,176)      ,( 28, 26, 74)          ,( 28, 27, 58)
        ,( 28, 28,197)

        --------------------------------------------------
        -- ECC = 30
        --------------------------------------------------
        ,( 30,  0,  1)      ,( 30,  1,212)      ,( 30,  2,246)          ,( 30,  3, 77)
        ,( 30,  4, 73)      ,( 30,  5,195)      ,( 30,  6,192)          ,( 30,  7, 75)
        ,( 30,  8, 98)      ,( 30,  9,  5)      ,( 30, 10, 70)          ,( 30, 11,103)
        ,( 30, 12,177)      ,( 30, 13, 22)      ,( 30, 14,217)          ,( 30, 15,138)
        ,( 30, 16, 51)      ,( 30, 17,181)      ,( 30, 18,246)          ,( 30, 19, 72)
        ,( 30, 20, 25)      ,( 30, 21, 18)      ,( 30, 22, 46)          ,( 30, 23,228)
        ,( 30, 24, 74)      ,( 30, 25,216)      ,( 30, 26,195)          ,( 30, 27, 11)
        ,( 30, 28,106)      ,( 30, 29,130)      ,( 30, 30,150)
END;
GO

-- ##############################################################################
-- ### Table: [QR].[GaloisExp]                                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Lookup table containing exponent values for GF(256) arithmetic.        ###
-- ###                                                                        ###
-- ### The table is used together with [QR].[GaloisLog] to implement          ###
-- ### efficient finite-field multiplication required by Reed-Solomon         ###
-- ### error correction.                                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[GaloisExp];
GO

CREATE TABLE [QR].[GaloisExp]
(
      [Exponent]    INTEGER     NOT NULL
    , [Value]       INTEGER     NOT NULL
    CONSTRAINT [PK_QR_GaloisExp]
        PRIMARY KEY ([Exponent])
);
GO

-- ##############################################################################
-- ### Table: [QR].[GaloisLog]                                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Lookup table containing logarithmic values for GF(256) arithmetic.     ###
-- ###                                                                        ###
-- ### The table is used to replace expensive finite-field multiplication     ###
-- ### operations by logarithmic addition.                                    ###
-- ###                                                                        ###
-- ### Used by Reed-Solomon error correction generation.                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[GaloisLog];
GO

CREATE TABLE [QR].[GaloisLog]
(
      [Value]       INTEGER     NOT NULL
    , [LogValue]    INTEGER     NOT NULL
    CONSTRAINT [PK_QR_GaloisLog]
        PRIMARY KEY ([Value])
);
GO

-- ##############################################################################
-- ### Table: [QR].[AlignmentPatternPosition]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores the alignment pattern coordinates for all supported QR          ###
-- ### versions.                                                              ###
-- ###                                                                        ###
-- ### The coordinates are used during matrix construction to place           ###
-- ### alignment patterns according to the QR specification.                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[AlignmentPatternPosition]
GO

CREATE TABLE [QR].[AlignmentPatternPosition]
(
      [VersionNumber] TINYINT     NOT NULL
    , [X]             SMALLINT    NOT NULL
    , [Y]             SMALLINT    NOT NULL

    CONSTRAINT [PK_QR_AlignmentPatternPosition]
        PRIMARY KEY
        (
            [VersionNumber],
            [X],
            [Y]
        )
);
GO

INSERT INTO QR.AlignmentPatternPosition VALUES(  2, 18, 18);
INSERT INTO QR.AlignmentPatternPosition VALUES(  3, 22, 22);
INSERT INTO QR.AlignmentPatternPosition VALUES(  4, 26, 26);
INSERT INTO QR.AlignmentPatternPosition VALUES(  5, 30, 30);
INSERT INTO QR.AlignmentPatternPosition VALUES(  6, 34, 34);
INSERT INTO QR.AlignmentPatternPosition VALUES(  7,  6, 22), (  7,  6, 38), (  7, 22,  6), (  7, 22, 22),
                                              (  7, 22, 38), (  7, 38,  6), (  7, 38, 22), (  7, 38, 38);
INSERT INTO QR.AlignmentPatternPosition VALUES(  8,  6, 24), (  8,  6, 42), (  8, 24,  6), (  8, 24, 24),
                                              (  8, 24, 42), (  8, 42,  6), (  8, 42, 24), (  8, 42, 42);
INSERT INTO QR.AlignmentPatternPosition VALUES(  9,  6, 26), (  9,  6, 46), (  9, 26,  6), (  9, 26, 26),
                                              (  9, 26, 46), (  9, 46,  6), (  9, 46, 26), (  9, 46, 46);
INSERT INTO QR.AlignmentPatternPosition VALUES( 10,  6, 28), ( 10,  6, 50), ( 10, 28,  6), ( 10, 28, 28),
                                              ( 10, 28, 50), ( 10, 50,  6), ( 10, 50, 28), ( 10, 50, 50);
GO

-- ##############################################################################
-- ### Table: [QR].[VersionRemainderBits]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores the number of remainder bits defined by the QR specification    ###
-- ### for each supported version.                                            ###
-- ###                                                                        ###
-- ### Remainder bits occupy otherwise unused modules and are validated       ###
-- ### during matrix population.                                              ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[VersionRemainderBits]
GO

CREATE TABLE [QR].[VersionRemainderBits]
(
      [VersionNumber]   TINYINT     NOT NULL
    , [RemainderBits]   TINYINT     NOT NULL

    CONSTRAINT [PK_QR_VersionRemainderBits]
        PRIMARY KEY ([VersionNumber])
);
GO

INSERT INTO QR.VersionRemainderBits
VALUES  (1 ,0), (2 ,7), (3 ,7), (4 ,7), ( 5, 7)
       ,(6 ,7), (7 ,0), (8 ,0), (9 ,0), (10, 0);
GO

-- ##############################################################################
-- ### Table: [QR].[LogoPattern]                                              ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores imported logo pixels including their original color             ###
-- ### information. Only visible pixels are stored. Transparent               ###
-- ### background pixels are ignored during import.                           ###
-- ###                                                                        ###
-- ### The table represents the source image for logo projection into         ###
-- ### the QR matrix.                                                         ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
IF OBJECT_ID('QR.LogoPattern') IS NULL
BEGIN
    CREATE TABLE [QR].[LogoPattern]
    (
            [LogoName]   VARCHAR(50) NOT NULL
        , [X]          SMALLINT    NOT NULL
        , [Y]          SMALLINT    NOT NULL
        , [ColorClass] TINYINT     NOT NULL

        CONSTRAINT [PK_QR_LogoPattern]
            PRIMARY KEY
            (
                [LogoName],
                [Y],
                [X]
            )
    );
END;
GO

-- ##############################################################################
-- ### Table: [QR].[LogoPlacement]                                            ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores the mapping between source logo pixels and their projected      ###
-- ### destination coordinates inside the QR matrix.                          ###
-- ###                                                                        ###
-- ### The table represents the result of the logo projection process.        ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [ ] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [x] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[LogoPlacement];
GO

CREATE TABLE [QR].[LogoPlacement]
(
      [LogoName]   VARCHAR(50) NOT NULL
    , [TargetX]    TINYINT     NOT NULL
    , [TargetY]    TINYINT     NOT NULL
    , [SourceX]    SMALLINT    NOT NULL
    , [SourceY]    SMALLINT    NOT NULL
    , [ColorClass] TINYINT     NOT NULL

    CONSTRAINT [PK_QR_LogoPlacement]
        PRIMARY KEY
        (
            [LogoName],
            [TargetY],
            [TargetX]
        )
);
GO

-- ##############################################################################
-- ### Table: [QR].[ErrorCorrectionLevel]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores the supported QR error correction levels and their associated   ###
-- ### codeword capacities.                                                   ###
-- ###                                                                        ###
-- ### The table serves as a central lookup and validation source for         ###
-- ### QR error correction levels.                                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### [x] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [ ] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[ErrorCorrectionLevel];
GO

CREATE TABLE [QR].[ErrorCorrectionLevel]
(
      [LevelCode]         CHAR(1)  PRIMARY KEY
    , [DataCodewords]     TINYINT  NOT NULL
    , [EccCodewords]      TINYINT  NOT NULL
);

INSERT INTO [QR].[ErrorCorrectionLevel]
VALUES
      ('L',19, 7)
    , ('M',16,10)
    , ('Q',13,13)
    , ('H', 9,17);
GO

-- ##############################################################################
-- ### Table: [QR].[VersionCapacity]                                          ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores QR payload capacities for all supported QR versions and         ###
-- ### error correction levels.                                               ###
-- ###                                                                        ###
-- ### The table is used to validate input payloads and determine whether     ###
-- ### a text can be encoded using the selected QR version and ECC level.     ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[VersionCapacity];
GO

CREATE TABLE [QR].[VersionCapacity]
(
      [VersionNumber]         TINYINT     NOT NULL
    , [ErrorCorrectionLevel]  CHAR(1)     NOT NULL
    , [DataCodewords]         SMALLINT    NOT NULL
    , [EccCodewords]          SMALLINT    NOT NULL

    CONSTRAINT [PK_QR_VersionCapacity]
        PRIMARY KEY
        (
            [VersionNumber],
            [ErrorCorrectionLevel]
        )
);
GO

INSERT INTO [QR].[VersionCapacity]
(
      [VersionNumber]
    , [ErrorCorrectionLevel]
    , [DataCodewords]
    , [EccCodewords]
)
VALUES
     (  1,'L', 19,  7), (  1,'M', 16, 10), (  1,'Q', 13, 13), (  1,'H',  9, 17)     -- Version  1
    ,(  2,'L', 34, 10), (  2,'M', 28, 16), (  2,'Q', 22, 22), (  2,'H', 16, 28)     -- Version  2
    ,(  3,'L', 55, 15), (  3,'M', 44, 26), (  3,'Q', 34, 18), (  3,'H', 26, 22)     -- Version  3
    ,(  4,'L', 80, 20), (  4,'M', 64, 18), (  4,'Q', 48, 26), (  4,'H', 36, 16)     -- Version  4
    ,(  5,'L',108, 26), (  5,'M', 86, 24), (  5,'Q', 62, 18), (  5,'H', 46, 22)     -- Version  5
    ,(  6,'L',136, 18), (  6,'M',108, 16), (  6,'Q', 76, 24), (  6,'H', 60, 28)     -- Version  6
    ,(  7,'L',156, 20), (  7,'M',124, 18), (  7,'Q', 88, 18), (  7,'H', 66, 26)     -- Version  7
    ,(  8,'L',194, 24), (  8,'M',154, 22), (  8,'Q',110, 22), (  8,'H', 86, 26)     -- Version  8
    ,(  9,'L',232, 30), (  9,'M',182, 22), (  9,'Q',132, 20), (  9,'H',100, 24)     -- Version  9
    ,( 10,'L',274, 18), ( 10,'M',216, 26), ( 10,'Q',154, 24), ( 10,'H',122, 28);    -- Version 10
GO

-- ##############################################################################
-- ### Table: [QR].[VersionBlockStructure]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Defines the QR block layout for each version and error correction      ###
-- ### level.                                                                 ###
-- ###                                                                        ###
-- ### The information stored here controls the distribution of data          ###
-- ### codewords into Reed-Solomon blocks and the subsequent ECC generation.  ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[VersionBlockStructure];
GO

CREATE TABLE [QR].[VersionBlockStructure]
(
      [VersionNumber]         TINYINT    NOT NULL
    , [ErrorCorrectionLevel]  CHAR(1)    NOT NULL
    , [GroupNumber]           TINYINT    NOT NULL
    , [BlockCount]            SMALLINT   NOT NULL
    , [DataCodewordsPerBlock] SMALLINT   NOT NULL

    CONSTRAINT [PK_QR_VersionBlockStructure]
        PRIMARY KEY
        (
            [VersionNumber],
            [ErrorCorrectionLevel],
            [GroupNumber]
        )
);
GO

INSERT INTO [QR].[VersionBlockStructure] VALUES
     (  1,'L',  1,  1, 19), (  1,'M',  1,  1, 16), (  1,'Q',  1,  1, 13), (  1,'H',  1,  1,  9)        -- Version  1
    ,(  2,'L',  1,  1, 34), (  2,'M',  1,  1, 28), (  2,'Q',  1,  1, 22), (  2,'H',  1,  1, 16)        -- Version  2
    ,(  3,'L',  1,  1, 55), (  3,'M',  1,  1, 44), (  3,'Q',  1,  2, 17), (  3,'H',  1,  2, 13)        -- Version  3
    ,(  4,'L',  1,  1, 80), (  4,'M',  1,  2, 32), (  4,'Q',  1,  2, 24), (  4,'H',  1,  4,  9)        -- Version  4
    ,(  5,'L',  1,  1,108), (  5,'M',  1,  2, 43), (  5,'Q',  1,  2, 15), (  5,'Q',  2,  2, 16), (  5,'H',  1,  2, 11), (  5,'H',  2,  2, 12)
    ,(  6,'L',  1,  2, 68), (  6,'M',  1,  4, 27), (  6,'Q',  1,  4, 19), (  6,'H',  1,  4, 15)        -- Version  6
    ,(  7,'L',  1,  2, 78), (  7,'M',  1,  4, 31), (  7,'Q',  1,  2, 14), (  7,'Q',  2,  4, 15), (  7,'H',  1,  4, 13), (  7,'H',  2,  1, 14)
    ,(  8,'L',  1,  2, 97), (  8,'M',  1,  2, 38), (  8,'M',  2,  2, 39), (  8,'Q',  1,  4, 18), (  8,'Q',  2,  2, 19), (  8,'H',  1,  4, 14), (  8,'H',  2,  2, 15)
    ,(  9,'L',  1,  2,116), (  9,'M',  1,  3, 36), (  9,'M',  2,  2, 37), (  9,'Q',  1,  4, 16), (  9,'Q',  2,  4, 17), (  9,'H',  1,  4, 12), (  9,'H',  2,  4, 13)
    ,( 10,'L',  1,  2, 68), ( 10,'L',  2,  2, 69), ( 10,'M',  1,  4, 43), ( 10,'M',  2,  1, 44), ( 10,'Q',  1,  6, 19), ( 10,'Q',  2,  2, 20), ( 10,'H',  1,  6, 15), ( 10,'H',  2,  2, 16);
GO

-- ##############################################################################
-- ### Table: [QR].[VersionDefinition]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Stores general QR version metadata.                                    ###
-- ###                                                                        ###
-- ### Each record describes the characteristics of a specific QR version,    ###
-- ### including matrix dimensions and structural information required        ###
-- ### throughout the QR generation process.                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### [ ] standard           [x] initial filling     [x] stable              ###
-- ### [ ] self-versioned     [ ] truncate            [ ] experimental        ###
-- ### [ ] system-versioned   [ ] complete rebuild    [ ] deprecated          ###
-- ###                                                [x] internal            ###
-- ##############################################################################
DROP TABLE IF EXISTS [QR].[VersionDefinition];
GO

CREATE TABLE [QR].[VersionDefinition]
(
      [VersionNumber]   TINYINT     NOT NULL
    , [MatrixSize]      SMALLINT    NOT NULL

    CONSTRAINT [PK_QR_VersionDefinition]
        PRIMARY KEY
        (
            [VersionNumber]
        )
);
GO

;WITH [V] AS
(
    SELECT 1                        AS [VersionNumber]

    UNION ALL

    SELECT [VersionNumber] + 1
    FROM [V]
    WHERE [VersionNumber] < 40
)

INSERT INTO [QR].[VersionDefinition]
(
      [VersionNumber]
    , [MatrixSize]
)
SELECT
      [VersionNumber]
    , 17 + ([VersionNumber] * 4)
FROM [V]
OPTION(MAXRECURSION 40);
GO










-- ##############################################################################
-- ### View: [QR].[vGeneratedSvgHistory]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Provides a convenient view of generated SVG documents together with    ###
-- ### their associated metadata. The view is intended for reporting,         ###
-- ### testing, debugging and history analysis.                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Derived from:             [QR].[GeneratedSvg]                          ###
-- ##############################################################################
CREATE OR ALTER VIEW [QR].[vGeneratedSvgHistory]
AS
SELECT
      [SvgID]                                           AS [SvgID]
    , [CreatedAt]                                       AS [CreatedAt]
    , [VersionNumber]                                   AS [VersionNumber]
    , [ErrorCorrectionLevel]                            AS [ErrorCorrectionLevel]
    , [LogoName]                                        AS [LogoName]
    , [TextLength]                                      AS [TextLength]
    , [SvgLength]                                       AS [SvgLength]
    , [TextEncoded]                                     AS [TextEncoded]
    , CONVERT(VARCHAR(64), [InputHash], 2)              AS [InputHashHex]
    , CONVERT(VARCHAR(64), [SvgHash],   2)              AS [SvgHashHex]
FROM [QR].[GeneratedSvg];
GO

-- ##############################################################################
-- ### View: [QR].[vLogoCandidates]                                           ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Identifies candidate regions that may be suitable for logo placement   ###
-- ### inside the QR matrix. Used during automatic logo area detection.       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Derived from:                [QR].[Module]                             ###
-- ##############################################################################
CREATE OR ALTER VIEW [QR].[vLogoCandidates]
AS
SELECT
      [X]
    , [Y]
    , CASE
          WHEN [ModuleType] IS NULL THEN 1
          ELSE 0
      END AS [IsFree]
FROM [QR].[Module];
GO











-- ##############################################################################
-- ### Procedure: [QR].[pBuildDataBlocks]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Distributes generated data codewords into QR specification blocks      ###
-- ### according to the selected version and ECC level.                       ###
-- ###                                                                        ###
-- ### The resulting block structure is stored in [QR].[DataBlock].           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pBuildDataBlocks]
(
      @VersionNumber        TINYINT
    , @ErrorCorrectionLevel CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [QR].[DataBlock];

    DECLARE @GroupNumber                INTEGER
    DECLARE @BlockCount                 INTEGER
    DECLARE @DataCodewordsPerBlock      INTEGER
    DECLARE @SourcePosition             INTEGER = 0
    DECLARE @BlockNumber                INTEGER = 1

    DECLARE C CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          [GroupNumber]
        , [BlockCount]
        , [DataCodewordsPerBlock]
    FROM [QR].[VersionBlockStructure]
    WHERE 1 = 1
        AND [VersionNumber]        = @VersionNumber
        AND [ErrorCorrectionLevel] = @ErrorCorrectionLevel
    ORDER BY [GroupNumber];

    OPEN [C];

    FETCH NEXT FROM [C]
    INTO
          @GroupNumber
        , @BlockCount
        , @DataCodewordsPerBlock;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @CurrentBlock INTEGER = 1;

        WHILE @CurrentBlock <= @BlockCount
        BEGIN
            DECLARE @BlockPosition INTEGER = 0;

            WHILE @BlockPosition < @DataCodewordsPerBlock
            BEGIN
                INSERT INTO [QR].[DataBlock]
                (
                      [BlockNumber]
                    , [Position]
                    , [Value]
                )
                SELECT
                      @BlockNumber
                    , @BlockPosition
                    , [Value]
                FROM [QR].[DataCodeword]
                WHERE [Position] = @SourcePosition;

                SET @SourcePosition     += 1;
                SET @BlockPosition      += 1;
            END

            SET @BlockNumber            += 1;
            SET @CurrentBlock           += 1;
        END

        FETCH NEXT FROM [C]
        INTO
              @GroupNumber
            , @BlockCount
            , @DataCodewordsPerBlock;
    END
    CLOSE [C];
    DEALLOCATE [C];

    -----------------------------------------------------------------
    -- Kontrolle
    -----------------------------------------------------------------
    IF (SELECT COUNT(*) FROM [QR].[DataBlock])
       <>
       (SELECT COUNT(*) FROM [QR].[DataCodeword])
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(MAX)
        SET @ErrorMessage =
              N'DE: Nicht alle Data-Codewords wurden auf Blöcke verteilt.'
            + CHAR(13) + CHAR(10)
            + N'EN: Not all data codewords were distributed across blocks.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetAlignmentPattern]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places a single alignment pattern at a specified matrix position.      ###
-- ### Alignment patterns improve readability and distortion tolerance for    ###
-- ### larger QR versions.                                                    ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @CenterX:                     Horizontal center position               ###
-- ### @CenterY:                     Vertical center position                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetAlignmentPattern]
(
      @CenterX INTEGER
    , @CenterY INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE 1 = 1
            AND [X]             BETWEEN @CenterX - 2 AND @CenterX + 2
            AND [Y]             BETWEEN @CenterY - 2 AND @CenterY + 2
            AND [ModuleType]    IN ('Finder', 'Separator')
    )
    RETURN;

    UPDATE [M]
    SET [IsBlack] =
        CASE
            WHEN ABS([M].[X] - @CenterX) = 2                                    THEN 1
            WHEN ABS([M].[Y] - @CenterY) = 2                                    THEN 1
            WHEN ABS([M].[X] - @CenterX) = 1 AND ABS([M].[Y] - @CenterY) = 1    THEN 0
            WHEN ABS([M].[X] - @CenterX) = 1 AND ABS([M].[Y] - @CenterY) = 0    THEN 0
            WHEN ABS([M].[X] - @CenterX) = 0 AND ABS([M].[Y] - @CenterY) = 1    THEN 0
            ELSE 1
        END,
        [ModuleType] = 'Alignment'
    FROM [QR].[Module]                  AS [M]
    WHERE
            [M].[X] BETWEEN @CenterX - 2 AND @CenterX + 2
        AND [M].[Y] BETWEEN @CenterY - 2 AND @CenterY + 2;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetAlignmentPatterns]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places all alignment patterns required by the selected QR version.     ###
-- ### Coordinates are obtained from [QR].[AlignmentPatternPosition].         ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetAlignmentPatterns]
(
    @VersionNumber      TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VersionNumber = 1
        RETURN;

    DECLARE
          @X INT
        , @Y INT;

    DECLARE [C] CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          [X]
        , [Y]
    FROM [QR].[AlignmentPatternPosition]
    WHERE [VersionNumber] = @VersionNumber;

    OPEN [C];

    FETCH NEXT FROM [C]
    INTO
          @X
        , @Y;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC [QR].[pSetAlignmentPattern]
              @CenterX = @X
            , @CenterY = @Y;

        FETCH NEXT FROM [C]
        INTO
              @X
            , @Y;
    END

    CLOSE [C];
    DEALLOCATE [C];
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pBuildGaloisTables]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates and populates the Galois lookup tables used for Reed-Solomon   ###
-- ### error correction calculations.                                         ###
-- ###                                                                        ###
-- ### The procedure fills [QR].[GaloisLog] and [QR].[GaloisExp].             ###
-- ###                                                                        ###
-- ### This procedure only needs to be executed when the lookup tables are    ###
-- ### missing or empty.                                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                     Internal                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pBuildGaloisTables]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE [QR].[GaloisExp];
    TRUNCATE TABLE [QR].[GaloisLog];

    DECLARE
          @Exponent INT = 0
        , @Value    INT = 1
        , @Next     INT;

    WHILE @Exponent < 255
    BEGIN

        INSERT INTO [QR].[GaloisExp]
        (
              [Exponent]
            , [Value]
        )
        VALUES
        (
              @Exponent
            , @Value
        );

        INSERT INTO [QR].[GaloisLog]
        (
              [Value]
            , [LogValue]
        )
        VALUES
        (
              @Value
            , @Exponent
        );

        SET @Next = @Value * 2;

        IF @Next >= 256
            SET @Next = @Next ^ 285;

        SET @Value = @Next;

        SET @Exponent += 1;
    END;

    INSERT INTO [QR].[GaloisExp]
    (
          [Exponent]
        , [Value]
    )
    SELECT
          [Exponent] + 255
        , [Value]
    FROM [QR].[GaloisExp]
    WHERE [Exponent] < 255;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pApplyLogoColors]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Applies logo-specific color information to projected logo modules      ###
-- ### inside the QR matrix. Colors are taken from [QR].[LogoPattern] and     ###
-- ### transferred to matching modules in [QR].[Module].                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @LogoName:               Logo identifier stored in [QR].[LogoPattern]  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pApplyLogoColors]
(
    @LogoName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [M]
    SET
        [ColorHex] =
            CASE
                WHEN [P].[ColorClass] = 1 AND [M].[IsBlack] = 1         THEN '#0F7285'
                WHEN [P].[ColorClass] = 1 AND [M].[IsBlack] = 0         THEN '#C4D9DD'
                WHEN [P].[ColorClass] = 2 AND [M].[IsBlack] = 1         THEN '#D09021'
                WHEN [P].[ColorClass] = 2 AND [M].[IsBlack] = 0         THEN '#FCF8F1'
            END
    FROM [QR].[Module]                          AS [M]
    INNER JOIN [QR].[LogoPlacement]             AS [P]
        ON 1 = 1
            AND [P].[TargetX] = [M].[X]
            AND [P].[TargetY] = [M].[Y]
    WHERE
        [P].[LogoName] = @LogoName;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pApplyMask]                                           ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Applies one of the eight QR mask patterns to all data modules.         ###
-- ### Structural QR modules remain unchanged.                                ###
-- ### Masking is implemented as an XOR operation.                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                  Internal                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @MaskPattern:               Mask pattern number (0-7)                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pApplyMask]
    @MaskPattern TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(MAX)

    IF @MaskPattern IS NULL
    BEGIN
        SET @ErrorMessage =
              N'DE: Das Mask Pattern darf nicht NULL sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: The mask pattern cannot be NULL.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @MaskPattern NOT BETWEEN 0 AND 7
    BEGIN
        SET @ErrorMessage =
              N'DE: Das Mask Pattern muss zwischen 0 und 7 liegen.'
            + CHAR(13) + CHAR(10)
            + N'EN: The mask pattern must be between 0 and 7.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- Ensure that the data has already been entered
    ------------------------------------------------------------------------
    DECLARE @TotalDataBits      INTEGER;

    SELECT
        @TotalDataBits = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF @TotalDataBits = 0
    BEGIN
        SET @ErrorMessage =
              N'DE: Keine Datenmodule vorhanden.'
            + CHAR(13) + CHAR(10)
            + N'EN: No data modules available.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- Apply masking. Coordinates: Y = row, X = column. The origin (0,0) is located at the top left.
    ------------------------------------------------------------------------
    UPDATE [M]
    SET [IsBlack] = CASE 
            WHEN 
                (@MaskPattern = 0 AND ((CONVERT(INT, [M].[Y]) + CONVERT(INT, [M].[X])) % 2) = 0)                                                                -- Mask Pattern 0
                OR
                (@MaskPattern = 1 AND (CONVERT(INT, [M].[Y]) % 2) = 0)                                                                                          -- Mask Pattern 1
                OR
                (@MaskPattern = 2 AND (CONVERT(INT, [M].[X]) % 3) = 0)                                                                                          -- Mask Pattern 2
                OR
                (@MaskPattern = 3 AND ((CONVERT(INT, [M].[Y]) + CONVERT(INT, [M].[X])) % 3) = 0)                                                                -- Mask Pattern 3
                OR
                (@MaskPattern = 4 AND ((CONVERT(INT, [M].[Y]) / 2)+ (CONVERT(INT, [M].[X]) / 3)) % 2 = 0)                                                       -- Mask Pattern 4
                OR
                (@MaskPattern = 5 AND ((CONVERT(INT, [M].[Y]) * CONVERT(INT, [M].[X])) % 2 + (CONVERT(INT, [M].[Y]) * CONVERT(INT, [M].[X])) % 3) = 0)          -- Mask Pattern 5
                OR
                (@MaskPattern = 6 AND (((CONVERT(INT, [M].[Y]) * CONVERT(INT, [M].[X])) % 2) + ((CONVERT(INT, [M].[Y]) * CONVERT(INT, [M].[X])) % 3)) % 2 = 0)  -- Mask Pattern 6
                OR
                (@MaskPattern = 7 AND (((CONVERT(INT, [M].[Y]) + CONVERT(INT, [M].[X])) % 2) + ((CONVERT(INT, [M].[Y]) * CONVERT(INT, [M].[X])) % 3)) % 2 = 0)  -- Mask Pattern 7
            THEN CONVERT(BIT, 1 - CONVERT(INT, [M].[IsBlack]))
            ELSE [M].[IsBlack]
            END
    FROM [QR].[Module]                                                  AS [M]
    WHERE
        [M].[ModuleType] IN ('Data', 'Remainder');
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCalculateMaskPenalty]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Calculates QR mask penalty scores according to the QR specification.   ###
-- ###                                                                        ###
-- ### All four QR penalty rules are evaluated and combined into a total      ###
-- ### penalty score. Lower scores indicate higher visual quality and         ###
-- ### improved scanability.                                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ReturnResultSet:        Controls whether the calculated penalty       ###
-- ###                          values are additionally returned as a result  ###
-- ###                          set.                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @OutPenaltyRule1:        Penalty score for rule 1 (runs of identical   ###
-- ###                          modules)                                      ###
-- ### @OutPenaltyRule2:        Penalty score for rule 2 (2x2 module blocks)  ###
-- ### @OutPenaltyRule3:        Penalty score for rule 3 (finder-like         ###
-- ###                          patterns)                                     ###
-- ### @OutPenaltyRule4:        Penalty score for rule 4 (black/white module  ###
-- ###                          ratio)                                        ###
-- ### @OutTotalPenalty:        Sum of all penalty rules                      ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCalculateMaskPenalty]
    @OutPenaltyRule1 INT OUTPUT,
    @OutPenaltyRule2 INT OUTPUT,
    @OutPenaltyRule3 INT OUTPUT,
    @OutPenaltyRule4 INT OUTPUT,
    @OutTotalPenalty INT OUTPUT,
    @ReturnResultSet BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    /* ========================================================================
       QR Mask Penalty Score
       The four rules are calculated separately:
           Rule 1: Long sequences of the same color
           Rule 2: 2x2 blocks of the same color
           Rule 3: “Finder”-like patterns
           Rule 4: Deviation from the 50 percent black ratio
       Finally, all four results are added together.
       ======================================================================== */
    DECLARE @PenaltyRule1   INTEGER = 0;
    DECLARE @PenaltyRule2   INTEGER = 0;
    DECLARE @PenaltyRule3   INTEGER = 0;
    DECLARE @PenaltyRule4   INTEGER = 0;
    DECLARE @MatrixSize     INTEGER;

    SELECT
        @MatrixSize = MAX(X) + 1
    FROM QR.Module;
    /* ========================================================================
       Rule 1
       Long horizontal and vertical sequences of the same color

       For a sequence of at least 5 modules:
           5 modules  -> 3 points
           6 modules  -> 4 points
           7 modules  -> 5 points
       In general:
           3 + RunLength - 5
       ======================================================================== */

    DECLARE @RunLength      INTEGER;
    DECLARE @PreviousColor  BIT;
    DECLARE @CurrentColor   BIT;
    DECLARE @X              INTEGER;
    DECLARE @Y              INTEGER;

    ------------------------------------------------------------------------
    -- Horizontal Chain
    ------------------------------------------------------------------------
    SET @Y = 0;

    WHILE @Y <= @MatrixSize - 1
    BEGIN
        SET @X              = 0;
        SET @RunLength      = 0;
        SET @PreviousColor  = NULL;

        WHILE @X <= @MatrixSize - 1
        BEGIN
            SELECT
                @CurrentColor = [IsBlack]
            FROM [QR].[Module]
            WHERE [X] = @X AND [Y] = @Y;

            IF @CurrentColor IS NULL
            BEGIN
                DECLARE @ErrorMessage NVARCHAR(MAX)
                SET @ErrorMessage =
                      N'DE: Die Matrix enthaelt noch Module ohne Farbwert.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: The matrix still contains modules without color values.'
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @PreviousColor IS NULL
            BEGIN
                SET @PreviousColor  = @CurrentColor;
                SET @RunLength      = 1;
            END
            ELSE IF @CurrentColor = @PreviousColor
            BEGIN
                SET @RunLength = @RunLength + 1;
            END
            ELSE
            BEGIN
                IF @RunLength >= 5
                BEGIN
                    SET @PenaltyRule1 =
                        @PenaltyRule1
                        + 3
                        + (@RunLength - 5);
                END;
                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END;
            SET @X = @X + 1;
        END;

        -- Evaluate the last row
        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;

        SET @Y = @Y + 1;
    END;

    ------------------------------------------------------------------------
    -- Vertical Chain
    ------------------------------------------------------------------------
    SET @X = 0;

    WHILE @X <= @MatrixSize - 1
    BEGIN
        SET @Y              = 0;
        SET @RunLength      = 0;
        SET @PreviousColor  = NULL;

        WHILE @Y <= @MatrixSize - 1
        BEGIN
            SELECT
                @CurrentColor = [IsBlack]
            FROM [QR].[Module]
            WHERE [X] = @X AND [Y] = @Y;

            IF @CurrentColor IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: Die Matrix enthaelt noch Module ohne Farbwert.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: The matrix still contains modules without color values.'
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @PreviousColor IS NULL
            BEGIN
                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END
            ELSE IF @CurrentColor = @PreviousColor
            BEGIN
                SET @RunLength = @RunLength + 1;
            END
            ELSE
            BEGIN
                IF @RunLength >= 5
                BEGIN
                    SET @PenaltyRule1 =
                        @PenaltyRule1
                        + 3
                        + (@RunLength - 5);
                END;

                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END;

            SET @Y = @Y + 1;
        END;

        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;
        SET @X = @X + 1;
    END;

    -- ========================================================================
    -- Rule 2       2x2 blocks of the same color
    -- Each 2x2 block consisting of four black or four white modules:
    --  +3 points
    -- The blocks may and should overlap.
    -- ========================================================================
    SELECT
        @PenaltyRule2 =
            COUNT(*) * 3
    FROM [QR].[Module]                                          AS [M00]

    INNER JOIN [QR].[Module]                                    AS [M10]
        ON [M10].[X] = [M00].[X] + 1
        AND [M10].[Y] = [M00].[Y]

    INNER JOIN [QR].[Module]                                    AS [M01]
        ON [M01].[X] = [M00].[X]
        AND [M01].[Y] = [M00].[Y] + 1

    INNER JOIN [QR].[Module]                                    AS [M11]
        ON [M11].[X] = [M00].[X] + 1
        AND [M11].[Y] = [M00].[Y] + 1

    WHERE 1 = 1
        AND [M00].[X] BETWEEN 0 AND @MatrixSize - 2
        AND [M00].[Y] BETWEEN 0 AND @MatrixSize - 2
        AND [M00].[IsBlack] = [M10].[IsBlack]
        AND [M00].[IsBlack] = [M01].[IsBlack]
        AND [M00].[IsBlack] = [M11].[IsBlack];

    -- ------------------------------------------------------------------------
    -- Penalty Rule 3: Finder-like Patterns
    -- This is the most important rule and also the one with the highest weighting.
    -- The pattern sought is the ratio 1 : 1 : 3 : 1 : 1, i.e., the bit pattern 
    -- 1011101 with four light modules before or after it, such as 10111010000 
    -- or 00001011101 (horizontal or vertical).
    -- ------------------------------------------------------------------------

    DECLARE @PatternA CHAR(11) = '10111010000';
    DECLARE @PatternB CHAR(11) = '00001011101';
    DECLARE @Sequence CHAR(11);

    -- ------------------------------------------------------------------------
    -- Horizontal
    -- ------------------------------------------------------------------------ */
    SET @Y = 0;

    WHILE @Y <= @MatrixSize - 1
    BEGIN

        SET @X = 0;

        WHILE @X <= @MatrixSize - 11
        BEGIN

            SELECT
                @Sequence =
                    STRING_AGG
                    (
                        CONVERT
                        (
                            VARCHAR(MAX),
                            CONVERT(INT, [IsBlack])
                        ),
                        ''
                    )
                    WITHIN GROUP
                    (
                        ORDER BY [X]
                    )
            FROM [QR].[Module]
            WHERE 1 = 1
                AND [Y] = @Y
                AND [X] BETWEEN @X AND @X + 10;

            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 = @PenaltyRule3 + 40;
            END;

            SET @X = @X + 1;
        END;

        SET @Y = @Y + 1;
    END;

    -- ------------------------------------------------------------------------
    -- Vertical
    -- ------------------------------------------------------------------------
    SET @X = 0;

    WHILE @X <= @MatrixSize - 1
    BEGIN

        SET @Y = 0;

        WHILE @Y <= @MatrixSize - 11
        BEGIN
            SELECT
                @Sequence =
                    STRING_AGG
                    (
                        CONVERT
                        (
                            VARCHAR(MAX),
                            CONVERT(INT, [IsBlack])
                        ),
                        ''
                    )
                    WITHIN GROUP
                    (
                        ORDER BY [Y]
                    )
            FROM [QR].[Module]
            WHERE 1 = 1
                AND [X] = @X
                AND [Y] BETWEEN @Y AND @Y + 10;

            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 = @PenaltyRule3 + 40;
            END;

            SET @Y = @Y + 1;
        END;

        SET @X = @X + 1;
    END;

    -- ----------------------------------------------------------------------------- 
    -- Penalty Rule 4: Black-to-White Ratio: Ideally, the percentage of black modules 
    -- should be close to 50 percent. The further it deviates from this, the higher 
    -- the penalty score. Rule 4 operates in 5-percent increments and assigns 10 
    -- points per increment.
    -- ----------------------------------------------------------------------------- 
    DECLARE @TotalModules       INTEGER;
    DECLARE @BlackModules       INTEGER;
    DECLARE @BlackPercent       DECIMAL(10,4);
    DECLARE @DeviationFrom50    DECIMAL(10,4);
    DECLARE @FivePercentSteps   INTEGEr;

    SELECT
        @TotalModules = COUNT(*),
        @BlackModules =
            SUM
            (
                CASE
                    WHEN [IsBlack] = 1 THEN 1
                    ELSE 0
                END
            )
    FROM [QR].[Module];

    SET @BlackPercent       = 100.0 * CONVERT(DECIMAL(10,4), @BlackModules) / CONVERT(DECIMAL(10,4), @TotalModules);
    SET @DeviationFrom50    = ABS(@BlackPercent - 50.0);
    SET @FivePercentSteps   = FLOOR(@DeviationFrom50 / 5.0);
    SET @PenaltyRule4       = @FivePercentSteps * 10;

    -- Now let's add the four partial results
    DECLARE @TotalPenalty   INTEGER;
    SET @TotalPenalty = @PenaltyRule1 + @PenaltyRule2 + @PenaltyRule3 + @PenaltyRule4;

    -- ------------------------------------------------------------------------
    -- Return results to the caller
    -- ------------------------------------------------------------------------
    SET @OutPenaltyRule1 = @PenaltyRule1;
    SET @OutPenaltyRule2 = @PenaltyRule2;
    SET @OutPenaltyRule3 = @PenaltyRule3;
    SET @OutPenaltyRule4 = @PenaltyRule4;
    SET @OutTotalPenalty = @TotalPenalty;

    -- ------------------------------------------------------------------------
    -- Optional Output Control
    -- When calling the function manually, we still want to be able to see the 
    -- previous result set. 
    -- pSelectBestMask, on the other hand, sets @ReturnResultSet to 0.
    -- ------------------------------------------------------------------------
    IF @ReturnResultSet = 1
    BEGIN

        SELECT
            @PenaltyRule1 AS [PenaltyRule1],
            @PenaltyRule2 AS [PenaltyRule2],
            @PenaltyRule3 AS [PenaltyRule3],
            @PenaltyRule4 AS [PenaltyRule4],

            @TotalPenalty AS [TotalPenalty],

            @BlackModules AS [BlackModules],
            @TotalModules AS [TotalModules],
            @BlackPercent AS [BlackPercent];
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateBaseMatrix]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates the complete QR matrix framework required before payload       ###
-- ### placement.                                                             ###
-- ### The procedure places all fixed QR structures defined by the            ###
-- ### specification.                                                         ###
-- ### Internally calls procedures responsible for finder patterns,           ###
-- ### separators, timing patterns, alignment patterns, format areas and      ###
-- ### the dark module.                                                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                      Internal                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:                 QR version number                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateBaseMatrix]
    @VersionNumber              TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize         INTEGER;
    DECLARE @BorderRight        INTEGER;
    SET @MatrixSize     = [QR].[fnGetMatrixSize](@VersionNumber);
    SET @BorderRight    = @MatrixSize - 7;

    EXEC [QR].[pInitializeMatrix] @VersionNumber = @VersionNumber;

    EXEC [QR].[pSetFinderPattern] 0, 0;
    EXEC [QR].[pSetFinderPattern] @BorderRight, 0;
    EXEC [QR].[pSetFinderPattern] 0, @BorderRight;

    EXEC [QR].[pSetSeparator] 0, 0;
    EXEC [QR].[pSetSeparator] @BorderRight, 0;
    EXEC [QR].[pSetSeparator] 0, @BorderRight;

    EXEC [QR].[pSetTimingPatterns]    @VersionNumber = @VersionNumber;
    EXEC [QR].[pSetAlignmentPatterns] @VersionNumber = @VersionNumber;
    EXEC [QR].[pSetDarkModule]        @VersionNumber = @VersionNumber;
    EXEC [QR].[pReserveFormatModules] @VersionNumber = @VersionNumber;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateColoredQrCode]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates a complete QR code including logo projection, color mapping    ###
-- ### and SVG rendering. This procedure represents the primary public API    ###
-- ### of the project.                                                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:             Public                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                 Text to be encoded into the QR code.            ###
-- ### @LogoName:             Name of the logo stored in [QR].[LogoPattern].  ###
-- ###                        NULL disables logo projection.                  ###
-- ### @ErrorCorrectionLevel: QR error correction level (L, M, Q or H)        ###
-- ### @ModuleSize:           Module size in SVG pixels.                      ###
-- ### @QuietZone:            Number of quiet-zone modules surrounding        ###
-- ###                        the QR code.                                    ###
-- ### @ForegroundColor:      Default color of dark QR modules                ###
-- ### @BackgroundColor:      Background color of the SVG document            ###
-- ### @RoundDataModulesOnly: Enables rounded rendering of data modules       ###
-- ### @VersionNumber:        QR version number                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @Svg:                       Generated SVG document                     ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateColoredQrCode]
(
      @Text                     VARCHAR(255)
    , @LogoName                 VARCHAR(50)
    , @ErrorCorrectionLevel     CHAR(1)     = 'M'
    , @ModuleSize               INTEGER     = 10
    , @QuietZone                INTEGER     = 4
    , @ForegroundColor          CHAR(7)     = '#000000'
    , @BackgroundColor          CHAR(7)     = '#FFFFFF'
    , @RoundDataModulesOnly     BIT         = 1
    , @VersionNumber            TINYINT     = 1
    , @Svg                      NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataBitStream      VARCHAR(MAX)
    DECLARE @FinalBitStream     VARCHAR(MAX);

    IF NOT EXISTS
    (
        SELECT 1
        FROM QR.GaloisLog
    )
    OR NOT EXISTS
    (
        SELECT 1
        FROM QR.GaloisExp
    )
    BEGIN
        EXEC QR.pBuildGaloisTables;
    END;

    ------------------------------------------------
    -- QR erzeugen
    ------------------------------------------------

    -- '1 BaseMatrix';
    EXEC [QR].[pCreateBaseMatrix]
        @VersionNumber = @VersionNumber;

    -- '2 DataBitStream';
    EXEC [QR].[pCreateDataBitStream]
          @Text                     = @Text
        , @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel
        , @DataBitStream            = @DataBitStream OUTPUT;

    -- '3 DataCodewords';
    EXEC [QR].[pCreateDataCodewords]
          @DataBitStream            = @DataBitStream
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 
        , @VersionNumber            = @VersionNumber

    -- '4 ECC';
    EXEC QR.pBuildDataBlocks
          @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 

    EXEC QR.pCreateEccBlocks
          @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 

    EXEC QR.pInterleaveCodewords;

    -- '5 FinalBitStream';
    EXEC [QR].[pCreateFinalBitStream]
          @ErrorCorrectionLevel     = @ErrorCorrectionLevel
        , @VersionNumber            = @VersionNumber
        , @FinalBitStream           = @FinalBitStream OUTPUT;

    -- '6 PlaceDataBits';
    EXEC [QR].[pPlaceDataBits]
         @Bits                      = @FinalBitStream,
         @VersionNumber             = @VersionNumber;

    -- '7 SelectBestMask';
    EXEC [QR].[pSelectBestMask]
        @ErrorCorrectionLevel       = @ErrorCorrectionLevel,
        @VersionNumber              = @VersionNumber;

    ------------------------------------------------
    -- Logo
    ------------------------------------------------
    IF NULLIF(@LogoName, '') IS NOT NULL
    BEGIN

        -- '8 LargestLogoArea';
        EXEC [QR].[pDetermineLargestLogoArea];

        DECLARE
              @StartX       INTEGER
            , @StartY       INTEGER
            , @Width        INTEGER
            , @Height       INTEGER;

        SELECT
              @StartX = [StartX]
            , @StartY = [StartY]
            , @Width  = [Width]
            , @Height = [Height]
        FROM [QR].[LogoArea]
        WHERE [AreaName] = 'LargestFreeRectangle';

        IF @Width IS NULL
           OR @Height IS NULL
        BEGIN
            THROW 50000,
                  'DE: Es konnte kein Logo-Bereich ermittelt werden.
        EN: No logo area could be determined.',
                  1;
        END;

        -- '9 ProjectLogo';
        EXEC [QR].[pProjectLogoPattern]
              @LogoName
            , @StartX
            , @StartY
            , @Width
            , @Height;

        -- '10 ApplyColors';
        EXEC [QR].[pApplyLogoColors]
             @LogoName;
    END

    ------------------------------------------------
    -- SVG
    ------------------------------------------------
    EXEC [QR].[pGenerateSvg]
          @ModuleSize           = @ModuleSize
        , @QuietZone            = @QuietZone
        , @ForegroundColor      = @ForegroundColor
        , @BackgroundColor      = @BackgroundColor
        , @RoundDataModulesOnly = @RoundDataModulesOnly
        , @Svg                  = @Svg OUTPUT;

    INSERT INTO [QR].[GeneratedSvg]
    (
          [CreatedAt]
        , [VersionNumber]
        , [TextEncoded]
        , [LogoName]
        , [ErrorCorrectionLevel]
        , [SvgLength]
        , [SvgHash]
        , [SvgContent]
        , [TextLength]
        , [InputHash]
    )
    VALUES
    (
          SYSDATETIME()
        , @VersionNumber
        , @Text
        , @LogoName
        , @ErrorCorrectionLevel
        , LEN(@Svg)
        , HASHBYTES
          (
              'SHA2_256',
              CONVERT(VARBINARY(MAX), @Svg)
          )
        , @Svg
        , LEN(@Svg)
        , HASHBYTES
          (
              'SHA2_256',
              CONCAT
              (
                    ISNULL(@Text,''),                       '|'
                  , ISNULL(@LogoName,''),                   '|'
                  , CONVERT(VARCHAR(10),@VersionNumber),    '|'
                  , ISNULL(@ErrorCorrectionLevel,'')
              )
          )
    );
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateDataBitStream]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Encodes the input payload using QR Byte Mode and generates the         ###
-- ### complete QR data bit stream.                                           ###
-- ###                                                                        ###
-- ### The procedure performs:                                                ###
-- ###   - Mode indicator creation                                            ###
-- ###   - Character count indicator generation                               ###
-- ###   - Payload encoding                                                   ###
-- ###   - Terminator insertion                                               ###
-- ###   - Bit padding                                                        ###
-- ###   - Pad codeword generation                                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                        Text to be encoded                       ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @DataBitStream:               Generated QR payload bit stream          ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateDataBitStream]
(
      @Text                     VARCHAR(255)
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
    , @DataBitStream            VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ModeIndicator      CHAR(4)      = '0100';
    DECLARE @CharacterCount     INTEGER;
    DECLARE @CharacterCountBits CHAR(8);
    DECLARE @PayloadBits        VARCHAR(MAX);
    DECLARE @RawDataBits        VARCHAR(MAX);
    DECLARE @DataCodewords      INTEGER;
    DECLARE @CapacityBits       INTEGER;
    DECLARE @Bytes TABLE
    (
          [Position]            INTEGER
        , [ByteValue]           TINYINT
        , [BitValue]            CHAR(8)
    );

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    SET @CharacterCount = LEN(@Text);

    ;WITH [N] AS
    (
        SELECT 1                                        AS Position

        UNION ALL

        SELECT Position + 1
        FROM [N]
        WHERE [Position] < LEN(@Text)
    )
    INSERT INTO @Bytes
    (
          [Position]
        , [ByteValue]
        , [BitValue]
    )
    SELECT
          [Position]
        , ASCII(SUBSTRING(@Text, [Position], 1))

        , CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   1 =   1 THEN '1' ELSE '0' END
    FROM [N]
    OPTION (MAXRECURSION 255);

    SET @CharacterCountBits =
          CASE WHEN @CharacterCount & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   1 =   1 THEN '1' ELSE '0' END;

    SELECT
        @PayloadBits =
            STRING_AGG(CONVERT(VARCHAR(MAX), [BitValue]), '')
            WITHIN GROUP (ORDER BY [Position])
    FROM @Bytes;

    SET @RawDataBits =
          @ModeIndicator
        + @CharacterCountBits
        + @PayloadBits;

    SET @CapacityBits = @DataCodewords * 8;

    IF LEN(@RawDataBits) > @CapacityBits
    BEGIN
        DECLARE @ErrorMessage60002       NVARCHAR(500);
        SET @ErrorMessage60002 =
              N'DE: Die Nutzdaten überschreiten die Kapazität der gewählten QR-Version '
            + CAST(@VersionNumber AS NVARCHAR(10))
            + N'-'
            + @ErrorCorrectionLevel
            + N'.'
            + CHAR(13) + CHAR(10)
            + N'EN: The payload exceeds the capacity of the selected QR version '
            + CAST(@VersionNumber AS NVARCHAR(10))
            + N'-'
            + @ErrorCorrectionLevel
            + N'.';
        THROW 60002, @ErrorMessage60002, 1;
    END;

    SET @DataBitStream =
        QR.fnPadDataBits_V1
        (
            @RawDataBits,
            @DataCodewords
        );

    IF LEN(@DataBitStream) <> (@DataCodewords * 8)
    BEGIN
        DECLARE @ErrorMessage60001       NVARCHAR(500);
        SET @ErrorMessage60002 =
              N'DE: Unerwartete Bitlänge im DataBitStream.'
            + CHAR(13) + CHAR(10)
            + N'EN: Unexpected bit length in the DataBitStream.';
        THROW 60001, @ErrorMessage60001, 1;
    END
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateDataCodewords]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Splits the QR data bit stream into 8-bit codewords and stores them     ###
-- ### in [QR].[DataCodeword].                                                ###
-- ###                                                                        ###
-- ### The resulting data codewords form the basis for block distribution     ###
-- ### and Reed-Solomon ECC generation.                                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                       Internal                              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @DataBitStream:               QR payload bit stream                    ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateDataCodewords]
(
      @DataBitStream            VARCHAR(MAX)
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DataCodewords      INTEGER;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DELETE FROM [QR].[DataCodeword];

    DECLARE
          @Position             INTEGER = 0
        , @ByteBits             CHAR(8);

    WHILE @Position < @DataCodewords
    BEGIN
        SET @ByteBits =
            SUBSTRING
            (
                @DataBitStream,
                (@Position * 8) + 1,
                8
            );

        INSERT INTO [QR].[DataCodeword]
        (
              [Position]
            , [Value]
        )
        VALUES
        (
              @Position
            , [QR].[fnBinaryByteToInt](@ByteBits)
        );

        SET @Position += 1;
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pInterleaveCodewords]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Interleaves data codewords and Reed-Solomon error correction           ###
-- ### codewords according to the QR specification.                           ###
-- ### The result is stored in [QR].[InterleavedCodeword].                    ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                      Internal                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pInterleaveCodewords]
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [QR].[InterleavedCodeword];

    DECLARE @Position INT = 0;
        DECLARE @MaxDataPosition INT;

    SELECT
        @MaxDataPosition = MAX(Position)
    FROM QR.DataBlock;

    DECLARE @DataPosition       INTEGER = 0;
    DECLARE @MaxEccPosition     INTEGER;
    DECLARE @EccPosition        INTEGER = 0;

    WHILE @DataPosition <= @MaxDataPosition
    BEGIN
        INSERT INTO [QR].[InterleavedCodeword]
        (
              [Position]
            , [Value]
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY [BlockNumber]
                ) - 1
            , Value
        FROM [QR].[DataBlock]
        WHERE [Position] = @DataPosition;

        SET @Position += @@ROWCOUNT;

        SET @DataPosition += 1;
    END;

    SELECT
        @MaxEccPosition = MAX([Position])
    FROM [QR].[EccBlock];

    WHILE @EccPosition <= @MaxEccPosition
    BEGIN
        INSERT INTO [QR].[InterleavedCodeword]
        (
              [Position]
            , [Value]
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY [BlockNumber]
                ) - 1
            , [Value]
        FROM [QR].[EccBlock]
        WHERE [Position] = @EccPosition;

        SET @Position += @@ROWCOUNT;
        SET @EccPosition += 1;
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateEccForBlock]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates Reed-Solomon error correction codewords for a single QR      ###
-- ### data block.                                                            ###
-- ###                                                                        ###
-- ### The procedure performs polynomial division using the corresponding     ###
-- ### generator polynomial and stores the resulting ECC codewords in         ###
-- ### [QR].[EccBlock].                                                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                   Internal                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @BlockNumber:                Data block to process                     ###
-- ### @VersionNumber:              QR version number                         ###
-- ### @ErrorCorrectionLevel:       QR error correction level (L, M, Q or H)  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateEccForBlock]
(
      @BlockNumber              INTEGER
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EccCodewords       INTEGER;
    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DECLARE @Remainder TABLE
    (
        [Position]              INTEGER     NOT NULL    PRIMARY KEY,
        [Value]                 INTEGER     NOT NULL
    );

    DECLARE @Generator TABLE
    (
          [Position]            INTEGER                 PRIMARY KEY
        , [Coefficient]         INTEGER     NOT NULL
    );


    INSERT INTO @Generator
    (
          [Position]
        , [Coefficient]
    )
    SELECT
          [Position]
        , [Coefficient]
    FROM [QR].[GeneratorPolynomial]
    WHERE [EccCodewords] = @EccCodewords;

    IF NOT EXISTS
    (
        SELECT 1
        FROM @Generator
    )
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(MAX)
        SET @ErrorMessage =
              N'DE: Kein Generatorpolynom gefunden.'
            + CHAR(13) + CHAR(10)
            + N'EN: No generator polynomial found'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    ;WITH [N] AS
    (
        SELECT 0                AS [Position]

        UNION ALL

        SELECT [Position] + 1
        FROM [N]
        WHERE [Position] + 1 < @EccCodewords
    )
    INSERT INTO @Remainder
    (
          [Position]
        , [Value]
    )
    SELECT
          [Position]
        , 0
    FROM [N]
    OPTION(MAXRECURSION 100);

    DECLARE @DataPosition           INTEGER = 0;
    DECLARE @DataValue              INTEGER;
    DECLARE @FirstRemainder         INTEGER;
    DECLARE @Factor                 INTEGER;
    DECLARE @GeneratorPosition      INTEGER;
    DECLARE @GeneratorCoefficient   INTEGER;
    DECLARE @Product                INTEGER;
    DECLARE @OldValue               INTEGER;
    DECLARE @DataCodewords          INTEGER;
    DECLARE @Shift TABLE
        (
              [Position]            INTEGER             PRIMARY KEY
            , [Value]               INTEGER NOT NULL
        );

    SELECT
        @DataCodewords = COUNT(*)
    FROM [QR].[DataBlock]
    WHERE BlockNumber = @BlockNumber;

    WHILE @DataPosition < @DataCodewords
    BEGIN
        DELETE FROM @Shift;

        SELECT
            @DataValue = Value
        FROM [QR].[DataBlock]
        WHERE 1 = 1
            AND [BlockNumber] = @BlockNumber
            AND [Position]    = @DataPosition;

        SELECT
            @FirstRemainder = [Value]
        FROM @Remainder
        WHERE [Position] = 0;


        IF @DataValue IS NULL
BEGIN
    THROW 79993,
          'DE: DataValue ist NULL.
EN: DataValue is NULL.',
          1;
END;


        SET @Factor = @DataValue ^ @FirstRemainder;

        INSERT INTO @Shift
        (
              [Position]
            , [Value]
        )
        SELECT
              [Position]
            , [Value]
        FROM @Remainder;

        UPDATE R
        SET
            [Value] =
                ISNULL
                (
                    (
                        SELECT S.[Value]
                        FROM @Shift AS S
                        WHERE
                            S.[Position] = R.[Position] + 1
                    ),
                    0
                )
        FROM @Remainder AS R;

        SET @GeneratorPosition = 1;

        WHILE @GeneratorPosition <= @EccCodewords
        BEGIN
            SELECT
                @GeneratorCoefficient = [Coefficient]
            FROM @Generator
            WHERE [Position] = @GeneratorPosition;


            IF @Factor IS NULL
            BEGIN
                THROW 79991,
                      'DE: Factor ist NULL.
            EN: Factor is NULL.',
                      1;
            END;

            IF @GeneratorCoefficient IS NULL
            BEGIN
                THROW 79992,
                      'DE: GeneratorCoefficient ist NULL.
            EN: GeneratorCoefficient is NULL.',
                      1;
            END;

            IF @Factor IS NULL
            BEGIN
                THROW 79996,
                      'DE: Factor ist NULL.
            EN: Factor is NULL.',
                      1;
            END;

            IF @GeneratorCoefficient IS NULL
            BEGIN
                THROW 79997,
                      'DE: GeneratorCoefficient ist NULL.
            EN: GeneratorCoefficient is NULL.',
                      1;
            END;

            SET @Product =
                [QR].[fnGaloisMultiply]
                (
                    @Factor,
                    @GeneratorCoefficient
                );

            SELECT
                @OldValue = [Value]
            FROM @Remainder
            WHERE
                [Position] = @GeneratorPosition - 1;

            DECLARE @NewValue INT;


            IF @OldValue IS NULL
BEGIN
    THROW 79994,
          'DE: OldValue ist NULL.
EN: OldValue is NULL.',
          1;
END;

IF @Product IS NULL
BEGIN
    THROW 79995,
          'DE: Product ist NULL.
EN: Product is NULL.',
          1;
END;


            SET @NewValue = @OldValue ^ @Product;

            UPDATE @Remainder
            SET
                [Value] = @NewValue
            WHERE
                [Position] = @GeneratorPosition - 1;

            SET @GeneratorPosition = @GeneratorPosition + 1;
        END;

        SET @DataPosition = @DataPosition + 1;
    END

    IF
    (
        SELECT COUNT(*)
        FROM @Remainder
    ) <> @EccCodewords
    BEGIN
        SET @ErrorMessage =
              N'DE: Falsche Anzahl ECC-Codewords erzeugt.'
            + CHAR(13) + CHAR(10)
            + N'EN: An incorrect number of ECC codewords was generated.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    INSERT INTO [QR].[EccBlock]
    (
          [BlockNumber]
        , [Position]
        , [Value]
    )
    SELECT
          @BlockNumber
        , [Position]
        , [Value]
    FROM @Remainder;
END;
GO


-- ##############################################################################
-- ### Procedure: [QR].[pCreateEccBlocks]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates Reed-Solomon error correction codewords for all data blocks    ###
-- ### belonging to the selected QR version and ECC level.                    ###
-- ###                                                                        ###
-- ### Internally calls [QR].[pCreateEccForBlock] for each block.             ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateEccBlocks]
(
      @VersionNumber          TINYINT
    , @ErrorCorrectionLevel   CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxBlockNumber     INTEGER;
    DECLARE @BlockNumber        INTEGER = 1;

    DELETE FROM [QR].[EccBlock];

    SELECT
        @MaxBlockNumber = MAX(BlockNumber)
    FROM [QR].[DataBlock];

    WHILE @BlockNumber <= @MaxBlockNumber
    BEGIN
        EXEC [QR].[pCreateEccForBlock]
              @BlockNumber
            , @VersionNumber
            , @ErrorCorrectionLevel;

        SET @BlockNumber += 1;
    END
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateFinalBitStream]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts the interleaved codeword sequence into the final QR bit       ###
-- ### stream ready for matrix placement.                                     ###
-- ### The procedure appends version-specific remainder bits as required      ###
-- ### by the QR specification.                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @FinalBitStream:              Final QR bit stream ready for matrix     ###
-- ###                               placement.                               ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateFinalBitStream]
(
    @VersionNumber          TINYINT,
    @ErrorCorrectionLevel   CHAR(1),
    @FinalBitStream         VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataCodewords      INTEGER;
    DECLARE @EccCodewords       INTEGER;
    DECLARE @ExpectedBits       INTEGER;
    DECLARE @ExpectedCodewords  INTEGER;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    IF NOT EXISTS
    (
        SELECT 1
        FROM [QR].[InterleavedCodeword]
    )
    BEGIN 
        DECLARE @ErrorMessage NVARCHAR(MAX)
        SET @ErrorMessage =
              N'DE: Keine interleavten Codewords vorhanden.'
            + CHAR(13) + CHAR(10)
            + N'EN: No interleaved codewords are present.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
        @FinalBitStream =
            STRING_AGG
            (
                CONVERT
                (
                    VARCHAR(MAX),
                    [QR].[fnByteToBinary]([Value])
                ),
                ''
            )
            WITHIN GROUP
            (
                ORDER BY [Position]
            )
    FROM QR.InterleavedCodeword;

    SELECT
        @ExpectedCodewords = COUNT(*)
    FROM QR.InterleavedCodeword;

    SET @ExpectedBits = @ExpectedCodewords * 8;

    IF LEN(@FinalBitStream) <> @ExpectedBits
    BEGIN
        SET @ErrorMessage =
              N'FinalBitStream besitzt '
            + CAST(LEN(@FinalBitStream) AS NVARCHAR(10))
            + N' statt '
            + CAST(@ExpectedBits AS NVARCHAR(10))
            + N' Bits.'
            + CHAR(13) + CHAR(10)
            + N'EN: FinalBitStream has '
            + CAST(LEN(@FinalBitStream) AS NVARCHAR(10))
            + N'bits instead of '
            + CAST(@ExpectedBits AS NVARCHAR(10));
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pCreateQrCode]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates a QR matrix according to the QR specification.                 ###
-- ### No logo projection or SVG generation is performed.                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:             Public                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                 Text to be encoded                              ###
-- ### @VersionNumber:        QR version number.                              ###
-- ### @ErrorCorrectionLevel: QR error correction level (L, M, Q or H)        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:     None                                            ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pCreateQrCode]
(
    @Text                   VARCHAR(255), 
    @VersionNumber          TINYINT         = 1,
    @ErrorCorrectionLevel   CHAR(1)         = 'M'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataBitStream  VARCHAR(MAX);
    DECLARE @FinalBitStream VARCHAR(MAX);

    EXEC QR.pCreateBaseMatrix
        @VersionNumber = @VersionNumber;

    EXEC [QR].[pCreateDataBitStream]
        @Text                   = @Text,
        @VersionNumber          = @VersionNumber,
        @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
        @DataBitStream          = @DataBitStream OUTPUT;

    EXEC [QR].[pCreateDataCodewords]
         @DataBitStream         = @DataBitStream,
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pBuildDataBlocks
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pCreateEccBlocks
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pInterleaveCodewords;

    EXEC [QR].[pCreateFinalBitStream]
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel,
         @VersionNumber         = @VersionNumber,
         @FinalBitStream        = @FinalBitStream OUTPUT;

    EXEC [QR].[pPlaceDataBits]
         @Bits                  = @FinalBitStream,
         @VersionNumber         = @VersionNumber;

    EXEC [QR].[pSelectBestMask]
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel,
         @VersionNumber         = @VersionNumber;
END;
GO


-- ##############################################################################
-- ### Procedure: [QR].[pDeleteLogoPattern]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Deletes all pixels belonging to the specified logo from                ###
-- ### [QR].[LogoPattern].                                                    ###
-- ###                                                                        ###
-- ### This procedure is typically used before importing an updated           ###
-- ### version of a logo or when removing obsolete logo definitions.          ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                                                             ###
-- ###   Public                                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ###   @LogoName:                                                           ###
-- ###     Name of the logo to be deleted.                                    ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ###   None                                                                 ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pDeleteLogoPattern]
(
    @LogoName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE
    FROM [QR].[LogoPattern]
    WHERE [LogoName] = @LogoName;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pDetermineLargestLogoArea]                            ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Identifies the largest rectangular area inside the QR matrix that can  ###
-- ### be used for logo placement without overwriting structural QR elements. ###
-- ###                                                                        ###
-- ### The procedure analyzes the current QR matrix and determines the        ###
-- ### largest available free rectangle suitable for logo projection.         ###
-- ###                                                                        ###
-- ### The resulting area definition is stored in [QR].[LogoArea].            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                                                             ###
-- ###   Internal                                                             ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ###   None                                                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ###   None                                                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Generated Data:                                                        ###
-- ###   [QR].[LogoArea]                                                      ###
-- ###     AreaName                                                           ###
-- ###     StartX                                                             ###
-- ###     StartY                                                             ###
-- ###     EndX                                                               ###
-- ###     EndY                                                               ###
-- ###     Width                                                              ###
-- ###     Height                                                             ###
-- ###     Area                                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Notes:                                                                 ###
-- ###   The preferred placement area is stored using the area name           ###
-- ###   'LargestFreeRectangle'.                                              ###
-- ###                                                                        ###
-- ###   The resulting coordinates are later consumed by                      ###
-- ###   [QR].[pProjectLogoPattern].                                          ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pDetermineLargestLogoArea]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BestStartX         INTEGER = NULL
    DECLARE @BestStartY         INTEGER = NULL
    DECLARE @BestEndX           INTEGER = NULL
    DECLARE @BestEndY           INTEGER = NULL
    DECLARE @BestArea           INTEGER = 0;
    DECLARE @StartX             INTEGER
    DECLARE @StartY             INTEGER
    DECLARE @EndX               INTEGER
    DECLARE @EndY               INTEGER
    DECLARE @Area               INTEGER
    DECLARE @MatrixSize         INTEGER;

    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    SET @StartY = 0;

    WHILE @StartY <= @MatrixSize - 1
    BEGIN
        SET @StartX = 0;

        WHILE @StartX <= @MatrixSize - 1
        BEGIN

            SET @EndY = @StartY;

            WHILE @EndY <= @MatrixSize - 1
            BEGIN

                SET @EndX = @StartX;

                WHILE @EndX <= @MatrixSize - 1
                BEGIN

                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM [QR].[Module]
                        WHERE 1 = 1
                           AND [X] BETWEEN @StartX AND @EndX
                           AND [Y] BETWEEN @StartY AND @EndY
                           AND [ModuleType] <> 'Data'
                    )
                    BEGIN
                        SET @Area =
                            (@EndX - @StartX + 1)
                          * (@EndY - @StartY + 1);

                        IF @Area > @BestArea
                        BEGIN
                            SET @BestArea   = @Area;
                            SET @BestStartX = @StartX;
                            SET @BestStartY = @StartY;
                            SET @BestEndX   = @EndX;
                            SET @BestEndY   = @EndY;
                        END
                    END

                    SET @EndX = @EndX + 1;
                END

                SET @EndY = @EndY + 1;
            END

            SET @StartX = @StartX + 1;
        END

        SET @StartY = @StartY + 1;
    END

    DELETE
    FROM [QR].[LogoArea]
    WHERE [AreaName] = 'LargestFreeRectangle';

    INSERT INTO [QR].[LogoArea]
    (
          [AreaName]
        , [StartX]
        , [StartY]
        , [EndX]
        , [EndY]
        , [Width]
        , [Height]
        , [Area]
    )
    VALUES
    (
          'LargestFreeRectangle'
        , @BestStartX
        , @BestStartY
        , @BestEndX
        , @BestEndY
        , (@BestEndX - @BestStartX + 1)
        , (@BestEndY - @BestStartY + 1)
        , @BestArea
    );
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pGenerateSvg]                                         ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates the final SVG representation of the QR matrix.               ###
-- ###                                                                        ###
-- ### Supports:                                                              ###
-- ###   - Custom module sizes                                                ###
-- ###   - Quiet zones                                                        ###
-- ###   - Rounded data modules                                               ###
-- ###   - Custom foreground colors                                           ###
-- ###   - Custom background colors                                           ###
-- ###   - Multi-color logo rendering                                         ###
-- ###                                                                        ###
-- ### The generated SVG is returned as a Unicode string.                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                   Internal                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ModuleSize:                 Module size in SVG pixels                 ###
-- ### @QuietZone:                  Width of the surrounding quiet zone       ###
-- ###                              measured in modules.                      ###
-- ### @ForegroundColor:            Default color of dark QR modules          ###
-- ### @BackgroundColor:            SVG background color                      ###
-- ### @RoundDataModulesOnly:       Enables rounded rendering of data modules ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @Svg:                        Generated SVG document                    ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pGenerateSvg]
(
      @ModuleSize               INTEGER     = 10
    , @QuietZone                INTEGER     = 4
    , @ForegroundColor          CHAR(7)     = '#000000'
    , @BackgroundColor          CHAR(7)     = '#FFFFFF'
    , @RoundDataModulesOnly     BIT         = 1
    , @Svg                      NVARCHAR(MAX)        OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------------
    -- Parameter prüfen
    ------------------------------------------------------------------------
    IF @ModuleSize < 1
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'ModuleSize muss mindestens 1 sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: ModuleSize must be at least 1.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @QuietZone < 0
    BEGIN
        SET @ErrorMessage =
              N'QuietZone darf nicht negativ sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: QuietZone must not be negative.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    ------------------------------------------------------------------------
    -- Matrix prüfen
    ------------------------------------------------------------------------
    DECLARE @QrSize INT;

    SELECT
        @QrSize =
            MAX([X]) + 1
    FROM [QR].[Module];

    IF @QrSize IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix ist leer.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix is empty.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF
    (
        SELECT COUNT(*)
        FROM [QR].[Module]
    ) <> (@QrSize * @QrSize)
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix ist unvollständig.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix is incomplete.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE [IsBlack] IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix enthält noch undefinierte Module.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix still contains undefined modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    ------------------------------------------------------------------------
    -- Calculate Drawing Area
    ------------------------------------------------------------------------
    DECLARE @CanvasModules      INTEGER;
    DECLARE @CanvasPixels       INTEGER;

    SET @CanvasModules  = @QrSize + (@QuietZone * 2);
    SET @CanvasPixels   = @CanvasModules * @ModuleSize;

    ------------------------------------------------------------------------
    -- SVG Header
    ------------------------------------------------------------------------
    SET @Svg =
          '<svg xmlns="http://www.w3.org/2000/svg"'
        + ' width="'  + CONVERT(VARCHAR(20), @CanvasPixels) + '"'
        + ' height="' + CONVERT(VARCHAR(20), @CanvasPixels) + '"'
        + ' viewBox="0 0 '
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + ' '
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" shape-rendering="crispEdges">'

        + '<rect width="'
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" height="'
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" fill="'
        + @BackgroundColor
        + '"/>';

    ------------------------------------------------------------------------
    -- Generate QR Modules
    ------------------------------------------------------------------------
    DECLARE @Modules VARCHAR(MAX);

    SELECT
        @Modules =
            STRING_AGG
            (
                CONVERT
                (
                    VARCHAR(MAX),
                    CASE
                    ----------------------------------------------------------------
                    -- Optional round data modules
                    ----------------------------------------------------------------
                    WHEN @RoundDataModulesOnly = 1 AND [ModuleType] = 'Data'
                    THEN
                          '<circle cx="'
                        + CONVERT
                          (VARCHAR(20), (((CONVERT(FLOAT,[X]) + @QuietZone) * @ModuleSize) + (@ModuleSize / 2.0)))
                        + '" cy="'
                        + CONVERT
                          (VARCHAR(20),(((CONVERT(FLOAT,[Y]) + @QuietZone) * @ModuleSize) + (@ModuleSize / 2.0)))
                        + '" r="'
                        + CONVERT
                          (VARCHAR(20), @ModuleSize * 0.45)
                        + '" fill="'
                        + CASE
                            WHEN [ColorHex] IS NOT NULL
                                THEN [ColorHex]
                            WHEN [IsBlack] = 1
                                THEN @ForegroundColor
                            ELSE
                                @BackgroundColor
                        END
                        + '"/>'

                    ----------------------------------------------------------------
                    -- Normale Module
                    ----------------------------------------------------------------
                    ELSE
                          '<rect x="'
                        + CONVERT(VARCHAR(20), (CONVERT(INT,[X]) + @QuietZone) * @ModuleSize)
                        + '" y="'
                        + CONVERT(VARCHAR(20), (CONVERT(INT,[Y]) + @QuietZone) * @ModuleSize)
                        + '" width="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" height="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" fill="'
                        + CASE
                            WHEN [ColorHex] IS NOT NULL
                                THEN [ColorHex]
                            WHEN [IsBlack] = 1
                                THEN @ForegroundColor
                            ELSE
                                @BackgroundColor
                        END
                        + '"/>'
                END
            ),
            ''
        )
        WITHIN GROUP
        (
            ORDER BY [Y], [X]
        )
        FROM [QR].[Module]
        WHERE
            [IsBlack] = 1 OR [ColorHex] IS NOT NULL;

    SET @Svg = @Svg + ISNULL(@Modules, '') + '</svg>';
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pInitializeMatrix]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates an empty QR matrix for the selected version.                   ###
-- ### The procedure initializes [QR].[Module] and creates one record for     ###
-- ### every matrix coordinate.                                               ###
-- ### All modules are initially marked as undefined and are populated by     ###
-- ### subsequent matrix construction procedures.                             ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                     Internal                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:                QR version number                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pInitializeMatrix]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize INT;

    SET @MatrixSize =
        QR.fnGetMatrixSize(@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'EN: Invalid QR code version.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    DELETE
    FROM [QR].[Module];

    ;WITH [N] AS
    (
        SELECT 0 AS [N]

        UNION ALL

        SELECT [N] + 1
        FROM [N]
        WHERE [N] + 1 < @MatrixSize
    )
    INSERT INTO [QR].[Module]
    (
          [X]
        , [Y]
        , [IsBlack]
        , [ModuleType]
        , [ColorHex]
    )
    SELECT
          [X].[N]
        , [Y].[N]
        , NULL
        , NULL
        , NULL
    FROM [N] AS [X]
    CROSS JOIN [N] AS [Y]
    OPTION (MAXRECURSION 200);
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pPlaceDataBits]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places the final QR payload bit stream into the matrix.                ###
-- ### The procedure follows the standard QR zig-zag placement algorithm      ###
-- ### and skips all modules reserved for structural information.             ###
-- ### Remainder-bit validation is also performed.                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Bits:                        Final QR payload bit stream              ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pPlaceDataBits]
(
      @Bits             VARCHAR(MAX)
    , @VersionNumber    TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize         INTEGER;
    DECLARE @ExpectedBits       INTEGER;
    DECLARE @FreeModuleCount    INTEGER;
    DECLARE @BitPosition        INTEGER = 1;
    DECLARE @RightX             INTEGER;
    DECLARE @LeftX              INTEGER;
    DECLARE @Y                  INTEGER;
    DECLARE @Direction          INTEGER = -1;
    DECLARE @CurrentX           INTEGER;
    DECLARE @CurrentBit         BIT;
    DECLARE @ErrorMessage       NVARCHAR(300);

    -------------------------------------------------------------------------
    -- Parameter prüfen
    -------------------------------------------------------------------------
    IF @Bits IS NULL OR LEN(@Bits) = 0
    BEGIN
        SET @ErrorMessage =
              N'Der Bitstream darf nicht NULL sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: The bitstream must not be NULL.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @Bits LIKE '%[^01]%'
    BEGIN
        SET @ErrorMessage =
              N'Der Bitstream darf nur 0 und 1 enthalten.'
            + CHAR(13) + CHAR(10)
            + N'EN: The bitstream may contain only 0s and 1s.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -------------------------------------------------------------------------
    -- Determine the size of the matrix
    -------------------------------------------------------------------------
    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    IF @MatrixSize IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Die Matrix wurde noch nicht initialisiert.'
            + CHAR(13) + CHAR(10)
            + N'EN: The matrix has not yet been initialized.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -------------------------------------------------------------------------
    -- Determine the expected number of bits
    -------------------------------------------------------------------------
    SET @ExpectedBits = LEN(@Bits);

    -------------------------------------------------------------------------
    -- Check Available Data Modules
    -------------------------------------------------------------------------
    SELECT
        @FreeModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] IS NULL;

    IF @FreeModuleCount < @ExpectedBits
    BEGIN
        SET @ErrorMessage =
              N'Zu wenig freie Datenmodule für den Bitstream vorhanden.'
            + CHAR(13) + CHAR(10)
            + N'EN: There are not enough free data modules available for the bitstream.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -------------------------------------------------------------------------
    -- Start on the far right
    -------------------------------------------------------------------------
    SET @RightX = @MatrixSize - 1;

    -------------------------------------------------------------------------
    -- Zigzag Layout
    -------------------------------------------------------------------------
    WHILE @RightX > 0
    BEGIN

        ---------------------------------------------------------------------
        -- Skip the “Timing” column
        ---------------------------------------------------------------------
        IF @RightX = 6 SET @RightX = 5;
        SET @LeftX = @RightX - 1;

        ---------------------------------------------------------------------
        -- Set the direction
        ---------------------------------------------------------------------
        IF @Direction = -1
            SET @Y = @MatrixSize - 1;
        ELSE
            SET @Y = 0;

        ---------------------------------------------------------------------
        -- Scroll through the current two-column layout
        ---------------------------------------------------------------------
        WHILE @Y BETWEEN 0 AND (@MatrixSize - 1)
        BEGIN

            -----------------------------------------------------------------
            -- Right Column
            -----------------------------------------------------------------
            SET @CurrentX = @RightX;

            IF EXISTS
            (
                SELECT 1
                FROM [QR].[Module]
                WHERE
                        [X] = @CurrentX
                    AND [Y] = @Y
                    AND [ModuleType] IS NULL
            )
            BEGIN

                IF @BitPosition > @ExpectedBits
                BEGIN
                    BREAK;
                END;

                SET @CurrentBit =
                    CONVERT(BIT,
                        SUBSTRING
                        (
                            @Bits,
                            @BitPosition,
                            1
                        )
                    );

                UPDATE [QR].[Module]
                SET
                      [IsBlack]    = @CurrentBit
                    , [ModuleType] = 'Data'
                WHERE
                        [X] = @CurrentX
                    AND [Y] = @Y;

                SET @BitPosition += 1;
            END;

            -----------------------------------------------------------------
            -- Left Column
            -----------------------------------------------------------------
            SET @CurrentX = @LeftX;

            IF EXISTS
            (
                SELECT 1
                FROM [QR].[Module]
                WHERE
                        [X] = @CurrentX
                    AND [Y] = @Y
                    AND [ModuleType] IS NULL
            )
            BEGIN

                IF @BitPosition > @ExpectedBits
                BEGIN
                    BREAK;
                END;

                SET @CurrentBit =
                    CONVERT(BIT,
                        SUBSTRING
                        (
                            @Bits,
                            @BitPosition,
                            1
                        )
                    );

                UPDATE [QR].[Module]
                SET
                      [IsBlack]    = @CurrentBit
                    , [ModuleType] = 'Data'
                WHERE
                        [X] = @CurrentX
                    AND [Y] = @Y;

                SET @BitPosition += 1;
            END;

            SET @Y = @Y + @Direction;
        END;

        ---------------------------------------------------------------------
        -- Next two-column page
        ---------------------------------------------------------------------
        SET @RightX         = @RightX - 2;
        SET @Direction      = @Direction * -1;
    END;

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = 0
        , [ModuleType] = 'Remainder'
    WHERE [ModuleType] IS NULL;

    DECLARE @ExpectedRemainderBits INT;

    SELECT
        @ExpectedRemainderBits = [RemainderBits]
    FROM [QR].[VersionRemainderBits]
    WHERE [VersionNumber] = @VersionNumber;

    IF
    (
        SELECT COUNT(*)
        FROM [QR].[Module]
        WHERE [ModuleType] = 'Remainder'
    )
    <> @ExpectedRemainderBits
    BEGIN
        SET @ErrorMessage =
              N'Falsche Anzahl Remainder Bits.'
            + CHAR(13) + CHAR(10)
            + N'EN: Incorrect number of remainder bits.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -------------------------------------------------------------------------
    -- Abschlusskontrolle
    -------------------------------------------------------------------------

    IF @BitPosition <= @ExpectedBits
    BEGIN
        SET @ErrorMessage =
              N'Es konnten nicht alle Bits platziert werden.'
            + CHAR(13) + CHAR(10)
            + N'EN: Not all bits could be placed.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pProjectLogoPattern]                                  ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Projects a logo stored in [QR].[LogoPattern] into the selected         ###
-- ### logo area of the QR matrix. The logo is automatically scaled to fit    ###
-- ### the target area while preserving the original aspect ratio. Source     ###
-- ### pixels are written to [QR].[LogoPlacement].                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @LogoName:               Logo identifier stored in [QR].[LogoPattern]  ###
-- ### @StartX:                 Left boundary of the target area              ###
-- ### @StartY:                 Upper boundary of the target area             ###
-- ### @Width:                  Width of the target area                      ###
-- ### @Height:                 Height of the target area                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pProjectLogoPattern]
(
      @LogoName VARCHAR(50)
    , @StartX   INT
    , @StartY   INT
    , @Width    INT
    , @Height   INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LogoWidth  INTEGER;
    DECLARE @LogoHeight INTEGER;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [QR].[LogoPattern]
        WHERE [LogoName] = @LogoName
    )
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Logo ' + @LogoName + N' wurde nicht gefunden.'
            + CHAR(13) + CHAR(10)
            + N'Logo ' + @LogoName + N' was not found.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
          @LogoWidth  = MAX([X]) + 1
        , @LogoHeight = MAX([Y]) + 1
    FROM [QR].[LogoPattern]
    WHERE [LogoName] = @LogoName;

    IF @LogoWidth IS NULL OR @LogoHeight IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Logo besitzt keine gültigen Pixeldaten.'
            + CHAR(13) + CHAR(10)
            + N'The logo does not contain valid pixel data.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @LogoWidth <= 0
       OR @LogoHeight <= 0
    BEGIN
        SET @ErrorMessage =
              N'Logo besitzt keine gültige Größe.'
            + CHAR(13) + CHAR(10)
            + N'The logo does not have a valid size.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    DELETE
    FROM [QR].[LogoPlacement]
    WHERE [LogoName] = @LogoName;

    ;WITH [TargetCells] AS
    (
        SELECT
              [X] = @StartX + [X].[N]
            , [Y] = @StartY + [Y].[N]
        FROM
        (
            SELECT TOP (@Width)
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
            FROM sys.objects
        ) AS X

        CROSS JOIN
        (
            SELECT TOP (@Height)
                   ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
            FROM sys.objects
        ) AS Y
    )

    INSERT INTO [QR].[LogoPlacement]
    (
          [LogoName]
        , [TargetX]
        , [TargetY]
        , [SourceX]
        , [SourceY]
        , [ColorClass]
    )
    SELECT
          @LogoName
        , [T].[X]
        , [T].[Y]
        , FLOOR([TX].[SourceX])
        , FLOOR([TY].[SourceY])
        , [P].[ColorClass]
    FROM [TargetCells]                                                                  AS [T]
    CROSS APPLY
    (
        SELECT ((([T].[X] - @StartX) + 0.5) * CONVERT(FLOAT,@LogoWidth) / @Width)       AS [SourceX]
    )                                                                                   AS [TX]

    CROSS APPLY
    (
        SELECT ((([T].[Y] - @StartY) + 0.5) * CONVERT(FLOAT,@LogoHeight) / @Height)     AS [SourceY]
    )                                                                                   AS [TY]
    INNER JOIN [QR].[LogoPattern]                                                       AS [P]
        ON 1 = 1
            AND [P].[LogoName] = @LogoName
            AND [P].[X] =
                CASE
                    WHEN FLOOR([TX].[SourceX]) >= @LogoWidth
                        THEN @LogoWidth - 1
                    ELSE FLOOR([TX].[SourceX])
                END
            AND [P].[Y] =
                CASE
                    WHEN FLOOR([TY].[SourceY]) >= @LogoHeight
                        THEN @LogoHeight - 1
                    ELSE FLOOR([TY].[SourceY])
                END
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pReserveFormatModules]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Reserves matrix locations required for QR format information.          ###
-- ### Reserved modules are protected from later payload placement.           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pReserveFormatModules]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize INT;

    SET @MatrixSize = [QR].[fnGetMatrixSize](@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'Invalid QR code version.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = NULL
        , [ModuleType] = 'Format'
    WHERE

        -- -----------------------------------------------------------
        -- First copy, top left
        -- ----------------------------------------------------------- */
        (X = 8 AND Y IN (0,1,2,3,4,5,7,8))          -- Note: Not 6, because that's where the sync line is
        OR
        (Y = 8 AND X IN (0,1,2,3,4,5,7,8))          -- Note: Not 6, because that's where the sync line is

        -- -----------------------------------------------------------
        -- Second copy, top right
        -- -----------------------------------------------------------
        OR
        (
                Y = 8
            AND X BETWEEN (@MatrixSize - 8)
                      AND (@MatrixSize - 1)
        )

        -- -----------------------------------------------------------
        -- third copy, bottom left
        -- -----------------------------------------------------------
        OR
        (
                X = 8
            AND Y BETWEEN (@MatrixSize - 7)
                      AND (@MatrixSize - 1)
        );
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSelectBestMask]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Evaluates all eight QR mask patterns and selects the mask with the     ###
-- ### lowest penalty score.                                                  ###
-- ### After selection, the corresponding format information is written       ###
-- ### to the QR matrix.                                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                  Internal                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ErrorCorrectionLevel:      QR error correction level                  ###
-- ### @VersionNumber:             QR version number                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSelectBestMask]
    @ErrorCorrectionLevel CHAR(1)       = 'M',
    @VersionNumber        TINYINT       = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- ========================================================================
    -- Determine the Best QR Mask
    -- ------------------------------------------------------------------------
    -- Prerequisites:
    --     - 208 data modules exist
    --     - These data modules are still unmasked
    --     - The format modules are reserved
    --     - Format modules have IsBlack = NULL
    --
    -- Procedure:
    --     1. Save the original state of the 208 data modules
    --     2. Test masks 0 through 7
    --     3. Set the respective format information
    --     4. Calculate penalty rules 1 through 4
    --     5. Determine the lowest total penalty
    --     6. Restore the original data
    --     7. Apply the winning mask
    --     8. Set the appropriate format information
    -- ========================================================================

    -- ------------------------------------------------------------------------
    -- Check Matrix State
    -- ------------------------------------------------------------------------
    DECLARE @DataModuleCount        INTEGER;
    DECLARE @FormatModuleCount      INTEGER;

    SELECT
        @DataModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF @DataModuleCount = 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Es wurden keine Datenmodule gefunden.'
            + CHAR(13) + CHAR(10)
            + N'No data modules were found.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
        @FormatModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] = 'Format';


    IF @FormatModuleCount <> 30
    BEGIN
        SET @ErrorMessage =
              N'Es muessen exakt 30 reservierte Formatmodule vorhanden sein.'
            + CHAR(13) + CHAR(10)
            + N'There must be exactly 30 reserved format modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- ========================================================================
    -- Save the unmasked initial state
    -- ======================================================================== 
    DECLARE @OriginalData TABLE
    (
        [X]                 TINYINT NOT NULL,
        [Y]                 TINYINT NOT NULL,
        [IsBlack]           BIT     NOT NULL,

        PRIMARY KEY
        (
            [Y],
            [X]
        )
    );

    INSERT INTO @OriginalData
    (
        [X],
        [Y],
        [IsBlack]
    )
    SELECT
        [X],
        [Y],
        [IsBlack]
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF (SELECT COUNT(*) FROM @OriginalData) <> @DataModuleCount
    BEGIN
        SET @ErrorMessage =
              N'Der unmaskierte Datenzustand konnte nicht vollständig gesichert werden.'
            + CHAR(13) + CHAR(10)
            + N'The unmasked data state could not be fully backed up.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- ========================================================================
    -- Results for the eight candidates
    -- ======================================================================== */
    DECLARE @MaskResults TABLE
    (
        [MaskPattern]           TINYINT NOT NULL PRIMARY KEY,
        [PenaltyRule1]          INTEGER NOT NULL,
        [PenaltyRule2]          INTEGER NOT NULL,
        [PenaltyRule3]          INTEGER NOT NULL,
        [PenaltyRule4]          INTEGER NOT NULL,
        [TotalPenalty]          INTEGER NOT NULL
    );

    DECLARE @MaskPattern        TINYINT = 0;
    DECLARE @P1                 INTEGER;
    DECLARE @P2                 INTEGER;
    DECLARE @P3                 INTEGER;
    DECLARE @P4                 INTEGER;
    DECLARE @Total              INTEGER;

       -- ========================================================================
       -- Test Masks 0 through 7
       -- ========================================================================
    WHILE @MaskPattern <= 7
    BEGIN

        -- --------------------------------------------------------------------
        -- Restore original, unmasked data
        -- --------------------------------------------------------------------
        UPDATE [M]
        SET
            [IsBlack] = O.[IsBlack]
        FROM [QR].[Module]                                  AS [M]
        INNER JOIN @OriginalData                            AS [O]
            ON 1 = 1
                AND [O].[X] = M.[X]
                AND [O].[Y] = M.[Y]
        WHERE
            [M].[ModuleType] IN ('Data', 'Remainder');

        -- --------------------------------------------------------------------
        -- Reset Format Information for This Candidate
        -- --------------------------------------------------------------------
        UPDATE [QR].[Module]
        SET
            [IsBlack] = NULL
        WHERE
            [ModuleType] = 'Format';

        -- --------------------------------------------------------------------
        -- Apply the candidate mask
        -- --------------------------------------------------------------------
        EXEC [QR].[pApplyMask]
            @MaskPattern = @MaskPattern;

        -- --------------------------------------------------------------------
        -- Set the appropriate format information
        -- --------------------------------------------------------------------
        EXEC [QR].[pSetFormatInformation]
            @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
            @MaskPattern            = @MaskPattern,
            @VersionNumber          = @VersionNumber;

        -- --------------------------------------------------------------------
        -- Calculate Penalty
        -- --------------------------------------------------------------------
        SET @P1         = 0;
        SET @P2         = 0;
        SET @P3         = 0;
        SET @P4         = 0;
        SET @Total      = 0;

        EXEC [QR].[pCalculateMaskPenalty]
            @OutPenaltyRule1 = @P1      OUTPUT,
            @OutPenaltyRule2 = @P2      OUTPUT,
            @OutPenaltyRule3 = @P3      OUTPUT,
            @OutPenaltyRule4 = @P4      OUTPUT,
            @OutTotalPenalty = @Total   OUTPUT,
            @ReturnResultSet = 0;

        -- --------------------------------------------------------------------
        -- Save Results
        -- --------------------------------------------------------------------
        INSERT INTO @MaskResults
        (
            [MaskPattern],
            [PenaltyRule1],
            [PenaltyRule2],
            [PenaltyRule3],
            [PenaltyRule4],
            [TotalPenalty]
        )
        VALUES
        (
            @MaskPattern,
            @P1,
            @P2,
            @P3,
            @P4,
            @Total
        );

        SET @MaskPattern = @MaskPattern + 1;
    END;

    -- ========================================================================
    -- Determining the Best Mask
    -- The mask with the lowest penalty score wins.
    -- If the scores are identical, we use the mask with the smaller number,
    -- so that the result remains deterministic.
    -- ========================================================================
    DECLARE @BestMaskPattern    TINYINT;
    DECLARE @BestPenalty        INTEGEr;

    SELECT TOP (1)
        @BestMaskPattern    = [MaskPattern],
        @BestPenalty        = [TotalPenalty]
    FROM @MaskResults
    ORDER BY
        [TotalPenalty],
        [MaskPattern];

    -- ========================================================================
    -- Restore the unmasked state one last time
    -- ========================================================================
    UPDATE [M]
    SET
        [IsBlack] = [O].[IsBlack]
    FROM [QR].[Module]                                      AS [M]
    INNER JOIN @OriginalData                                AS [O]
        ON 1 = 1
            AND [O].[X] = [M].[X]
            AND [O].[Y] = [M].[Y]
    WHERE
        [M].[ModuleType] IN ('Data', 'Remainder');

    UPDATE [QR].[Module]
    SET
        [IsBlack] = NULL
    WHERE
        [ModuleType] = 'Format';

    -- ========================================================================
    -- Apply the Winner Mask
    -- ========================================================================
    EXEC [QR].[pApplyMask]
        @MaskPattern = @BestMaskPattern;

    EXEC [QR].[pSetFormatInformation]
        @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
        @MaskPattern            = @BestMaskPattern,
        @VersionNumber          = @VersionNumber;

    -- ========================================================================
    -- Final Inspection
    --=========================================================================
    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE [IsBlack] IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'Nach der Maskenauswahl enthaelt die Matrix noch undefinierte Module.'
            + CHAR(13) + CHAR(10)
            + N'After selecting the masks, the matrix still contains undefined modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetDarkModule]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places the mandatory dark module defined by the QR specification.      ###
-- ### The dark module is located at a fixed position and is present in all   ###
-- ### QR versions.                                                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetDarkModule]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DarkModuleY INT;

    SET @DarkModuleY = (4 * @VersionNumber) + 9;

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = 1
        , [ModuleType] = 'Dark'
    WHERE
            [X] = 8
        AND [Y] = @DarkModuleY;

    IF @@ROWCOUNT <> 1
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Dark Module konnte nicht gesetzt werden.'
            + CHAR(13) + CHAR(10)
            + N'The Dark Module could not be set.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetFinderPattern]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places a QR finder pattern at the specified matrix position.           ###
-- ### Finder patterns allow scanners to detect orientation and position      ###
-- ### of the QR code.                                                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                  Internal                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @StartX:                    Left coordinate of the finder pattern      ###
-- ### @StartY:                    Upper coordinate of the finder pattern     ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetFinderPattern]
    @StartX     TINYINT,
    @StartY     TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Each Finder pattern measures 7x7
    -- with a black center, white interior, and black border
    UPDATE [M]
    SET
        [IsBlack] =
            CASE
                WHEN
                       [M].[X] = @StartX
                    OR [M].[X] = @StartX + 6
                    OR [M].[Y] = @StartY
                    OR [M].[Y] = @StartY + 6
                THEN 1
                WHEN
                        [M].[X] BETWEEN @StartX + 2 AND @StartX + 4
                    AND [M].[Y] BETWEEN @StartY + 2 AND @StartY + 4
                THEN 1
                ELSE 0
            END,
        [ModuleType] = 'Finder'
    FROM [QR].[Module]                                          AS [M]
    WHERE
        1 = 1
            AND [M].[X]   BETWEEN @StartX AND @StartX + 6
            AND [M].[Y]   BETWEEN @StartY AND @StartY + 6;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetFormatInformation]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Writes QR format information into reserved matrix locations.           ###
-- ###                                                                        ###
-- ### Format information contains:                                           ###
-- ###   - Error correction level                                             ###
-- ###   - Selected mask pattern                                              ###
-- ###                                                                        ###
-- ### The procedure is executed after mask selection.                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ErrorCorrectionLevel:        QR error correction level                ###
-- ### @MaskPattern:                 Selected mask pattern (0-7)              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetFormatInformation]
    @ErrorCorrectionLevel   CHAR(1),
    @MaskPattern            TINYINT,
    @VersionNumber          TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FormatBits     CHAR(15);
    DECLARE @MatrixSize     INTEGER;
    DECLARE @ErrorMessage   NVARCHAR(300);
    -- ------------------------------------------------------------------------
    -- Set Format Information for QR Version 1-M
    -- The 15 format bits contain:
    --     Error Correction Level = M
    --     Mask Pattern           = 0 through 7
    --     BCH Error Correction
    -- The format information is written twice into the matrix.
    -- ------------------------------------------------------------------------
    IF @MaskPattern IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Das Mask Pattern darf nicht NULL sein.'
            + CHAR(13) + CHAR(10)
            + N'The mask pattern cannot be NULL.'
        RAISERROR (@ErrorMessage, 16, 1)
    END

    IF @MaskPattern NOT BETWEEN 0 AND 7
    BEGIN
        SET @ErrorMessage =
              N'Das Mask Pattern muss zwischen 0 und 7 liegen.'
            + CHAR(13) + CHAR(10)
            + N'The mask pattern must be between 0 and 7.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SET @MatrixSize = [QR].[fnGetMatrixSize](@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'Invalid QR code version.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SET @FormatBits =
        [QR].[fnGetFormatBits_V1]
        (
              @ErrorCorrectionLevel
            , @MaskPattern
        );

    IF @FormatBits IS NULL
        OR LEN(@FormatBits) <> 15
    BEGIN
        SET @ErrorMessage =
              N'Die Format Information konnte nicht erzeugt werden.'
            + CHAR(13) + CHAR(10)
            + N'The format information could not be generated.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- --------------------------------------------------------------------------
    -- Target Positions
    -- BitIndex:
    --      0 = least significant bit of the 15-bit format value
    --      14 = most significant bit
    --  Since fnGetFormatBits_V1 returns the string with the MSB first:
    --      SUBSTRING(@FormatBits, 15 - BitIndex, 1)
    -- --------------------------------------------------------------------------
    DECLARE @FormatModules TABLE
    (
        [CopyNumber] TINYINT NOT NULL,
        [BitIndex]   TINYINT NOT NULL,
        [X]          TINYINT NOT NULL,
        [Y]          TINYINT NOT NULL,

        PRIMARY KEY
        (
            [CopyNumber],
            [BitIndex]
       )
    );

    -- --------------------------------------------------------------------------
    -- First copy: around the Finder in the upper-left corner
    -- --------------------------------------------------------------------------
    INSERT INTO @FormatModules
    (
        [CopyNumber],
        [BitIndex],
        [X],
        [Y]
    )
    VALUES
        (1,  0,  8,  0),        (1,  1,  8,  1),        (1,  2,  8,  2),
        (1,  3,  8,  3),        (1,  4,  8,  4),        (1,  5,  8,  5),
        (1,  6,  8,  7),        (1,  7,  8,  8),        (1,  8,  7,  8),
        (1,  9,  5,  8),        (1, 10,  4,  8),        (1, 11,  3,  8),
        (1, 12,  2,  8),        (1, 13,  1,  8),        (1, 14,  0,  8);
    
    -- --------------------------------------------------------------------------
    -- Second copy:        top right and bottom left
    -- --------------------------------------------------------------------------
    INSERT INTO @FormatModules
    (
          [CopyNumber]
        , [BitIndex]
        , [X]
        , [Y]
    )
    VALUES
          (2, 0, @MatrixSize - 1, 8)        , (2, 1, @MatrixSize - 2, 8)
        , (2, 2, @MatrixSize - 3, 8)        , (2, 3, @MatrixSize - 4, 8)
        , (2, 4, @MatrixSize - 5, 8)        , (2, 5, @MatrixSize - 6, 8)
        , (2, 6, @MatrixSize - 7, 8)        , (2, 7, @MatrixSize - 8, 8)
        , (2, 8, 8, @MatrixSize - 7)        , (2, 9, 8, @MatrixSize - 6)
        , (2,10, 8, @MatrixSize - 5)        , (2,11, 8, @MatrixSize - 4)
        , (2,12, 8, @MatrixSize - 3)        , (2,13, 8, @MatrixSize - 2)
        , (2,14, 8, @MatrixSize - 1);

    DECLARE @ReservedFormatModuleCount INTEGER;

    SELECT
        @ReservedFormatModuleCount = COUNT(*)
    FROM @FormatModules AS F
    INNER JOIN [QR].[Module] AS M
        ON 1 = 1
            AND [M].[X] = [F].[X]
            AND [M].[Y] = [F].[Y]
    WHERE
        [M].[ModuleType] = 'Format';

    IF @ReservedFormatModuleCount <> 30
    BEGIN
        SET @ErrorMessage =
              N'Die erwarteten 30 reservierten Formatmodule wurden nicht gefunden.'
            + CHAR(13) + CHAR(10)
            + N'The expected 30 reserved format modules were not found.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- --------------------------------------------------------------------------
    -- Write Format Bits
    -- --------------------------------------------------------------------------
    UPDATE [M]
    SET
        [IsBlack] =
            CONVERT
            (
                BIT,
                SUBSTRING
                (
                    @FormatBits,
                    15 - CONVERT(INT, [F].[BitIndex]),
                    1
                )
            )
    FROM [QR].[Module]                                                  AS [M]
    INNER JOIN @FormatModules                                           AS [F]
        ON 1 = 1
            AND [F].[X] = [M].[X]
            AND [F].[Y] = [M].[Y];

    -- --------------------------------------------------------------------------
    -- Abschlusskontrolle
    -- --------------------------------------------------------------------------
    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE 1 = 1
            AND [ModuleType]    = 'Format'
            AND [IsBlack]       IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'Nicht alle Formatmodule wurden gesetzt.'
            + CHAR(13) + CHAR(10)
            + N'Not all format modules have been set.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetSeparator]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places the separator modules surrounding a QR finder pattern.          ###
-- ###                                                                        ###
-- ### Separators form a one-module-wide white border around each finder      ###
-- ### pattern and prevent adjacent QR structures from interfering with       ###
-- ### reliable pattern detection during scanning.                            ###
-- ###                                                                        ###
-- ### Separator modules are defined by the QR specification and are          ###
-- ### considered fixed structural elements of the QR matrix.                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:           Internal                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @StartX:             Left coordinate of the associated finder pattern  ###
-- ### @StartY:             Upper coordinate of the associated finder pattern ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Notes:                                                                 ###
-- ###   The separator is placed around the corresponding finder pattern      ###
-- ###   and reserves matrix cells that must not be used for payload data.    ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetSeparator]
    @StartX     TINYINT,
    @StartY     TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE M
    SET
        [IsBlack]    = 0,
        [ModuleType] = 'Separator'
    FROM [QR].[Module] AS [M]
    WHERE
        (
                [M].[X] BETWEEN @StartX - 1 AND @StartX + 7
            AND [M].[Y] BETWEEN @StartY - 1 AND @StartY + 7
        )
        AND NOT
        (
                [M].[X] BETWEEN @StartX AND @StartX + 6
            AND [M].[Y] BETWEEN @StartY AND @StartY + 6
        );
END;
GO

-- ##############################################################################
-- ### Procedure: [QR].[pSetTimingPatterns]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places the horizontal and vertical timing patterns.                    ###
-- ### Timing patterns allow scanners to determine module spacing and         ###
-- ### matrix alignment.                                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:             None                                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE OR ALTER PROCEDURE [QR].[pSetTimingPatterns]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize INT;

    SET @MatrixSize = [QR].[fnGetMatrixSize](@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'Invalid QR code version.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- Horizontal
    UPDATE [QR].[Module]
    SET
        [IsBlack] =
            CASE
                WHEN [X] % 2 = 0 THEN 1
                ELSE 0
            END,
        [ModuleType] = 'Timing'
    WHERE
            [Y] = 6
        AND [X] BETWEEN 8 AND (@MatrixSize - 9);

    -- Vertical
    UPDATE [QR].[Module]
    SET
        [IsBlack] =
            CASE
                WHEN [Y] % 2 = 0 THEN 1
                ELSE 0
            END,
        [ModuleType] = 'Timing'
    WHERE
            [X] = 6
        AND [Y] BETWEEN 8 AND (@MatrixSize - 9);

END;
GO







-- ##############################################################################
-- ### Function: [QR].[fnGaloisMultiply]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Multiplies two values in the finite field GF(256).                     ###
-- ###                                                                        ###
-- ### The implementation uses logarithmic and exponent lookup tables         ###
-- ### instead of direct polynomial multiplication.                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @A:                          First operand                             ###
-- ### @B:                          Second operand                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Product of @A and @B in GF(256)                                        ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnGaloisMultiply]
(
      @A            INTEGER
    , @B            INTEGER
)
RETURNS INTEGER
AS
BEGIN

    IF @A = 0 RETURN 0;
    IF @B = 0 RETURN 0;

    DECLARE @LogA           INTEGER
    DECLARE @LogB           INTEGER
    DECLARE @Result         INTEGER;

    SELECT
        @LogA = [LogValue]
    FROM [QR].[GaloisLog]
    WHERE [Value] = @A;

    SELECT
        @LogB = [LogValue]
    FROM [QR].[GaloisLog]
    WHERE [Value] = @B;

    SELECT
        @Result = [Value]
    FROM [QR].[GaloisExp]
    WHERE [Exponent] = @LogA + @LogB;

    RETURN @Result;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnBinaryByteToInt]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts an 8-bit binary string into its integer representation.       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @Binary:                    8-bit binary string                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                    Integer value between 0 and 255            ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnBinaryByteToInt]
(
    @Bits CHAR(8)
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Value INT;

    SET @Value =
          CASE SUBSTRING(@Bits, 1, 1) WHEN '1' THEN 128 ELSE 0 END
        + CASE SUBSTRING(@Bits, 2, 1) WHEN '1' THEN  64 ELSE 0 END
        + CASE SUBSTRING(@Bits, 3, 1) WHEN '1' THEN  32 ELSE 0 END
        + CASE SUBSTRING(@Bits, 4, 1) WHEN '1' THEN  16 ELSE 0 END
        + CASE SUBSTRING(@Bits, 5, 1) WHEN '1' THEN   8 ELSE 0 END
        + CASE SUBSTRING(@Bits, 6, 1) WHEN '1' THEN   4 ELSE 0 END
        + CASE SUBSTRING(@Bits, 7, 1) WHEN '1' THEN   2 ELSE 0 END
        + CASE SUBSTRING(@Bits, 8, 1) WHEN '1' THEN   1 ELSE 0 END;
    RETURN @Value;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnByteToBinary]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts a numeric byte value into an 8-bit binary string.             ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @Value:                      Byte value between 0 and 255              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### 8-bit binary representation                                            ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnByteToBinary]
(
    @Value INTEGER
)
RETURNS CHAR(8)
AS
BEGIN

    RETURN
          CASE WHEN @Value & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   1 =   1 THEN '1' ELSE '0' END;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnGetFormatBits_V1]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates the 15-bit QR format information string for the specified    ###
-- ### error correction level and mask pattern.                               ###
-- ###                                                                        ###
-- ### The generated value contains BCH error protection as required by the   ###
-- ### QR specification and is written into the reserved format information   ###
-- ### modules of the QR matrix.                                              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### @MaskPattern:                 Selected mask pattern (0-7)              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Complete QR format information bit string                              ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnGetFormatBits_V1]
(
    @ErrorCorrectionLevel   CHAR(1),
    @MaskPattern            TINYINT
)
RETURNS CHAR(15)
AS
BEGIN
    -- ------------------------------------------------------------------------
    -- QR Format Information
    -- Fixed:                Error Correction Level = M
    -- Variable:             Mask Pattern = 0 through 7
    -- Format Data:          EE MMM
    --     EE  = Error Correction Level
    --     MMM = Mask Pattern
    -- For M:                EE = 00
    -- BCH:                  Generator Polynomial = 0x537
    -- Final QR Format Mask: 0x5412
    -- ------------------------------------------------------------------------
    IF @MaskPattern IS NULL                             RETURN NULL;
    IF @MaskPattern > 7                                 RETURN NULL;
    IF @ErrorCorrectionLevel NOT IN ('L','M','Q','H')   RETURN NULL;

    DECLARE @FormatData         INT;
    DECLARE @Value              INT;
    DECLARE @Remainder          INT;
    DECLARE @Generator          INT = 1335;  -- 0x537
    DECLARE @FormatMask         INT = 21522; -- 0x5412
    DECLARE @Bit                INT;
    DECLARE @FormatValue        INT;
    DECLARE @Result             CHAR(15);

    -- ------------------------------------------------------------------------
    -- 5 Format Data Bits
    -- Error Correction Level M: 00
    -- Thus, the lower three bits correspond directly to the mask pattern.
    -- ------------------------------------------------------------------------
    DECLARE @ECLBits INT;

    SET @ECLBits =
        CASE @ErrorCorrectionLevel
            WHEN 'L' THEN 1   -- 01
            WHEN 'M' THEN 0   -- 00
            WHEN 'Q' THEN 3   -- 11
            WHEN 'H' THEN 2   -- 10
            ELSE NULL
        END;

    IF @ECLBits IS NULL RETURN NULL;

    SET @FormatData = (@ECLBits * 8) + @MaskPattern;

    -- ------------------------------------------------------------------------
    -- Make room for 10 BCH bits
    --     FormatData << 10
    -- ------------------------------------------------------------------------
    SET @Value = @FormatData * 1024;
    SET @Remainder = @Value;

    -- ------------------------------------------------------------------------
    -- Polynomdivision ueber GF(2)
    -- ------------------------------------------------------------------------
    -- Generator:
    --     10100110111
    --     0x537
    -- The generator has a degree of 10.
    -- Therefore, we start at the highest possible bit, bit 14,
    -- and work down to bit 10.
    -- ------------------------------------------------------------------------
    SET @Bit = 14;

    WHILE @Bit >= 10
    BEGIN
        IF (@Remainder & POWER(2, @Bit)) <> 0
        BEGIN
            SET @Remainder = @Remainder ^ (@Generator * POWER(2, @Bit - 10));
        END;

        SET @Bit = @Bit - 1;
    END;

    -- ------------------------------------------------------------------------
    -- The lower 10 bits are the BCH remainder.
    -- Format code before QR masking:
    --     5 data bits + 10 BCH bits    
    -- ------------------------------------------------------------------------
    SET @FormatValue =  (@FormatData * 1024) + @Remainder;

    -- ------------------------------------------------------------------------
    -- Apply QR-specific format mask: 0x5412
    -- ------------------------------------------------------------------------
    SET @FormatValue = @FormatValue ^ @FormatMask;

    -- ------------------------------------------------------------------------
    -- Convert a numerical value to exactly 15 bits
    -- Bit 14 first, bit 0 last.
    -- ------------------------------------------------------------------------
    SET @Result =
          CASE WHEN (@FormatValue & 16384) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  8192) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  4096) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  2048) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  1024) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   512) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   256) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   128) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    64) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    32) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    16) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     8) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     4) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     2) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     1) <> 0 THEN '1' ELSE '0' END;
    RETURN @Result;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnPadDataBits_V1]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Applies QR payload padding according to the QR specification.          ###
-- ###                                                                        ###
-- ### The function appends:                                                  ###
-- ###   - Terminator bits                                                    ###
-- ###   - Zero padding bits                                                  ###
-- ###   - Alternating pad codewords                                          ###
-- ###                                                                        ###
-- ### until the required payload size for the selected QR version and        ###
-- ### error correction level has been reached.                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @BitStream:                   Encoded QR payload bit stream            ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ###   Fully padded QR payload bit stream.                                  ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnPadDataBits_V1]
(
    @DataBits           VARCHAR(MAX),
    @DataCodewords      INTEGER
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Result             VARCHAR(MAX);
    DECLARE @MissingBits        INTEGER;
    DECLARE @TerminatorLength   INTEGER;
    DECLARE @BytePaddingLength  INTEGER;
    DECLARE @UseEC              BIT;

    SET @Result = @DataBits;

    IF @Result IS NULL                          RETURN NULL;
    IF @Result LIKE '%[^01]%'                   RETURN NULL;
    IF LEN(@Result) > (@DataCodewords * 8)      RETURN NULL;

    -- Terminator
    SET @MissingBits            = (@DataCodewords * 8) - LEN(@Result);
    SET @TerminatorLength       =
        CASE
            WHEN @MissingBits >= 4 THEN 4
            ELSE @MissingBits
        END;
    SET @Result = @Result + REPLICATE('0', @TerminatorLength);

    -- Fill to the byte limit
    SET @BytePaddingLength  = (8 - (LEN(@Result) % 8)) % 8;
    SET @Result             = @Result + REPLICATE('0', @BytePaddingLength);

    -- Pad Codewords EC and 11
    SET @UseEC = 1;
    
    DECLARE @TargetLength   INTEGER;
    SET @TargetLength   = @DataCodewords * 8;
    SET @MissingBits    = @TargetLength - LEN(@Result);

    WHILE LEN(@Result) < @TargetLength
    BEGIN
        SET @Result = @Result
            + CASE
                  WHEN @UseEC = 1
                      THEN '11101100'
                  ELSE '00010001'
              END;
        SET @UseEC =
            CASE
                WHEN @UseEC = 1 THEN 0
                ELSE 1
            END;
    END;

    RETURN @Result;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnGetMatrixSize]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the QR matrix size for a given version.                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:               QR version number.                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Matrix size in modules.                                                ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnGetMatrixSize]
(
    @VersionNumber TINYINT
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Result INTEGER;

    SELECT
        @Result = [MatrixSize]
    FROM [QR].[VersionDefinition]
    WHERE [VersionNumber] = @VersionNumber;

    RETURN ISNULL(@Result, 0)
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnGetDataCodewords]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the number of QR data codewords for a given version and        ###
-- ### error correction level.                                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:              QR version number                         ###
-- ### @ErrorCorrectionLevel:       QR error correction level (L, M, Q or H)  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Number of data codewords.                                              ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnGetDataCodewords]
(
      @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Result INTEGER;

    SELECT
        @Result = DataCodewords
    FROM [QR].[VersionCapacity]
    WHERE 1 = 1
        AND [VersionNumber]           = @VersionNumber
        AND [ErrorCorrectionLevel]    = @ErrorCorrectionLevel;

    RETURN @Result;
END;
GO

-- ##############################################################################
-- ### Function: [QR].[fnGetEccCodewords]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the number of Reed-Solomon error correction codewords for      ###
-- ### a given QR version and ECC level.                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:            QR version number                           ###
-- ### @ErrorCorrectionLevel:     QR error correction level (L, M, Q or H)    ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Number of ECC codewords                                                ###
-- ##############################################################################
CREATE OR ALTER FUNCTION [QR].[fnGetEccCodewords]
(
      @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
RETURNS INTEGER
AS
BEGIN

    DECLARE @Result             INTEGER;

    SELECT
        @Result = [EccCodewords]
    FROM [QR].[VersionCapacity]
    WHERE 1 = 1
        AND [VersionNumber]         = @VersionNumber
        AND [ErrorCorrectionLevel]  = @ErrorCorrectionLevel;

    RETURN @Result;
END;
GO







/*
SELECT CAST([Inhalt] AS XML) AS VollstaendigerText
FROM (
        SELECT TOP 1 [SVG].[SvgContent]         AS [Inhalt]
        FROM [QR].[GeneratedSvg]                AS [SVG]
        ORDER BY [SVG].[CreatedAt] DESC
    ) AS Dummy


-- Liste der letzten generierten QR-Codes
SELECT TOP(20)
FROM [QR].[vGeneratedSvgHistory]


DECLARE @Svg VARCHAR(MAX);

EXEC QR.pCreateColoredQrCode
      @Text                 = 'Hello World'
    , @LogoName             = 'TA'
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M'
    , @Svg                  = @Svg OUTPUT;

    SELECT @Svg

*/
