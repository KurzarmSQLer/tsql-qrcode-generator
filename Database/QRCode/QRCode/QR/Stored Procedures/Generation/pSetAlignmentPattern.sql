
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
CREATE   PROCEDURE [QR].[pSetAlignmentPattern]
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
        AND [M].[Y] BETWEEN @CenterY - 2 AND @CenterY + 2
        AND [M].[ModuleType] IS NULL;
END;
