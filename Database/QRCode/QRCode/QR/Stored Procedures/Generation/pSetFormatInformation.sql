
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
CREATE   PROCEDURE [QR].[pSetFormatInformation]
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
