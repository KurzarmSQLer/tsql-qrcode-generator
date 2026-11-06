
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
CREATE   PROCEDURE [QR].[pSetTimingPatterns]
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
