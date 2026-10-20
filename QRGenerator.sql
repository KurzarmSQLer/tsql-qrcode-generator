USE [Kopfnuesse]
GO

-- Schema anlegen, um diese Objekte sauber von anderen Aufgaben der Kopfnussreihe zu trennen
IF SCHEMA_ID(N'QR') IS NULL
    EXEC(N'CREATE SCHEMA [QR]');
GO


DROP TABLE IF EXISTS [QR].[DataCodeword];
GO

CREATE TABLE [QR].[DataCodeword]
(
      [Position] INT NOT NULL
    , [Value]    TINYINT NOT NULL

    CONSTRAINT [PK_QR_DataCodeword]
        PRIMARY KEY ([Position])
);
GO



IF OBJECT_ID('QR.GeneratedSvg') IS NULL
BEGIN
    CREATE TABLE QR.GeneratedSvg
    (
          [SvgID]                   BIGINT       IDENTITY(1,1)
        , [CreatedAt]               DATETIME2(0)                    NOT NULL
        , [VersionNumber]           TINYINT                         NULL
        , [SvgContent]              NVARCHAR(MAX)                   NOT NULL
        , [TextEncoded]             VARCHAR(255)                    NULL
        , [LogoName]                VARCHAR(50)                     NULL
        , [ErrorCorrectionLevel]    CHAR(1)                         NULL
        , [SvgLength]               INT                             NULL
        , [SvgHash]                 VARBINARY(32)                   NULL
        , [TextLength]              INT                             NULL
        , [InputHash]               VARBINARY(32)                   NULL
        CONSTRAINT [PK_QR_GeneratedSvg]
                PRIMARY KEY ([SvgID])
        );
END;
GO



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



-- Haupttabelle anlegen
DROP TABLE IF EXISTS [QR].[Module];
GO

-- Wir konzemntrieren uns zu Demo-Zwecken auf einen QR-Code der Größe 21x21
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


IF OBJECT_ID('QR.LogoArea') IS NULL
BEGIN
    CREATE TABLE [QR].[LogoArea]
    (
          [AreaName] VARCHAR(50) NOT NULL
        , [StartX]   TINYINT     NOT NULL
        , [StartY]   TINYINT     NOT NULL
        , [EndX]     TINYINT     NOT NULL
        , [EndY]     TINYINT     NOT NULL
        , [Width]    SMALLINT    NOT NULL
        , [Height]   SMALLINT    NOT NULL
        , [Area]     INT         NOT NULL

        CONSTRAINT [PK_QR_LogoArea]
            PRIMARY KEY ([AreaName])
    )
END;
GO


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
        /* --------------------------------------------------
           ECC = 10   (Level M)
           -------------------------------------------------- */
          (10,0,1)
        , (10,1,216)
        , (10,2,194)
        , (10,3,159)
        , (10,4,111)
        , (10,5,199)
        , (10,6,94)
        , (10,7,95)
        , (10,8,113)
        , (10,9,157)
        , (10,10,193)
        /* --------------------------------------------------
           ECC = 7   (Level L)
           -------------------------------------------------- */
        ,(7, 0,   1)
        ,(7, 1, 127)
        ,(7, 2, 122)
        ,(7, 3, 154)
        ,(7, 4, 164)
        ,(7, 5,  11)
        ,(7, 6,  68)
        ,(7, 7, 117)

        /* --------------------------------------------------
           ECC = 13  (Level Q)
           -------------------------------------------------- */
        ,(13, 0,   1)
        ,(13, 1, 137)
        ,(13, 2,  73)
        ,(13, 3, 227)
        ,(13, 4,  17)
        ,(13, 5, 177)
        ,(13, 6,  17)
        ,(13, 7,  52)
        ,(13, 8,  13)
        ,(13, 9,  46)
        ,(13,10,  43)
        ,(13,11,  83)
        ,(13,12, 132)
        ,(13,13, 120)

        /* --------------------------------------------------
           ECC = 17  (Level H)
           -------------------------------------------------- */
        ,(17, 0,   1)
        ,(17, 1, 119)
        ,(17, 2,  66)
        ,(17, 3,  83)
        ,(17, 4, 120)
        ,(17, 5, 119)
        ,(17, 6,  22)
        ,(17, 7, 197)
        ,(17, 8,  83)
        ,(17, 9, 249)
        ,(17,10,  41)
        ,(17,11, 143)
        ,(17,12, 134)
        ,(17,13,  85)
        ,(17,14,  53)
        ,(17,15, 125)
        ,(17,16,  99)
        ,(17,17,  79)


        /* --------------------------------------------------
           ECC = 18 
           -------------------------------------------------- */
        ,(18, 0,   1)
        ,(18, 1, 239)
        ,(18, 2, 251)
        ,(18, 3, 183)
        ,(18, 4, 113)
        ,(18, 5, 149)
        ,(18, 6, 175)
        ,(18, 7, 199)
        ,(18, 8, 215)
        ,(18, 9, 240)
        ,(18,10, 220)
        ,(18,11,  73)
        ,(18,12,  82)
        ,(18,13, 173)
        ,(18,14,  75)
        ,(18,15,  32)
        ,(18,16,  67)
        ,(18,17, 217)
        ,(18,18, 146)

        -- ECC = 15
        ,(15,0,1)
        ,(15,1,29)
        ,(15,2,196)
        ,(15,3,111)
        ,(15,4,163)
        ,(15,5,112)
        ,(15,6,74)
        ,(15,7,10)
        ,(15,8,105)
        ,(15,9,105)
        ,(15,10,139)
        ,(15,11,132)
        ,(15,12,151)
        ,(15,13,32)
        ,(15,14,134)
        ,(15,15,26)

        -- ECC = 16
        ,(16,0,1)
        ,(16,1,59)
        ,(16,2,13)
        ,(16,3,104)
        ,(16,4,189)
        ,(16,5,68)
        ,(16,6,209)
        ,(16,7,30)
        ,(16,8,8)
        ,(16,9,163)
        ,(16,10,65)
        ,(16,11,41)
        ,(16,12,229)
        ,(16,13,98)
        ,(16,14,50)
        ,(16,15,36)
        ,(16,16,59)

        -- ECC = 20
        ,(20,0,1)
        ,(20,1,152)
        ,(20,2,185)
        ,(20,3,240)
        ,(20,4,5)
        ,(20,5,111)
        ,(20,6,99)
        ,(20,7,6)
        ,(20,8,220)
        ,(20,9,112)
        ,(20,10,150)
        ,(20,11,69)
        ,(20,12,36)
        ,(20,13,187)
        ,(20,14,22)
        ,(20,15,228)
        ,(20,16,198)
        ,(20,17,121)
        ,(20,18,121)
        ,(20,19,165)
        ,(20,20,174)

        -- ECC = 22
        ,(22,0,1)
        ,(22,1,89)
        ,(22,2,179)
        ,(22,3,131)
        ,(22,4,176)
        ,(22,5,182)
        ,(22,6,244)
        ,(22,7,19)
        ,(22,8,189)
        ,(22,9,69)
        ,(22,10,40)
        ,(22,11,28)
        ,(22,12,137)
        ,(22,13,29)
        ,(22,14,123)
        ,(22,15,67)
        ,(22,16,253)
        ,(22,17,86)
        ,(22,18,218)
        ,(22,19,230)
        ,(22,20,26)
        ,(22,21,145)
        ,(22,22,245)

        -- ECC = 24
        ,(24,0,1)
        ,(24,1,122)
        ,(24,2,118)
        ,(24,3,169)
        ,(24,4,70)
        ,(24,5,178)
        ,(24,6,237)
        ,(24,7,216)
        ,(24,8,102)
        ,(24,9,115)
        ,(24,10,150)
        ,(24,11,229)
        ,(24,12,73)
        ,(24,13,130)
        ,(24,14,72)
        ,(24,15,61)
        ,(24,16,43)
        ,(24,17,206)
        ,(24,18,1)
        ,(24,19,237)
        ,(24,20,247)
        ,(24,21,127)
        ,(24,22,217)
        ,(24,23,144)
        ,(24,24,117)

        -- ECC = 26
        ,(26,0,1)
        ,(26,1,246)
        ,(26,2,51)
        ,(26,3,183)
        ,(26,4,4)
        ,(26,5,136)
        ,(26,6,98)
        ,(26,7,199)
        ,(26,8,152)
        ,(26,9,77)
        ,(26,10,56)
        ,(26,11,206)
        ,(26,12,24)
        ,(26,13,145)
        ,(26,14,40)
        ,(26,15,209)
        ,(26,16,117)
        ,(26,17,233)
        ,(26,18,42)
        ,(26,19,135)
        ,(26,20,68)
        ,(26,21,70)
        ,(26,22,144)
        ,(26,23,146)
        ,(26,24,77)
        ,(26,25,43)
        ,(26,26,94)

        -- ECC = 28
        ,(28,0,1)
        ,(28,1,252)
        ,(28,2,9)
        ,(28,3,28)
        ,(28,4,13)
        ,(28,5,18)
        ,(28,6,251)
        ,(28,7,208)
        ,(28,8,150)
        ,(28,9,103)
        ,(28,10,174)
        ,(28,11,100)
        ,(28,12,41)
        ,(28,13,167)
        ,(28,14,12)
        ,(28,15,247)
        ,(28,16,56)
        ,(28,17,117)
        ,(28,18,119)
        ,(28,19,233)
        ,(28,20,127)
        ,(28,21,181)
        ,(28,22,100)
        ,(28,23,121)
        ,(28,24,147)
        ,(28,25,176)
        ,(28,26,74)
        ,(28,27,58)
        ,(28,28,197)

        -- ECC = 30
        ,(30,0,1)
        ,(30,1,212)
        ,(30,2,246)
        ,(30,3,77)
        ,(30,4,73)
        ,(30,5,195)
        ,(30,6,192)
        ,(30,7,75)
        ,(30,8,98)
        ,(30,9,5)
        ,(30,10,70)
        ,(30,11,103)
        ,(30,12,177)
        ,(30,13,22)
        ,(30,14,217)
        ,(30,15,138)
        ,(30,16,51)
        ,(30,17,181)
        ,(30,18,246)
        ,(30,19,72)
        ,(30,20,25)
        ,(30,21,18)
        ,(30,22,46)
        ,(30,23,228)
        ,(30,24,74)
        ,(30,25,216)
        ,(30,26,195)
        ,(30,27,11)
        ,(30,28,106)
        ,(30,29,130)
        ,(30,30,150)
