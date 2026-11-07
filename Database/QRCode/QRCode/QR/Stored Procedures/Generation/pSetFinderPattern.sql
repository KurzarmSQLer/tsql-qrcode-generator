
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
CREATE   PROCEDURE [QR].[pSetFinderPattern]
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
