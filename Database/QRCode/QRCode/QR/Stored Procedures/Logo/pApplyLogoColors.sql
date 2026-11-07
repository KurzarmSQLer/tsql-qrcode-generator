
-- ##############################################################################
-- ### Procedure: [QR].[pApplyLogoColors]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Applies logo-specific color information to projected logo modules      ###
-- ### inside the QR matrix. Colors are taken from [QR].[LogoPattern] and     ###
-- ### transferred to matching modules in [QR].[Module].                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @LogoName:               Logo identifier stored in [QR].[LogoPattern]  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pApplyLogoColors]
(
    @LogoName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [M]
    SET
        [ColorHex] =
            CASE
                WHEN [P].[ColorClass] = 1 AND [M].[IsBlack] = 1         THEN '#0F7285'
                WHEN [P].[ColorClass] = 1 AND [M].[IsBlack] = 0         THEN '#C4D9DD'
                WHEN [P].[ColorClass] = 2 AND [M].[IsBlack] = 1         THEN '#D09021'
                WHEN [P].[ColorClass] = 2 AND [M].[IsBlack] = 0         THEN '#FCF8F1'
            END
    FROM [QR].[Module]                          AS [M]
    INNER JOIN [QR].[LogoPlacement]             AS [P]
        ON 1 = 1
            AND [P].[TargetX] = [M].[X]
            AND [P].[TargetY] = [M].[Y]
    WHERE
        [P].[LogoName] = @LogoName;
END;
