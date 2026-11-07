
-- ##############################################################################
-- ### Procedure: [QR].[pSetVersionInformation]                               ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Writes BCH-protected QR version information into the reserved          ###
-- ### version-information areas of the QR matrix.                            ###
-- ###                                                                        ###
-- ### Version information is required only for QR versions 7 and higher.     ###
-- ###                                                                        ###
-- ### The same 18-bit version-information value is written twice             ###
-- ### according to the QR specification:                                     ###
-- ###                                                                        ###
-- ###   - Top-right version area                                             ###
-- ###   - Bottom-left version area                                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Dependencies:                                                          ###
-- ###   [QR].[VersionInformation]                                            ###
-- ###   [QR].[Module]                                                        ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pSetVersionInformation]
(
    @VersionNumber TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VersionNumber < 7
        RETURN;

    DECLARE
          @MatrixSize    INT
        , @VersionBits   CHAR(18)
        , @ErrorMessage  NVARCHAR(300);

    -------------------------------------------------------------------------
    -- Matrix Size
    -------------------------------------------------------------------------
    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    -------------------------------------------------------------------------
    -- Version Bits
    -------------------------------------------------------------------------
    SELECT
        @VersionBits = [VersionBits]
    FROM [QR].[VersionInformation]
    WHERE [VersionNumber] = @VersionNumber;

    IF @VersionBits IS NULL
    BEGIN
        SET @ErrorMessage =
              N'DE: Keine Versionsinformation vorhanden.'
            + CHAR(13) + CHAR(10)
            + N'EN: No version information available.';
        RAISERROR (@ErrorMessage,16,1);
    END;

    -------------------------------------------------------------------------
    -- Version Module Mapping
    --
    -- BitIndex:
    --      0 = Least Significant Version Bit
    --      17 = Most Significant Version Bit
    --
    -- VersionBits are stored MSB-first.
    -------------------------------------------------------------------------
    DECLARE @VersionModules TABLE
    (
          [CopyNumber] TINYINT NOT NULL
        , [BitIndex]   TINYINT NOT NULL
        , [X]          TINYINT NOT NULL
        , [Y]          TINYINT NOT NULL

        , PRIMARY KEY
          (
              [CopyNumber]
            , [BitIndex]
          )
    );

    -------------------------------------------------------------------------
    -- Top Right
    -------------------------------------------------------------------------
    INSERT INTO @VersionModules
    (
          [CopyNumber]
        , [BitIndex]
        , [X]
        , [Y]
    )
    VALUES
          (1,  0, @MatrixSize - 11, 0)
        , (1,  1, @MatrixSize - 10, 0)
        , (1,  2, @MatrixSize -  9, 0)

        , (1,  3, @MatrixSize - 11, 1)
        , (1,  4, @MatrixSize - 10, 1)
        , (1,  5, @MatrixSize -  9, 1)

        , (1,  6, @MatrixSize - 11, 2)
        , (1,  7, @MatrixSize - 10, 2)
        , (1,  8, @MatrixSize -  9, 2)

        , (1,  9, @MatrixSize - 11, 3)
        , (1, 10, @MatrixSize - 10, 3)
        , (1, 11, @MatrixSize -  9, 3)

        , (1, 12, @MatrixSize - 11, 4)
        , (1, 13, @MatrixSize - 10, 4)
        , (1, 14, @MatrixSize -  9, 4)

        , (1, 15, @MatrixSize - 11, 5)
        , (1, 16, @MatrixSize - 10, 5)
        , (1, 17, @MatrixSize -  9, 5);

    -------------------------------------------------------------------------
    -- Bottom Left
    -------------------------------------------------------------------------
    INSERT INTO @VersionModules
    (
          [CopyNumber]
        , [BitIndex]
        , [X]
        , [Y]
    )
    VALUES
          (2,  0, 0, @MatrixSize - 11)
        , (2,  1, 1, @MatrixSize - 11)
        , (2,  2, 2, @MatrixSize - 11)

        , (2,  3, 0, @MatrixSize - 10)
        , (2,  4, 1, @MatrixSize - 10)
        , (2,  5, 2, @MatrixSize - 10)

        , (2,  6, 0, @MatrixSize -  9)
        , (2,  7, 1, @MatrixSize -  9)
        , (2,  8, 2, @MatrixSize -  9)

        , (2,  9, 3, @MatrixSize - 11)
        , (2, 10, 4, @MatrixSize - 11)
        , (2, 11, 5, @MatrixSize - 11)

        , (2, 12, 3, @MatrixSize - 10)
        , (2, 13, 4, @MatrixSize - 10)
        , (2, 14, 5, @MatrixSize - 10)

        , (2, 15, 3, @MatrixSize -  9)
        , (2, 16, 4, @MatrixSize -  9)
        , (2, 17, 5, @MatrixSize -  9);

    -------------------------------------------------------------------------
    -- Write Version Bits
    -------------------------------------------------------------------------
    UPDATE M
    SET
        [IsBlack] =
            CONVERT
            (
                BIT,
                SUBSTRING
                (
                    @VersionBits,
                    18 - V.[BitIndex],
                    1
                )
            ),
        [ModuleType] = 'Version'
    FROM [QR].[Module] M
    INNER JOIN @VersionModules V
        ON  V.[X] = M.[X]
        AND V.[Y] = M.[Y];

    -------------------------------------------------------------------------
    -- Validation
    -------------------------------------------------------------------------
    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE
                [ModuleType] = 'Version'
            AND [IsBlack] IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'DE: Nicht alle Versionsmodule wurden gesetzt.'
            + CHAR(13) + CHAR(10)
            + N'EN: Not all version modules have been set.';
        RAISERROR (@ErrorMessage,16,1);
    END;
END;
