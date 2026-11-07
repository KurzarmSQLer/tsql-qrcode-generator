
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
CREATE   PROCEDURE [QR].[pPlaceDataBits]
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
    DECLARE @BitPosition        INTEGER =  1;
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
              N'DE: Falsche Anzahl Remainder Bits.'
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
