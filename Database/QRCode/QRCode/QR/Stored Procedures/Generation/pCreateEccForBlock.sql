
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
CREATE   PROCEDURE [QR].[pCreateEccForBlock]
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
                SET @ErrorMessage =
                      N'DE: Factor ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: Factor is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @GeneratorCoefficient IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: GeneratorCoefficient ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: GeneratorCoefficient is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @Factor IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: Factor ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: Factor is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @GeneratorCoefficient IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: GeneratorCoefficient ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: GeneratorCoefficient is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
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
                SET @ErrorMessage =
                      N'DE: OldValue ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: OldValue is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @Product IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: Product ist NULL.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: Product is NULL.';
                RAISERROR (@ErrorMessage, 16, 1)
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
