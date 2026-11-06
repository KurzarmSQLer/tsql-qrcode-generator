

-- ##############################################################################
-- ### Function: [QR].[fnGaloisMultiply]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Multiplies two values in the finite field GF(256).                     ###
-- ###                                                                        ###
-- ### The implementation uses logarithmic and exponent lookup tables         ###
-- ### instead of direct polynomial multiplication.                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @A:                          First operand                             ###
-- ### @B:                          Second operand                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Product of @A and @B in GF(256)                                        ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnGaloisMultiply]
(
      @A            INTEGER
    , @B            INTEGER
)
RETURNS INTEGER
AS
BEGIN

    IF @A = 0 RETURN 0;
    IF @B = 0 RETURN 0;

    DECLARE @LogA           INTEGER
    DECLARE @LogB           INTEGER
    DECLARE @Result         INTEGER;

    SELECT
        @LogA = [LogValue]
    FROM [QR].[GaloisLog]
    WHERE [Value] = @A;

    SELECT
        @LogB = [LogValue]
    FROM [QR].[GaloisLog]
    WHERE [Value] = @B;

    SELECT
        @Result = [Value]
    FROM [QR].[GaloisExp]
    WHERE [Exponent] = @LogA + @LogB;

    RETURN @Result;
END;