END;
GO


DROP TABLE IF EXISTS QR.GaloisExp;
GO

CREATE TABLE QR.GaloisExp
(
      [Exponent] INT NOT NULL
    , [Value]    INT NOT NULL

    CONSTRAINT PK_QR_GaloisExp
        PRIMARY KEY ([Exponent])
);
GO

DROP TABLE IF EXISTS [QR].[GaloisLog];
GO

CREATE TABLE [QR].[GaloisLog]
(
      [Value]    INT NOT NULL
    , [LogValue] INT NOT NULL

    CONSTRAINT [PK_QR_GaloisLog]
        PRIMARY KEY ([Value])
);
GO


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

/* --------------------------------------------------------------------
   Version 2
   Zentren: 6,18
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(2,18,18);

/* --------------------------------------------------------------------
   Version 3
   Zentren: 6,22
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(3,22,22);

/* --------------------------------------------------------------------
   Version 4
   Zentren: 6,26
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(4,26,26);

/* --------------------------------------------------------------------
   Version 5
   Zentren: 6,30
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(5,30,30);

/* --------------------------------------------------------------------
   Version 6
   Zentren: 6,34
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(6,34,34);

/* --------------------------------------------------------------------
   Version 7
   Zentren: 6,22,38
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(7, 6,22),
(7, 6,38),
(7,22, 6),
(7,22,22),
(7,22,38),
(7,38, 6),
(7,38,22),
(7,38,38);

/* --------------------------------------------------------------------
   Version 8
   Zentren: 6,24,42
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(8, 6,24),
(8, 6,42),
(8,24, 6),
(8,24,24),
(8,24,42),
(8,42, 6),
(8,42,24),
(8,42,42);

/* --------------------------------------------------------------------
   Version 9
   Zentren: 6,26,46
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(9, 6,26),
(9, 6,46),
(9,26, 6),
(9,26,26),
(9,26,46),
(9,46, 6),
(9,46,26),
(9,46,46);

/* --------------------------------------------------------------------
   Version 10
   Zentren: 6,28,50
   -------------------------------------------------------------------- */
INSERT INTO QR.AlignmentPatternPosition VALUES
(10, 6,28),
(10, 6,50),
(10,28, 6),
(10,28,28),
(10,28,50),
(10,50, 6),
(10,50,28),
(10,50,50);
GO


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
VALUES
 (1 ,0)
,(2 ,7)
,(3 ,7)
,(4 ,7)
,(5 ,7)
,(6 ,7)
,(7 ,0)
,(8 ,0)
,(9 ,0)
,(10,0);
GO












CREATE OR ALTER VIEW [QR].[vGeneratedSvgHistory]
AS
SELECT
      [SvgID]
    , [CreatedAt]
    , [VersionNumber]
    , [ErrorCorrectionLevel]
    , [LogoName]
    , [TextLength]
    , [SvgLength]
    , [TextEncoded]
    , CONVERT(VARCHAR(64), [InputHash], 2)              AS [InputHashHex]
    , CONVERT(VARCHAR(64), [SvgHash],   2)              AS [SvgHashHex]
FROM [QR].[GeneratedSvg];
GO


