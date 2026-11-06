
-- ##############################################################################
-- ### Function: [QR].[fnBinaryByteToInt]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts an 8-bit binary string into its integer representation.       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @Binary:                    8-bit binary string                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                    Integer value between 0 and 255            ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnBinaryByteToInt]
(
    @Bits CHAR(8)
)
RETURNS INTEGER
AS
BEGIN
    DECLARE @Value INT;

    SET @Value =
          CASE SUBSTRING(@Bits, 1, 1) WHEN '1' THEN 128 ELSE 0 END
        + CASE SUBSTRING(@Bits, 2, 1) WHEN '1' THEN  64 ELSE 0 END
        + CASE SUBSTRING(@Bits, 3, 1) WHEN '1' THEN  32 ELSE 0 END
        + CASE SUBSTRING(@Bits, 4, 1) WHEN '1' THEN  16 ELSE 0 END
        + CASE SUBSTRING(@Bits, 5, 1) WHEN '1' THEN   8 ELSE 0 END
        + CASE SUBSTRING(@Bits, 6, 1) WHEN '1' THEN   4 ELSE 0 END
        + CASE SUBSTRING(@Bits, 7, 1) WHEN '1' THEN   2 ELSE 0 END
        + CASE SUBSTRING(@Bits, 8, 1) WHEN '1' THEN   1 ELSE 0 END;
    RETURN @Value;
END;
