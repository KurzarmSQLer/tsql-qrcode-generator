
-- ##############################################################################
-- ### Function: [QR].[fnGetMatrixSize]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the QR matrix size for a given version.                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:               QR version number.                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Matrix size in modules.                                                ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnGetMatrixSize]
(
    @VersionNumber TINYINT
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Result INTEGER;

    SELECT
        @Result = [MatrixSize]
    FROM [QR].[VersionDefinition]
    WHERE [VersionNumber] = @VersionNumber;

    RETURN ISNULL(@Result, 0)
END;
