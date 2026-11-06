
-- ##############################################################################
-- ### Function: [QR].[fnGetDataCodewords]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the number of QR data codewords for a given version and        ###
-- ### error correction level.                                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:              QR version number                         ###
-- ### @ErrorCorrectionLevel:       QR error correction level (L, M, Q or H)  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Number of data codewords.                                              ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnGetDataCodewords]
(
      @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Result INTEGER;

    SELECT
        @Result = DataCodewords
    FROM [QR].[VersionCapacity]
    WHERE 1 = 1
        AND [VersionNumber]           = @VersionNumber
        AND [ErrorCorrectionLevel]    = @ErrorCorrectionLevel;

    RETURN @Result;
END;
