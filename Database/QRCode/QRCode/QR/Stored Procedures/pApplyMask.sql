
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
CREATE   PROCEDURE [QR].[pApplyMask]
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
