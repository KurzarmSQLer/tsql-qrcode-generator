
-- ##############################################################################
-- ### Function: [QR].[fnGetEccCodewords]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Returns the number of Reed-Solomon error correction codewords for      ###
-- ### a given QR version and ECC level.                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @VersionNumber:            QR version number                           ###
-- ### @ErrorCorrectionLevel:     QR error correction level (L, M, Q or H)    ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Number of ECC codewords                                                ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnGetEccCodewords]
(
      @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
RETURNS INTEGER
AS
BEGIN

    DECLARE @Result             INTEGER;

    SELECT
        @Result = [EccCodewords]
    FROM [QR].[VersionCapacity]
    WHERE 1 = 1
        AND [VersionNumber]         = @VersionNumber
        AND [ErrorCorrectionLevel]  = @ErrorCorrectionLevel;

    RETURN @Result;
END;