CREATE OR ALTER PROCEDURE [QR].[pBuildDataBlocks]
(
      @VersionNumber        TINYINT
    , @ErrorCorrectionLevel CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [QR].[DataBlock];

    DECLARE
          @GroupNumber           INT
        , @BlockCount            INT
        , @DataCodewordsPerBlock INT;

    DECLARE
          @SourcePosition INT = 0
        , @BlockNumber    INT = 1;

    DECLARE C CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          GroupNumber
        , BlockCount
        , DataCodewordsPerBlock
    FROM QR.VersionBlockStructure
    WHERE
            VersionNumber        = @VersionNumber
        AND ErrorCorrectionLevel = @ErrorCorrectionLevel
    ORDER BY GroupNumber;

    OPEN C;

    FETCH NEXT FROM C
    INTO
          @GroupNumber
        , @BlockCount
        , @DataCodewordsPerBlock;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        DECLARE @CurrentBlock INT = 1;

        WHILE @CurrentBlock <= @BlockCount
        BEGIN

            DECLARE @BlockPosition INT = 0;

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
                    , Value
                FROM [QR].[DataCodeword]
                WHERE Position = @SourcePosition;

                SET @SourcePosition += 1;
                SET @BlockPosition += 1;
            END
            SET @BlockNumber += 1;
            SET @CurrentBlock += 1;
        END

        FETCH NEXT FROM [C]
        INTO
              @GroupNumber
            , @BlockCount
            , @DataCodewordsPerBlock;
    END
    CLOSE C;
    DEALLOCATE C;

    -----------------------------------------------------------------
    -- Kontrolle
    -----------------------------------------------------------------
    IF
    (
        SELECT COUNT(*)
        FROM [QR].[DataBlock]
    )
    <>
    (
        SELECT COUNT(*)
        FROM [QR].[DataCodeword]
    )
    BEGIN
        THROW 52001, 'Nicht alle Data-Codewords wurden auf Blöcke verteilt.', 1;
    END;
END;
GO




CREATE OR ALTER PROCEDURE QR.pSetAlignmentPattern
(
      @CenterX INT
    , @CenterY INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM QR.Module
        WHERE
                X BETWEEN @CenterX - 2 AND @CenterX + 2
            AND Y BETWEEN @CenterY - 2 AND @CenterY + 2
            AND ModuleType IN
            (
                'Finder',
                'Separator'
            )
    )
    RETURN;


    UPDATE M
    SET
        IsBlack =
            CASE
                WHEN ABS(M.X - @CenterX) = 2 THEN 1
                WHEN ABS(M.Y - @CenterY) = 2 THEN 1

                WHEN ABS(M.X - @CenterX) = 1
                 AND ABS(M.Y - @CenterY) = 1
                    THEN 0

                WHEN ABS(M.X - @CenterX) = 1
                 AND ABS(M.Y - @CenterY) = 0
                    THEN 0

                WHEN ABS(M.X - @CenterX) = 0
                 AND ABS(M.Y - @CenterY) = 1
                    THEN 0

                ELSE 1
            END,

        ModuleType = 'Alignment'

    FROM QR.Module M

    WHERE
            M.X BETWEEN @CenterX - 2 AND @CenterX + 2
        AND M.Y BETWEEN @CenterY - 2 AND @CenterY + 2;
END;
GO

CREATE OR ALTER PROCEDURE QR.pSetAlignmentPatterns
(
    @VersionNumber TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VersionNumber = 1
        RETURN;

    DECLARE
          @X INT
        , @Y INT;

    DECLARE C CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          X
        , Y
    FROM QR.AlignmentPatternPosition
    WHERE VersionNumber = @VersionNumber;

    OPEN C;

    FETCH NEXT FROM C
    INTO
          @X
        , @Y;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        EXEC QR.pSetAlignmentPattern
              @CenterX = @X
            , @CenterY = @Y;

        FETCH NEXT FROM C
        INTO
              @X
            , @Y;
    END

    CLOSE C;
    DEALLOCATE C;
END;
GO


CREATE OR ALTER PROCEDURE QR.pBuildGaloisTables
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

        INSERT INTO QR.GaloisExp
        (
              Exponent
            , Value
        )
        VALUES
        (
              @Exponent
            , @Value
        );

        INSERT INTO QR.GaloisLog
        (
              Value
            , LogValue
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

    /*
        Komfort:
        Exp-Tabelle bis 511 erweitern.
        Dadurch kann später Exp(Log(A)+Log(B)) ohne Modulo 255 erfolgen.
    */

    INSERT INTO QR.GaloisExp
    (
          Exponent
        , Value
    )
    SELECT
          Exponent + 255
        , Value
    FROM QR.GaloisExp
    WHERE Exponent < 255;

END;
GO


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

-- Version 1
 (1,'L',19, 7)
,(1,'M',16,10)
,(1,'Q',13,13)
,(1,'H', 9,17)

-- Version 2
,(2,'L',34,10)
,(2,'M',28,16)
,(2,'Q',22,22)
,(2,'H',16,28)

-- Version 3
,(3,'L',55,15)
,(3,'M',44,26)
,(3,'Q',34,18)
,(3,'H',26,22)

-- Version 4
,(4,'L',80,20)
,(4,'M',64,18)
,(4,'Q',48,26)
,(4,'H',36,16)

-- Version 5
,(5,'L',108,26)
,(5,'M',86,24)
,(5,'Q',62,18)
,(5,'H',46,22)

-- Version 6
,(6,'L',136,18)
,(6,'M',108,16)
,(6,'Q',76,24)
,(6,'H',60,28)

-- Version 7
,(7,'L',156,20)
,(7,'M',124,18)
,(7,'Q',88,18)
,(7,'H',66,26)

-- Version 8
,(8,'L',194,24)
,(8,'M',154,22)
,(8,'Q',110,22)
,(8,'H',86,26)

-- Version 9
,(9,'L',232,30)
,(9,'M',182,22)
,(9,'Q',132,20)
,(9,'H',100,24)

-- Version 10
,(10,'L',274,18)
,(10,'M',216,26)
,(10,'Q',154,24)
,(10,'H',122,28);
GO


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

/* ---------------------------------------------------------
   Version 1
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (1,'L',1,1,19),
    (1,'M',1,1,16),
    (1,'Q',1,1,13),
    (1,'H',1,1,9);

/* ---------------------------------------------------------
   Version 2
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (2,'L',1,1,34),
    (2,'M',1,1,28),
    (2,'Q',1,1,22),
    (2,'H',1,1,16);

/* ---------------------------------------------------------
   Version 3
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (3,'L',1,1,55),
    (3,'M',1,1,44),
    (3,'Q',1,2,17),
    (3,'H',1,2,13);

/* ---------------------------------------------------------
   Version 4
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (4,'L',1,1,80),
    (4,'M',1,2,32),
    (4,'Q',1,2,24),
    (4,'H',1,4,9);

/* ---------------------------------------------------------
   Version 5
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (5,'L',1,1,108),
    (5,'M',1,2,43),
    (5,'Q',1,2,15),
    (5,'Q',2,2,16),
    (5,'H',1,2,11),
    (5,'H',2,2,12);

/* ---------------------------------------------------------
   Version 6
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (6,'L',1,2,68),
    (6,'M',1,4,27),
    (6,'Q',1,4,19),
    (6,'H',1,4,15);

/* ---------------------------------------------------------
   Version 7
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (7,'L',1,2,78),
    (7,'M',1,4,31),
    (7,'Q',1,2,14),
    (7,'Q',2,4,15),
    (7,'H',1,4,13),
    (7,'H',2,1,14);

/* ---------------------------------------------------------
   Version 8
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (8,'L',1,2,97),
    (8,'M',1,2,38),
    (8,'M',2,2,39),
    (8,'Q',1,4,18),
    (8,'Q',2,2,19),
    (8,'H',1,4,14),
    (8,'H',2,2,15);

/* ---------------------------------------------------------
   Version 9
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (9,'L',1,2,116),
    (9,'M',1,3,36),
    (9,'M',2,2,37),
    (9,'Q',1,4,16),
    (9,'Q',2,4,17),
    (9,'H',1,4,12),
    (9,'H',2,4,13);

/* ---------------------------------------------------------
   Version 10
   --------------------------------------------------------- */
INSERT INTO [QR].[VersionBlockStructure] VALUES
    (10,'L',1,2,68),
    (10,'L',2,2,69),
    (10,'M',1,4,43),
    (10,'M',2,1,44),
    (10,'Q',1,6,19),
    (10,'Q',2,2,20),
    (10,'H',1,6,15),
    (10,'H',2,2,16);
GO








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












CREATE OR ALTER PROCEDURE [QR].[pApplyLogoColors]
(
    @LogoName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE M
    SET
        [ColorHex] =
            CASE

                WHEN P.[ColorClass] = 1
                     AND M.[IsBlack] = 1
                    THEN '#0F7285'

                WHEN P.[ColorClass] = 1
                     AND M.[IsBlack] = 0
                    THEN '#C4D9DD'

                WHEN P.[ColorClass] = 2
                     AND M.[IsBlack] = 1
                    THEN '#D09021'

                WHEN P.[ColorClass] = 2
                     AND M.[IsBlack] = 0
                    THEN '#FCF8F1'

            END

    FROM [QR].[Module] M

    INNER JOIN [QR].[LogoPlacement] P
        ON P.[TargetX] = M.[X]
       AND P.[TargetY] = M.[Y]

    WHERE
        P.[LogoName] = @LogoName;
END;
GO




CREATE OR ALTER PROCEDURE [QR].[pApplyMask]
    @MaskPattern TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    /* ========================================================================
       QR-Code Data Masking

       Eingabe:
           @MaskPattern = 0 bis 7

       Maskiert werden ausschliesslich Module mit:

           ModuleType = 'Data'

       Damit bleiben unveraendert:

           Finder Pattern
           Separatoren
           Timing Pattern
           Dark Module
           Format Information

       Die Maskierung ist eine XOR-Operation:

           Maskenbedingung falsch:
               Modul bleibt unveraendert

           Maskenbedingung wahr:
               0 -> 1
               1 -> 0
       ======================================================================== */


    /* ------------------------------------------------------------------------
       Mask Pattern pruefen
       ------------------------------------------------------------------------ */

    IF @MaskPattern IS NULL
    BEGIN
        THROW 50200,
              'Das Mask Pattern darf nicht NULL sein.',
              1;
    END;


    IF @MaskPattern NOT BETWEEN 0 AND 7
    BEGIN
        THROW 50201,
              'Das Mask Pattern muss zwischen 0 und 7 liegen.',
              1;
    END;


    /* ------------------------------------------------------------------------
       Sicherstellen, dass die Daten bereits platziert wurden
       ------------------------------------------------------------------------ */
    DECLARE @TotalDataBits INT;

    SELECT
        @TotalDataBits = COUNT(*)
    FROM QR.Module
    WHERE ModuleType IN ('Data', 'Remainder');

    IF @TotalDataBits = 0
    BEGIN
        THROW 50202, 'Keine Datenmodule vorhanden.', 1;
    END;

    /* ------------------------------------------------------------------------
       Maskierung anwenden

       Koordinaten:

           Y = Zeile
           X = Spalte

       Der Ursprung (0,0) befindet sich oben links.
       ------------------------------------------------------------------------ */
    UPDATE M
    SET
        [IsBlack] =
            CASE
                WHEN
                (
                    /* Mask Pattern 0 */
                    @MaskPattern = 0
                    AND
                    ((CONVERT(INT, [M].[Y]) + CONVERT(INT, [M].[X])) % 2) = 0
                )
                OR
                (
                    /* Mask Pattern 1 */
                    @MaskPattern = 1
                    AND
                    (CONVERT(INT, [M].[Y]) % 2) = 0
                )
                OR
                (
                    /* Mask Pattern 2 */
                    @MaskPattern = 2
                    AND
                    (CONVERT(INT, [M].[X]) % 3) = 0
                )
                OR
                (
                    /* Mask Pattern 3 */
                    @MaskPattern = 3
                    AND
                    (
                        (
                            CONVERT(INT, [M].[Y])
                            + CONVERT(INT, [M].[X])
                        ) % 3
                    ) = 0
                )
                OR
                (
                    /* Mask Pattern 4 */
                    @MaskPattern = 4
                    AND
                    (
                        (
                            CONVERT(INT, [M].[Y]) / 2
                        )
                        +
                        (
                            CONVERT(INT, [M].[X]) / 3
                        )
                    ) % 2 = 0
                )
                OR
                (
                    /* Mask Pattern 5 */
                    @MaskPattern = 5
                    AND
                    (
                        (
                            CONVERT(INT, [M].[Y])
                            * CONVERT(INT, [M].[X])
                        ) % 2
                        +
                        (
                            CONVERT(INT, [M].[Y])
                            * CONVERT(INT, [M].[X])
                        ) % 3
                    ) = 0
                )
                OR
                (
                    /* Mask Pattern 6 */
                    @MaskPattern = 6
                    AND
                    (
                        (
                            (
                                CONVERT(INT, [M].[Y])
                                * CONVERT(INT, [M].[X])
                            ) % 2
                        )
                        +
                        (
                            (
                                CONVERT(INT, [M].[Y])
                                * CONVERT(INT, [M].[X])
                            ) % 3
                        )
                    ) % 2 = 0
                )
                OR
                (
                    /* Mask Pattern 7 */
                    @MaskPattern = 7
                    AND
                    (
                        (
                            (
                                CONVERT(INT, [M].[Y])
                                + CONVERT(INT, [M].[X])
                            ) % 2
                        )
                        +
                        (
                            (
                                CONVERT(INT, [M].[Y])
                                * CONVERT(INT, [M].[X])
                            ) % 3
                        )
                    ) % 2 = 0
                )
                THEN
                    CONVERT(BIT, 1 - CONVERT(INT, [M].[IsBlack]))
                ELSE
                    [M].[IsBlack]
            END
    FROM [QR].[Module]                                                  AS [M]
    WHERE
        [M].[ModuleType] IN ('Data', 'Remainder');
END;
GO




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
       Die vier Regeln werden getrennt berechnet:
           Rule 1: Lange Folgen gleicher Farbe
           Rule 2: 2x2-Bloecke gleicher Farbe
           Rule 3: Finder-aehnliche Muster
           Rule 4: Abweichung vom Verhaeltnis 50 Prozent schwarz
       Am Ende werden alle vier Ergebnisse addiert.
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
       Lange horizontale und vertikale Folgen gleicher Farbe

       Fuer eine Folge mit mindestens 5 Modulen:
           5 Module  -> 3 Punkte
           6 Module  -> 4 Punkte
           7 Module  -> 5 Punkte
       Allgemein:
           3 + RunLength - 5
       ======================================================================== */

    DECLARE @RunLength      INTEGER;
    DECLARE @PreviousColor  BIT;
    DECLARE @CurrentColor   BIT;
    DECLARE @X              INTEGER;
    DECLARE @Y              INTEGER;

    /* ------------------------------------------------------------------------
       Horizontale Folgen
       ------------------------------------------------------------------------ */
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
                THROW 50300, 'Die Matrix enthaelt noch Module ohne Farbwert.', 1;
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


        /* Letzte Folge der Zeile auswerten */

        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;


        SET @Y = @Y + 1;

    END;


    /* ------------------------------------------------------------------------
       Vertikale Folgen
       ------------------------------------------------------------------------ */

    SET @X = 0;

    WHILE @X <= @MatrixSize - 1
    BEGIN
        SET @Y = 0;
        SET @RunLength = 0;
        SET @PreviousColor = NULL;

        WHILE @Y <= @MatrixSize - 1
        BEGIN
            SELECT
                @CurrentColor = [IsBlack]
            FROM [QR].[Module]
            WHERE [X] = @X AND [Y] = @Y;

            IF @CurrentColor IS NULL
            BEGIN
                THROW 50301,'Die Matrix enthaelt noch Module ohne Farbwert.', 1;
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

        /* Letzte Folge der Spalte auswerten */
        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;
        SET @X = @X + 1;
    END;

    /*
    Penalty Rule 2: 2x2-Blöcke
    Jeder 2x2-Block, dessen vier Module dieselbe Farbe besitzen, kostet 3 Punkte. 
    Die 2x2-Fenster überlappen sich bewusst.*/

    /* ========================================================================
       Rule 2       2x2-Bloecke gleicher Farbe
       Jeder 2x2-Block aus vier schwarzen oder vier weissen Modulen:
           +3 Punkte
       Die Bloecke duerfen und sollen sich ueberlappen.
       ======================================================================== */
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

/*
Penalty Rule 3: finderähnliche Muster
Das ist die wichtigste und zugleich am stärksten gewichtete Regel.
Gesucht wird das Verhältnis
1 : 1 : 3 : 1 : 1, also das Bitmuster 1011101
mit vier hellen Modulen davor oder danach, also 10111010000 oder 00001011101
*/
    /* ========================================================================
       Rule 3
       Finder-aehnliche Muster

       Gesucht werden:

           10111010000

       oder:

           00001011101

       horizontal und vertikal.

       Jedes Vorkommen:

           +40 Punkte
       ======================================================================== */

    DECLARE @PatternA CHAR(11) = '10111010000';
    DECLARE @PatternB CHAR(11) = '00001011101';
    DECLARE @Sequence CHAR(11);

    /* ------------------------------------------------------------------------
       Horizontal
       ------------------------------------------------------------------------ */
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
            WHERE
                [Y] = @Y
                AND [X] BETWEEN @X AND @X + 10;


            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 =
                    @PenaltyRule3 + 40;
            END;


            SET @X = @X + 1;

        END;


        SET @Y = @Y + 1;

    END;


    /* ------------------------------------------------------------------------
       Vertikal
       ------------------------------------------------------------------------ */

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
            WHERE
                [X] = @X
                AND [Y] BETWEEN @Y AND @Y + 10;


            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 =
                    @PenaltyRule3 + 40;
            END;


            SET @Y = @Y + 1;

        END;


        SET @X = @X + 1;

    END;

    /*
    Penalty Rule 4: Verhältnis Schwarz/Weiß
    Idealerweise liegt der Anteil schwarzer Module nahe bei 50 Prozent. Je weiter er davon abweicht, desto höher der Penalty Score. Regel 4 arbeitet in 5-Prozent-Schritten und vergibt je Schritt 10 Punkte
    */

        /* ========================================================================
       Rule 4
       Verhaeltnis schwarzer zu weisser Module

       Gesamtzahl bei Version 1:

           21 * 21 = 441 Module

       Fuer jede Abweichung von 50 Prozent um weitere 5 Prozentpunkte:

           +10 Punkte
       ======================================================================== */

    DECLARE @TotalModules INT;
    DECLARE @BlackModules INT;

    DECLARE @BlackPercent DECIMAL(10,4);
    DECLARE @DeviationFrom50 DECIMAL(10,4);
    DECLARE @FivePercentSteps INT;


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


    SET @BlackPercent =
        100.0
        * CONVERT(DECIMAL(10,4), @BlackModules)
        / CONVERT(DECIMAL(10,4), @TotalModules);


    SET @DeviationFrom50 =
        ABS(@BlackPercent - 50.0);


    SET @FivePercentSteps =
        FLOOR
        (
            @DeviationFrom50 / 5.0
        );


    SET @PenaltyRule4 =
        @FivePercentSteps * 10;

    -- jetzt addieren wir die vier Teilergebnisse
        /* ========================================================================
       Gesamtergebnis
       ======================================================================== */
    DECLARE @TotalPenalty INT;

    SET @TotalPenalty =
          @PenaltyRule1
        + @PenaltyRule2
        + @PenaltyRule3
        + @PenaltyRule4;

    /* ------------------------------------------------------------------------
       Ergebnisse an den Aufrufer zurueckgeben
       ------------------------------------------------------------------------ */
    SET @OutPenaltyRule1 = @PenaltyRule1;
    SET @OutPenaltyRule2 = @PenaltyRule2;
    SET @OutPenaltyRule3 = @PenaltyRule3;
    SET @OutPenaltyRule4 = @PenaltyRule4;
    SET @OutTotalPenalty = @TotalPenalty;

    /* ------------------------------------------------------------------------
       Optionale Kontrollausgabe

       Beim manuellen Aufruf wollen wir weiterhin das bisherige Resultset
       sehen koennen.

       pSelectBestMask setzt @ReturnResultSet dagegen auf 0.
       ------------------------------------------------------------------------ */
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




CREATE OR ALTER PROCEDURE [QR].[pCreateBaseMatrix]
    @VersionNumber      TINYINT = 1
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



CREATE OR ALTER PROCEDURE [QR].[pCreateColoredQrCode]
(
      @Text                     VARCHAR(255)
    , @LogoName                 VARCHAR(50)
    , @ErrorCorrectionLevel     CHAR(1)     = 'M'
    , @ModuleSize               INT         = 10
    , @QuietZone                INT         = 4
    , @ForegroundColor          CHAR(7)     = '#000000'
    , @BackgroundColor          CHAR(7)     = '#FFFFFF'
    , @RoundDataModulesOnly     BIT         = 1
    , @VersionNumber            TINYINT     = 1
    , @Svg                      NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
          @DataBitStream  VARCHAR(MAX)
        , @FinalBitStream VARCHAR(MAX);

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
        @ErrorCorrectionLevel = @ErrorCorrectionLevel,
        @VersionNumber        = @VersionNumber;

    ------------------------------------------------
    -- Logo
    ------------------------------------------------

    -- '8 LargestLogoArea';
    EXEC [QR].[pDetermineLargestLogoArea];

    DECLARE
          @StartX INT
        , @StartY INT
        , @Width  INT
        , @Height INT;

    SELECT
          @StartX = StartX
        , @StartY = StartY
        , @Width  = Width
        , @Height = Height
    FROM QR.LogoArea
    WHERE AreaName = 'LargestFreeRectangle';

    -- '9 ProjectLogo';
    EXEC QR.pProjectLogoPattern
          @LogoName
        , @StartX
        , @StartY
        , @Width
        , @Height;

    -- '10 ApplyColors';
    EXEC QR.pApplyLogoColors
         @LogoName;

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
          CreatedAt
        , VersionNumber
        , TextEncoded
        , LogoName
        , ErrorCorrectionLevel
        , SvgLength
        , SvgHash
        , SvgContent
        , TextLength
        , InputHash
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




CREATE OR ALTER PROCEDURE QR.pCreateDataBitStream
(
      @Text VARCHAR(255)
    , @VersionNumber TINYINT
    , @ErrorCorrectionLevel CHAR(1)
    , @DataBitStream VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ModeIndicator      CHAR(4)      = '0100';
    DECLARE @CharacterCount     INT;
    DECLARE @CharacterCountBits CHAR(8);
    DECLARE @PayloadBits        VARCHAR(MAX);
    DECLARE @RawDataBits        VARCHAR(MAX);
    DECLARE @DataCodewords      INTEGER;
    DECLARE @CapacityBits       INTEGER;

    DECLARE @Bytes TABLE
    (
          [Position]  INT
        , [ByteValue] TINYINT
        , [BitValue]  CHAR(8)
    );

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    SET @CharacterCount = LEN(@Text);

    ;WITH N AS
    (
        SELECT 1 AS Position

        UNION ALL

        SELECT Position + 1
        FROM N
        WHERE Position < LEN(@Text)
    )
    INSERT INTO @Bytes
    (
          Position
        , ByteValue
        , BitValue
    )
    SELECT
          Position
        , ASCII(SUBSTRING(@Text, Position, 1))

        , CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, Position, 1)) &   1 =   1 THEN '1' ELSE '0' END
    FROM N
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
            STRING_AGG(CONVERT(VARCHAR(MAX), BitValue), '')
            WITHIN GROUP (ORDER BY Position)
    FROM @Bytes;

    SET @RawDataBits =
          @ModeIndicator
        + @CharacterCountBits
        + @PayloadBits;

    SET @CapacityBits = @DataCodewords * 8;

    IF LEN(@RawDataBits) > @CapacityBits
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(500);
        SET @ErrorMessage =
              N'Die Nutzdaten überschreiten die Kapazität von Version '
            + CAST(@VersionNumber AS NVARCHAR(10))
            + N'-'
            + @ErrorCorrectionLevel
            + N'.';
        THROW 60002, @ErrorMessage, 1;
    END;

    SET @DataBitStream =
        QR.fnPadDataBits_V1
        (
            @RawDataBits,
            @DataCodewords
        );

    IF LEN(@DataBitStream) <> (@DataCodewords * 8)
    BEGIN
        THROW 60001,
              'Unerwartete Bitlänge im DataBitStream.',
              1;
    END
END;
GO




CREATE OR ALTER PROCEDURE [QR].[pCreateDataCodewords]
(
      @DataBitStream            VARCHAR(MAX)
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DataCodewords INT;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DELETE FROM [QR].[DataCodeword];

    DECLARE
          @Position INT = 0
        , @ByteBits CHAR(8);

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

    DECLARE @DataPosition INT = 0;

    WHILE @DataPosition <= @MaxDataPosition
    BEGIN

        INSERT INTO QR.InterleavedCodeword
        (
              Position
            , Value
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY BlockNumber
                ) - 1
            , Value
        FROM QR.DataBlock
        WHERE Position = @DataPosition;

        SET @Position += @@ROWCOUNT;

        SET @DataPosition += 1;
    END;
    DECLARE @MaxEccPosition INT;

    SELECT
        @MaxEccPosition = MAX(Position)
    FROM QR.EccBlock;

    DECLARE @EccPosition INT = 0;

    WHILE @EccPosition <= @MaxEccPosition
    BEGIN

        INSERT INTO QR.InterleavedCodeword
        (
              Position
            , Value
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY BlockNumber
                ) - 1
            , Value
        FROM QR.EccBlock
        WHERE Position = @EccPosition;

        SET @Position += @@ROWCOUNT;

        SET @EccPosition += 1;
    END;
END;
GO



CREATE OR ALTER PROCEDURE [QR].[pCreateEccForBlock]
(
      @BlockNumber            INT
    , @VersionNumber          TINYINT
    , @ErrorCorrectionLevel   CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EccCodewords INT;
    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DECLARE @Remainder TABLE
    (
        [Position] INTEGER     NOT NULL PRIMARY KEY,
        [Value]    INTEGER     NOT NULL
    );

    DECLARE @Generator TABLE
    (
          Position    INT PRIMARY KEY
        , Coefficient INT NOT NULL
    );

    INSERT INTO @Generator
    (
          Position
        , Coefficient
    )
    SELECT
          Position
        , Coefficient
    FROM QR.GeneratorPolynomial
    WHERE EccCodewords = @EccCodewords;

    IF NOT EXISTS
    (
        SELECT 1
        FROM @Generator
    )
    BEGIN
        THROW 70002, 'Kein Generatorpolynom gefunden.', 1;
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
    FROM N
    OPTION(MAXRECURSION 100);

    DECLARE @DataPosition           INTEGER = 0;
    DECLARE @DataValue              INTEGER;
    DECLARE @FirstRemainder         INTEGER;
    DECLARE @Factor                 INTEGER;
    DECLARE @GeneratorPosition      INTEGER;
    DECLARE @GeneratorCoefficient   INTEGER;
    DECLARE @Product                INTEGER;
    DECLARE @OldValue               INTEGER;
    DECLARE @Shift TABLE
        (
                [Position] INT PRIMARY KEY
            , [Value]    INT NOT NULL
        );
    DECLARE @DataCodewords INT;

    SELECT
        @DataCodewords = COUNT(*)
    FROM QR.DataBlock
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
        THROW 70001, 'Falsche Anzahl ECC-Codewords erzeugt.', 1;
    END;

    INSERT INTO QR.EccBlock
    (
          BlockNumber
        , Position
        , Value
    )
    SELECT
          @BlockNumber
        , Position
        , Value
    FROM @Remainder;
END;
GO


CREATE OR ALTER PROCEDURE QR.pCreateEccBlocks
(
      @VersionNumber          TINYINT
    , @ErrorCorrectionLevel   CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM QR.EccBlock;

    DECLARE @MaxBlockNumber INT;

    SELECT
        @MaxBlockNumber = MAX(BlockNumber)
    FROM QR.DataBlock;

    DECLARE @BlockNumber INT = 1;

    WHILE @BlockNumber <= @MaxBlockNumber
    BEGIN

        EXEC QR.pCreateEccForBlock
              @BlockNumber
            , @VersionNumber
            , @ErrorCorrectionLevel;

        SET @BlockNumber += 1;
    END
END;
GO






CREATE OR ALTER PROCEDURE [QR].[pCreateFinalBitStream]
(
    @VersionNumber          TINYINT,
    @ErrorCorrectionLevel   CHAR(1),
    @FinalBitStream         VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataCodewords INT;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

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
        FROM QR.InterleavedCodeword
    )
    BEGIN 
        THROW 61002, 'Keine interleavten Codewords vorhanden.', 1;
    END;

    SELECT
        @FinalBitStream =
            STRING_AGG
            (
                CONVERT
                (
                    VARCHAR(MAX),
                    QR.fnByteToBinary(Value)
                ),
                ''
            )
            WITHIN GROUP
            (
                ORDER BY Position
            )
    FROM QR.InterleavedCodeword;

    DECLARE @ExpectedBits INT;
    DECLARE @ExpectedCodewords INT;

    SELECT
        @ExpectedCodewords = COUNT(*)
    FROM QR.InterleavedCodeword;

    SET @ExpectedBits = @ExpectedCodewords * 8;

    IF LEN(@FinalBitStream) <> @ExpectedBits
    BEGIN

        DECLARE @ErrorMessage NVARCHAR(300);

        SET @ErrorMessage =
              N'FinalBitStream besitzt '
            + CAST(LEN(@FinalBitStream) AS NVARCHAR(10))
            + N' statt '
            + CAST(@ExpectedBits AS NVARCHAR(10))
            + N' Bits.';

        THROW 61001, @ErrorMessage, 1;
    END;
END;
GO



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



CREATE OR ALTER PROCEDURE [QR].[pDetermineLargestLogoArea]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
          @BestStartX INT = NULL
        , @BestStartY INT = NULL
        , @BestEndX   INT = NULL
        , @BestEndY   INT = NULL
        , @BestArea   INT = 0;

    DECLARE
          @StartX INT
        , @StartY INT
        , @EndX   INT
        , @EndY   INT
        , @Area   INT;
    
    DECLARE @MatrixSize INT;

    SELECT
        @MatrixSize = MAX(X) + 1
    FROM QR.Module;

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
                        WHERE
                               [X] BETWEEN @StartX AND @EndX
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
        THROW 50610,
              'ModuleSize muss mindestens 1 sein.',
              1;
    END;

    IF @QuietZone < 0
    BEGIN
        THROW 50611,
              'QuietZone darf nicht negativ sein.',
              1;
    END;

    ------------------------------------------------------------------------
    -- Matrix prüfen
    ------------------------------------------------------------------------
    DECLARE @QrSize INT;

    SELECT
        @QrSize =
            MAX(X) + 1
    FROM [QR].[Module];

    IF @QrSize IS NULL
    BEGIN
        THROW 50602, 'Die QR-Matrix ist leer.', 1;
    END;

    IF
    (
        SELECT COUNT(*)
        FROM [QR].[Module]
    ) <> (@QrSize * @QrSize)
    BEGIN
        THROW 50600,
              'Die QR-Matrix ist unvollständig.',
              1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE IsBlack IS NULL
    )
    BEGIN
        THROW 50601,
              'Die QR-Matrix enthält noch undefinierte Module.',
              1;
    END;

    ------------------------------------------------------------------------
    -- Zeichenfläche berechnen
    ------------------------------------------------------------------------
    DECLARE @CanvasModules INT;

    SET @CanvasModules =
        @QrSize + (@QuietZone * 2);

    DECLARE @CanvasPixels INT;

    SET @CanvasPixels =
        @CanvasModules * @ModuleSize;

    ------------------------------------------------------------------------
    -- SVG-Kopf
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
    -- QR-Module erzeugen
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
                    -- Datenmodule optional rund
                    ----------------------------------------------------------------
                    WHEN @RoundDataModulesOnly = 1
                         AND [ModuleType] = 'Data'
                    THEN
                          '<circle cx="'
                        + CONVERT
                          (
                              VARCHAR(20),
                              (
                                  ((CONVERT(FLOAT,[X]) + @QuietZone)
                                   * @ModuleSize)
                                  + (@ModuleSize / 2.0)
                              )
                          )
                        + '" cy="'
                        + CONVERT
                          (
                              VARCHAR(20),
                              (
                                  ((CONVERT(FLOAT,[Y]) + @QuietZone)
                                   * @ModuleSize)
                                  + (@ModuleSize / 2.0)
                              )
                          )
                        + '" r="'
                        + CONVERT
                          (
                              VARCHAR(20),
                              @ModuleSize * 0.45
                          )
                        + '" fill="'
                        +
                        CASE
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
                        + CONVERT
                          (
                              VARCHAR(20),
                              (CONVERT(INT,[X]) + @QuietZone)
                              * @ModuleSize
                          )
                        + '" y="'
                        + CONVERT
                          (
                              VARCHAR(20),
                              (CONVERT(INT,[Y]) + @QuietZone)
                              * @ModuleSize
                          )
                        + '" width="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" height="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" fill="'
                        +
                        CASE
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
               [IsBlack] = 1
            OR [ColorHex] IS NOT NULL;

    SET @Svg =
          @Svg
        + ISNULL(@Modules, '')
        + '</svg>';

END;
GO




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
        THROW 50010,
              'Ungültige QR-Version.',
              1;
    END;

    DELETE
    FROM [QR].[Module];

    ;WITH N AS
    (
        SELECT 0 AS N

        UNION ALL

        SELECT N + 1
        FROM N
        WHERE N + 1 < @MatrixSize
    )
    INSERT INTO [QR].[Module]
    (
          X
        , Y
        , IsBlack
        , ModuleType
        , ColorHex
    )
    SELECT
          X.N
        , Y.N
        , NULL
        , NULL
        , NULL
    FROM N AS X
    CROSS JOIN N AS Y
    OPTION (MAXRECURSION 200);

END;
GO



CREATE OR ALTER PROCEDURE [QR].[pPlaceDataBits]
(
      @Bits             VARCHAR(MAX)
    , @VersionNumber    TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize         INT;
    DECLARE @ExpectedBits       INT;
    DECLARE @FreeModuleCount    INT;

    DECLARE @BitPosition        INT = 1;
    DECLARE @RightX             INT;
    DECLARE @LeftX              INT;

    DECLARE @Y                  INT;
    DECLARE @Direction          INT = -1;

    DECLARE @CurrentX           INT;
    DECLARE @CurrentBit         BIT;

    -------------------------------------------------------------------------
    -- Parameter prüfen
    -------------------------------------------------------------------------

    IF @Bits IS NULL
    BEGIN
        THROW 50001,
              'Der Bitstream darf nicht NULL sein.',
              1;
    END;

    IF LEN(@Bits) = 0
    BEGIN
        THROW 50002,
              'Der Bitstream darf nicht leer sein.',
              1;
    END;

    IF @Bits LIKE '%[^01]%'
    BEGIN
        THROW 50003,
              'Der Bitstream darf nur 0 und 1 enthalten.',
              1;
    END;

    -------------------------------------------------------------------------
    -- Matrixgröße bestimmen
    -------------------------------------------------------------------------

    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    IF @MatrixSize IS NULL
    BEGIN
        THROW 50004,
              'Die Matrix wurde noch nicht initialisiert.',
              1;
    END;

    -------------------------------------------------------------------------
    -- Erwartete Bitanzahl bestimmen
    -------------------------------------------------------------------------

    SET @ExpectedBits = LEN(@Bits);

    /* -------------------------------------------------------------------------
       Freie Datenmodule prüfen
       ------------------------------------------------------------------------- */
    SELECT
        @FreeModuleCount = COUNT(*)
    FROM QR.Module
    WHERE ModuleType IS NULL;

    IF @FreeModuleCount < @ExpectedBits
    BEGIN
        THROW 50005,
              'Zu wenig freie Datenmodule für den Bitstream vorhanden.',
              1;
    END;

    -------------------------------------------------------------------------
    -- Start rechts außen
    -------------------------------------------------------------------------

    SET @RightX = @MatrixSize - 1;

    -------------------------------------------------------------------------
    -- Zick-Zack-Belegung
    -------------------------------------------------------------------------

    WHILE @RightX > 0
    BEGIN

        ---------------------------------------------------------------------
        -- Timing-Spalte überspringen
        ---------------------------------------------------------------------

        IF @RightX = 6
            SET @RightX = 5;

        SET @LeftX = @RightX - 1;

        ---------------------------------------------------------------------
        -- Richtung festlegen
        ---------------------------------------------------------------------

        IF @Direction = -1
            SET @Y = @MatrixSize - 1;
        ELSE
            SET @Y = 0;

        ---------------------------------------------------------------------
        -- Aktuelle Doppelspalte durchlaufen
        ---------------------------------------------------------------------

        WHILE @Y BETWEEN 0 AND (@MatrixSize - 1)
        BEGIN

            -----------------------------------------------------------------
            -- Rechte Spalte
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
            -- Linke Spalte
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
        -- Nächste Doppelspalte
        ---------------------------------------------------------------------

        SET @RightX = @RightX - 2;
        SET @Direction = @Direction * -1;
    END;

    UPDATE QR.Module
    SET
          IsBlack    = 0
        , ModuleType = 'Remainder'
    WHERE ModuleType IS NULL;

    DECLARE @ExpectedRemainderBits INT;

    SELECT
        @ExpectedRemainderBits = RemainderBits
    FROM QR.VersionRemainderBits
    WHERE VersionNumber = @VersionNumber;

    IF
    (
        SELECT COUNT(*)
        FROM QR.Module
        WHERE ModuleType = 'Remainder'
    )
    <> @ExpectedRemainderBits
    BEGIN
        THROW 50009,
              'Falsche Anzahl Remainder Bits.',
              1;
    END;

    -------------------------------------------------------------------------
    -- Abschlusskontrolle
    -------------------------------------------------------------------------

    IF @BitPosition <= @ExpectedBits
    BEGIN
        THROW 50008, 'Es konnten nicht alle Bits platziert werden.', 1;
    END;
END;
GO


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

    IF NOT EXISTS
    (
        SELECT 1
        FROM QR.LogoPattern
        WHERE LogoName = @LogoName
    )
    BEGIN
        DECLARE @ErrorText      NVARCHAR(200);
        SET @ErrorText = 'Logo ' + @LogoName + ' wurde nicht gefunden.';
        THROW 50710, @ErrorText,1;
    END;

    DECLARE @LogoWidth  INTEGER;
    DECLARE @LogoHeight INTEGER;

    SELECT
          @LogoWidth  = MAX([X]) + 1
        , @LogoHeight = MAX([Y]) + 1
    FROM [QR].[LogoPattern]
    WHERE [LogoName] = @LogoName;

    IF @LogoWidth IS NULL OR @LogoHeight IS NULL
    BEGIN
        THROW 50711, 'Logo besitzt keine gültigen Pixeldaten.', 1;
    END;

    IF @LogoWidth <= 0
       OR @LogoHeight <= 0
    BEGIN
        THROW 50712, 'Logo besitzt keine gültige Größe.', 1;
    END;

    DELETE
    FROM [QR].[LogoPlacement]
    WHERE [LogoName] = @LogoName;

    ;WITH TargetCells AS
    (
        SELECT
              X = @StartX + X.N
            , Y = @StartY + Y.N

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

        , T.X
        , T.Y

        , FLOOR(TX.SourceX)
        , FLOOR(TY.SourceY)

        , P.ColorClass

    FROM TargetCells AS T

    CROSS APPLY
    (
        SELECT (((T.X - @StartX) + 0.5) * CONVERT(FLOAT,@LogoWidth) / @Width) AS SourceX
    ) AS TX

    CROSS APPLY
    (
        SELECT (((T.Y - @StartY) + 0.5) * CONVERT(FLOAT,@LogoHeight) / @Height) AS SourceY
    ) AS TY

    INNER JOIN [QR].[LogoPattern] AS P
        ON 1 = 1
            AND P.LogoName = @LogoName
            AND P.X =
                CASE
                    WHEN FLOOR(TX.SourceX) >= @LogoWidth
                        THEN @LogoWidth - 1
                    ELSE FLOOR(TX.SourceX)
                END

            AND P.Y =
                CASE
                    WHEN FLOOR(TY.SourceY) >= @LogoHeight
                        THEN @LogoHeight - 1
                    ELSE FLOOR(TY.SourceY)
                END
END;
GO




CREATE OR ALTER PROCEDURE [QR].[pReserveFormatModules]
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
        THROW 50050,
              'Ungültige QR-Version.',
              1;
    END;

    UPDATE [QR].[Module]
    SET
          IsBlack    = NULL
        , ModuleType = 'Format'
    WHERE

        /* -----------------------------------------------------------
           Erste Kopie links oben
           ----------------------------------------------------------- */

        (X = 8 AND Y IN (0,1,2,3,4,5,7,8))

        OR

        (Y = 8 AND X IN (0,1,2,3,4,5,7,8))

        /* -----------------------------------------------------------
           Zweite Kopie oben rechts
           ----------------------------------------------------------- */

        OR
        (
                Y = 8
            AND X BETWEEN (@MatrixSize - 8)
                      AND (@MatrixSize - 1)
        )

        /* -----------------------------------------------------------
           Zweite Kopie unten links
           ----------------------------------------------------------- */

        OR
        (
                X = 8
            AND Y BETWEEN (@MatrixSize - 7)
                      AND (@MatrixSize - 1)
        );

END;
GO



CREATE OR ALTER PROCEDURE [QR].[pSelectBestMask]
    @ErrorCorrectionLevel CHAR(1)       = 'M',
    @VersionNumber        TINYINT       = 1
AS
BEGIN
    SET NOCOUNT ON;

    /* ========================================================================
       Beste QR-Maske bestimmen

       Voraussetzung:

           - 208 Data-Module existieren
           - diese Data-Module sind noch unmaskiert
           - die Formatmodule sind reserviert
           - Formatmodule besitzen IsBlack = NULL

       Ablauf:

           1. Originalzustand der 208 Data-Module sichern
           2. Masken 0 bis 7 testen
           3. jeweilige Format Information setzen
           4. Penalty Rules 1 bis 4 berechnen
           5. niedrigsten Gesamt-Penalty bestimmen
           6. Originaldaten wiederherstellen
           7. Gewinner-Maske anwenden
           8. passende Format Information setzen
       ======================================================================== */


    /* ------------------------------------------------------------------------
       Matrixzustand pruefen
       ------------------------------------------------------------------------ */
    DECLARE @DataModuleCount INT;
    DECLARE @FormatModuleCount INT;

    SELECT
        @DataModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF @DataModuleCount = 0
    BEGIN
        THROW 50500, 'Es wurden keine Datenmodule gefunden.', 1;
    END;

    SELECT
        @FormatModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] = 'Format';


    IF @FormatModuleCount <> 30
    BEGIN
        THROW 50501,
              'Es muessen exakt 30 reservierte Formatmodule vorhanden sein.',
              1;
    END;
    /* ========================================================================
       Unmaskierten Ausgangszustand sichern
       ======================================================================== */

    DECLARE @OriginalData TABLE
    (
        [X]       TINYINT NOT NULL,
        [Y]       TINYINT NOT NULL,
        [IsBlack] BIT     NOT NULL,

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
        THROW 50502, 'Der unmaskierte Datenzustand konnte nicht vollständig gesichert werden.', 1;
    END;

    /* ========================================================================
       Ergebnisse der acht Kandidaten
       ======================================================================== */
    DECLARE @MaskResults TABLE
    (
        [MaskPattern]  TINYINT NOT NULL PRIMARY KEY,

        [PenaltyRule1] INT NOT NULL,
        [PenaltyRule2] INT NOT NULL,
        [PenaltyRule3] INT NOT NULL,
        [PenaltyRule4] INT NOT NULL,

        [TotalPenalty] INT NOT NULL
    );

    DECLARE @MaskPattern    TINYINT = 0;
    DECLARE @P1             INTEGER;
    DECLARE @P2             INTEGER;
    DECLARE @P3             INTEGER;
    DECLARE @P4             INTEGER;
    DECLARE @Total          INTEGER;

        /* ========================================================================
       Masken 0 bis 7 testen
       ======================================================================== */
    WHILE @MaskPattern <= 7
    BEGIN

        /* --------------------------------------------------------------------
           Originale unmaskierte Daten wiederherstellen
           -------------------------------------------------------------------- */
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

        /* --------------------------------------------------------------------
           Format Information fuer diesen Kandidaten zuruecksetzen
           -------------------------------------------------------------------- */
        UPDATE [QR].[Module]
        SET
            [IsBlack] = NULL
        WHERE
            [ModuleType] = 'Format';

        /* --------------------------------------------------------------------
           Kandidatenmaske anwenden
           -------------------------------------------------------------------- */
        EXEC [QR].[pApplyMask]
            @MaskPattern = @MaskPattern;

        /* --------------------------------------------------------------------
           Passende Format Information setzen
           -------------------------------------------------------------------- */
        EXEC [QR].[pSetFormatInformation]
            @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
            @MaskPattern            = @MaskPattern,
            @VersionNumber          = @VersionNumber;

        /* --------------------------------------------------------------------
           Penalty berechnen
           -------------------------------------------------------------------- */
        SET @P1 = 0;
        SET @P2 = 0;
        SET @P3 = 0;
        SET @P4 = 0;
        SET @Total = 0;

        EXEC [QR].[pCalculateMaskPenalty]
            @OutPenaltyRule1 = @P1      OUTPUT,
            @OutPenaltyRule2 = @P2      OUTPUT,
            @OutPenaltyRule3 = @P3      OUTPUT,
            @OutPenaltyRule4 = @P4      OUTPUT,
            @OutTotalPenalty = @Total   OUTPUT,
            @ReturnResultSet = 0;

        /* --------------------------------------------------------------------
           Ergebnis speichern
           -------------------------------------------------------------------- */
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

        /* ========================================================================
       Beste Maske bestimmen

       Niedrigster Penalty Score gewinnt.

       Bei identischem Score verwenden wir die kleinere Maskennummer,
       damit das Ergebnis deterministisch bleibt.
       ======================================================================== */
    DECLARE @BestMaskPattern TINYINT;
    DECLARE @BestPenalty INT;

    SELECT TOP (1)
        @BestMaskPattern = [MaskPattern],
        @BestPenalty = [TotalPenalty]
    FROM @MaskResults
    ORDER BY
        [TotalPenalty],
        [MaskPattern];

    /* ========================================================================
       Unmaskierten Zustand ein letztes Mal herstellen
       ======================================================================== */
    UPDATE M
    SET
        [IsBlack] = O.[IsBlack]
    FROM [QR].[Module] AS M
    INNER JOIN @OriginalData AS O
        ON O.[X] = M.[X]
        AND O.[Y] = M.[Y]
    WHERE
        M.[ModuleType] IN ('Data', 'Remainder');

    UPDATE [QR].[Module]
    SET
        [IsBlack] = NULL
    WHERE
        [ModuleType] = 'Format';

    /* ========================================================================
       Gewinner-Maske anwenden
       ======================================================================== */
    EXEC [QR].[pApplyMask]
        @MaskPattern = @BestMaskPattern;

    EXEC [QR].[pSetFormatInformation]
        @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
        @MaskPattern            = @BestMaskPattern,
        @VersionNumber          = @VersionNumber;

    /* ========================================================================
       Abschlusskontrolle
       ======================================================================== */
    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE [IsBlack] IS NULL
    )
    BEGIN
        THROW 50503, 'Nach der Maskenauswahl enthaelt die Matrix noch undefinierte Module.', 1;
    END;
END;
GO




CREATE OR ALTER PROCEDURE [QR].[pSetDarkModule]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DarkModuleY INT;

    SET @DarkModuleY =
        (4 * @VersionNumber) + 9;

    UPDATE [QR].[Module]
    SET
          IsBlack    = 1
        , ModuleType = 'Dark'
    WHERE
            X = 8
        AND Y = @DarkModuleY;

    IF @@ROWCOUNT <> 1
    BEGIN
        THROW 50040,
              'Dark Module konnte nicht gesetzt werden.',
              1;
    END;
END;
GO



CREATE OR ALTER PROCEDURE [QR].[pSetFinderPattern]
    @StartX     TINYINT,
    @StartY     TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    -- die Finder-Pattern haben je eine Größe von 7x7
    -- schwarzer Kern, weißes Inneres und schwarzer Rand
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



CREATE OR ALTER PROCEDURE [QR].[pSetFormatInformation]
    @ErrorCorrectionLevel   CHAR(1),
    @MaskPattern            TINYINT,
    @VersionNumber          TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    /* ========================================================================
       Format Information fuer QR Version 1-M setzen

       Die 15 Formatbits enthalten:

           Error Correction Level = M
           Mask Pattern           = 0 bis 7
           BCH Error Correction

       Die Format Information wird zweimal in die Matrix geschrieben.
       ======================================================================== */


    IF @MaskPattern IS NULL
    BEGIN
        THROW 50400,
              'Das Mask Pattern darf nicht NULL sein.',
              1;
    END


    IF @MaskPattern NOT BETWEEN 0 AND 7
    BEGIN
        THROW 50401,
              'Das Mask Pattern muss zwischen 0 und 7 liegen.',
              1;
    END;


    DECLARE @FormatBits CHAR(15);
    DECLARE @MatrixSize INT;

    SET @MatrixSize = [QR].[fnGetMatrixSize](@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        THROW 50405, 'Ungültige QR-Version.', 1;
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
        THROW 50402,
              'Die Format Information konnte nicht erzeugt werden.',
              1;
    END;


    /* ========================================================================
       Zielpositionen

       BitIndex:

           0 = niederwertigstes Bit des 15-Bit-Formatwertes
           14 = hoechstwertigstes Bit

       Da fnGetFormatBits_V1_M den String MSB zuerst liefert:

           SUBSTRING(@FormatBits, 15 - BitIndex, 1)
       ======================================================================== */

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
    /* ------------------------------------------------------------------------
       Erste Kopie:
       um den Finder oben links
       ------------------------------------------------------------------------ */

    INSERT INTO @FormatModules
    (
        [CopyNumber],
        [BitIndex],
        [X],
        [Y]
    )
    VALUES
        (1,  0,  8,  0),
        (1,  1,  8,  1),
        (1,  2,  8,  2),
        (1,  3,  8,  3),
        (1,  4,  8,  4),
        (1,  5,  8,  5),
        (1,  6,  8,  7),
        (1,  7,  8,  8),

        (1,  8,  7,  8),
        (1,  9,  5,  8),
        (1, 10,  4,  8),
        (1, 11,  3,  8),
        (1, 12,  2,  8),
        (1, 13,  1,  8),
        (1, 14,  0,  8);
    
    /* ------------------------------------------------------------------------
       Zweite Kopie:        oben rechts und unten links        
       ------------------------------------------------------------------------ */

    INSERT INTO @FormatModules
    (
          CopyNumber
        , BitIndex
        , X
        , Y
    )
    VALUES
          (2, 0, @MatrixSize - 1, 8)
        , (2, 1, @MatrixSize - 2, 8)
        , (2, 2, @MatrixSize - 3, 8)
        , (2, 3, @MatrixSize - 4, 8)
        , (2, 4, @MatrixSize - 5, 8)
        , (2, 5, @MatrixSize - 6, 8)
        , (2, 6, @MatrixSize - 7, 8)
        , (2, 7, @MatrixSize - 8, 8)

        , (2, 8, 8, @MatrixSize - 7)
        , (2, 9, 8, @MatrixSize - 6)
        , (2,10, 8, @MatrixSize - 5)
        , (2,11, 8, @MatrixSize - 4)
        , (2,12, 8, @MatrixSize - 3)
        , (2,13, 8, @MatrixSize - 2)
        , (2,14, 8, @MatrixSize - 1);

    DECLARE @ReservedFormatModuleCount INT;


    SELECT
        @ReservedFormatModuleCount = COUNT(*)
    FROM @FormatModules AS F

    INNER JOIN [QR].[Module] AS M
        ON M.[X] = F.[X]
        AND M.[Y] = F.[Y]

    WHERE
        M.[ModuleType] = 'Format';


    IF @ReservedFormatModuleCount <> 30
    BEGIN
        THROW 50403,
              'Die erwarteten 30 reservierten Formatmodule wurden nicht gefunden.',
              1;
    END;

    /* ========================================================================
       Formatbits schreiben
       ======================================================================== */

    UPDATE M
    SET
        [IsBlack] =
            CONVERT
            (
                BIT,
                SUBSTRING
                (
                    @FormatBits,
                    15 - CONVERT(INT, F.[BitIndex]),
                    1
                )
            )

    FROM [QR].[Module] AS M

    INNER JOIN @FormatModules AS F
        ON F.[X] = M.[X]
        AND F.[Y] = M.[Y];


    /* ========================================================================
       Abschlusskontrolle
       ======================================================================== */

    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE
            [ModuleType] = 'Format'
            AND [IsBlack] IS NULL
    )
    BEGIN
        THROW 50404, 'Nicht alle Formatmodule wurden gesetzt.', 1;
    END;
END;
GO





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




CREATE OR ALTER PROCEDURE [QR].[pSetTimingPatterns]
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
        THROW 50030,
              'Ungültige QR-Version.',
              1;
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

    -- Vertikal
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

CREATE OR ALTER FUNCTION QR.fnGaloisMultiply
(
      @A INT
    , @B INT
)
RETURNS INT
AS
BEGIN

    IF @A = 0 RETURN 0;
    IF @B = 0 RETURN 0;

    DECLARE
          @LogA INT
        , @LogB INT
        , @Result INT;

    SELECT
        @LogA = LogValue
    FROM QR.GaloisLog
    WHERE Value = @A;

    SELECT
        @LogB = LogValue
    FROM QR.GaloisLog
    WHERE Value = @B;

    SELECT
        @Result = Value
    FROM QR.GaloisExp
    WHERE Exponent = @LogA + @LogB;

    RETURN @Result;
END;
GO







CREATE OR ALTER FUNCTION [QR].[fnBinaryByteToInt]
(
    @Bits CHAR(8)
)
RETURNS INT
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



CREATE OR ALTER FUNCTION [QR].[fnGetFormatBits_V1]
(
    @ErrorCorrectionLevel   CHAR(1),
    @MaskPattern            TINYINT
)
RETURNS CHAR(15)
AS
BEGIN
    /* ========================================================================
       QR Format Information

       Fest:
           Error Correction Level = M

       Variabel:
           Mask Pattern = 0 bis 7

       Format Data:

           EE MMM

           EE  = Error Correction Level
           MMM = Mask Pattern

       Fuer M:

           EE = 00

       BCH:
           Generatorpolynom = 0x537

       Abschliessende QR-Formatmaske:

           0x5412
       ======================================================================== */

    IF @MaskPattern IS NULL
        RETURN NULL;

    IF @MaskPattern > 7
        RETURN NULL;

    IF @ErrorCorrectionLevel NOT IN ('L','M','Q','H')
    RETURN NULL;

    DECLARE @FormatData INT;

    DECLARE @Value INT;
    DECLARE @Remainder INT;

    DECLARE @Generator INT = 1335;  -- 0x537
    DECLARE @FormatMask INT = 21522; -- 0x5412

    DECLARE @Bit INT;
    DECLARE @FormatValue INT;

    DECLARE @Result CHAR(15);


    /* ------------------------------------------------------------------------
       5 Format-Datenbits

       Error Correction Level M:

           00

       Damit entsprechen die unteren drei Bits direkt dem Mask Pattern.
       ------------------------------------------------------------------------ */

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

    /* ------------------------------------------------------------------------
       Platz fuer 10 BCH-Bits schaffen

           FormatData << 10
       ------------------------------------------------------------------------ */

    SET @Value = @FormatData * 1024;

    SET @Remainder = @Value;


    /* ------------------------------------------------------------------------
       Polynomdivision ueber GF(2)

       Generator:

           10100110111
           0x537

       Der Generator besitzt Grad 10.

       Deshalb beginnen wir beim hoechsten moeglichen Bit 14
       und arbeiten bis Bit 10.
       ------------------------------------------------------------------------ */

    SET @Bit = 14;


    WHILE @Bit >= 10
    BEGIN

        IF (@Remainder & POWER(2, @Bit)) <> 0
        BEGIN
            SET @Remainder =
                @Remainder
                ^
                (
                    @Generator
                    * POWER(2, @Bit - 10)
                );
        END;


        SET @Bit = @Bit - 1;

    END;


    /* ------------------------------------------------------------------------
       Die unteren 10 Bits sind der BCH-Rest.

       Formatcode vor QR-Maskierung:

           5 Datenbits
           +
           10 BCH-Bits
       ------------------------------------------------------------------------ */

    SET @FormatValue =
          (@FormatData * 1024)
        + @Remainder;


    /* ------------------------------------------------------------------------
       QR-spezifische Formatmaske anwenden

           0x5412
       ------------------------------------------------------------------------ */

    SET @FormatValue =
        @FormatValue ^ @FormatMask;


    /* ------------------------------------------------------------------------
       Numerischen Wert in exakt 15 Bits umwandeln
       Bit 14 zuerst, Bit 0 zuletzt.
       ------------------------------------------------------------------------ */

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
    DECLARE @UseEC BIT;

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

    -- Bis zur Byte-Grenze auffuellen
    SET @BytePaddingLength = (8 - (LEN(@Result) % 8)) % 8;
    SET @Result = @Result + REPLICATE('0', @BytePaddingLength);

    -- Pad Codewords EC und 11
    SET @UseEC = 1;
    
    DECLARE @TargetLength INT;
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





CREATE OR ALTER FUNCTION QR.fnGetMatrixSize
(
    @VersionNumber TINYINT
)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    SELECT
        @Result = MatrixSize
    FROM QR.VersionDefinition
    WHERE VersionNumber = @VersionNumber;

    RETURN ISNULL(@Result, 0)
END;
GO

CREATE OR ALTER FUNCTION QR.fnGetDataCodewords
(
      @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    SELECT
        @Result = DataCodewords
    FROM QR.VersionCapacity
    WHERE 1 = 1
        AND VersionNumber           = @VersionNumber
        AND ErrorCorrectionLevel    = @ErrorCorrectionLevel;

    RETURN @Result;
END;
GO

CREATE OR ALTER FUNCTION QR.fnGetEccCodewords
(
      @VersionNumber TINYINT
    , @ErrorCorrectionLevel CHAR(1)
)
RETURNS INT
AS
BEGIN

    DECLARE @Result INT;

    SELECT
        @Result = EccCodewords
    FROM QR.VersionCapacity
    WHERE
            VersionNumber = @VersionNumber
        AND ErrorCorrectionLevel = @ErrorCorrectionLevel;

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
*/
