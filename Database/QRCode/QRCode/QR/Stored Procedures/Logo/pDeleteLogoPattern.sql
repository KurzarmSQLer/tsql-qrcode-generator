

-- ##############################################################################
-- ### Procedure: [QR].[pDeleteLogoPattern]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Deletes all pixels belonging to the specified logo from                ###
-- ### [QR].[LogoPattern].                                                    ###
-- ###                                                                        ###
-- ### This procedure is typically used before importing an updated           ###
-- ### version of a logo or when removing obsolete logo definitions.          ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                                                             ###
-- ###   Public                                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ###   @LogoName:                                                           ###
-- ###     Name of the logo to be deleted.                                    ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ###   None                                                                 ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pDeleteLogoPattern]
(
    @LogoName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE
    FROM [QR].[LogoPattern]
    WHERE [LogoName] = @LogoName;
END;
