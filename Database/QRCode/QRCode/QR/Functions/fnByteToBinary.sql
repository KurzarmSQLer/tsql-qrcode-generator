
-- ##############################################################################
-- ### Function: [QR].[fnByteToBinary]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts a numeric byte value into an 8-bit binary string.             ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @Value:                      Byte value between 0 and 255              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### 8-bit binary representation                                            ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnByteToBinary]
(
    @Value INTEGER
)
RETURNS CHAR(8)
AS
BEGIN

    RETURN
          CASE WHEN @Value & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN @Value &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN @Value &   1 =   1 THEN '1' ELSE '0' END;
END;
