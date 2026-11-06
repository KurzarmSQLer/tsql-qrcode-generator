
-- ##############################################################################
-- ### Procedure: [QR].[pSetDarkModule]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places the mandatory dark module defined by the QR specification.      ###
-- ### The dark module is located at a fixed position and is present in all   ###
-- ### QR versions.                                                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pSetDarkModule]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DarkModuleY INT;

    SET @DarkModuleY = (4 * @VersionNumber) + 9;

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = 1
        , [ModuleType] = 'Dark'
    WHERE
            [X] = 8
        AND [Y] = @DarkModuleY;

    IF @@ROWCOUNT <> 1
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Dark Module konnte nicht gesetzt werden.'
            + CHAR(13) + CHAR(10)
            + N'The Dark Module could not be set.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
