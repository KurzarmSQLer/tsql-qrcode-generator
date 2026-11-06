
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
CREATE   PROCEDURE [QR].[pSetSeparator]
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
