
-- ##############################################################################
-- ### Function: [QR].[fnGetFormatBits_V1]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates the 15-bit QR format information string for the specified    ###
-- ### error correction level and mask pattern.                               ###
-- ###                                                                        ###
-- ### The generated value contains BCH error protection as required by the   ###
-- ### QR specification and is written into the reserved format information   ###
-- ### modules of the QR matrix.                                              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### @MaskPattern:                 Selected mask pattern (0-7)              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ### Complete QR format information bit string                              ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnGetFormatBits_V1]
(
    @ErrorCorrectionLevel   CHAR(1),
    @MaskPattern            TINYINT
)
RETURNS CHAR(15)
AS
BEGIN
    -- ------------------------------------------------------------------------
    -- QR Format Information
    -- Fixed:                Error Correction Level = M
    -- Variable:             Mask Pattern = 0 through 7
    -- Format Data:          EE MMM
    --     EE  = Error Correction Level
    --     MMM = Mask Pattern
    -- For M:                EE = 00
    -- BCH:                  Generator Polynomial = 0x537
    -- Final QR Format Mask: 0x5412
    -- ------------------------------------------------------------------------
    IF @MaskPattern IS NULL                             RETURN NULL;
    IF @MaskPattern > 7                                 RETURN NULL;
    IF @ErrorCorrectionLevel NOT IN ('L','M','Q','H')   RETURN NULL;

    DECLARE @FormatData         INT;
    DECLARE @Value              INT;
    DECLARE @Remainder          INT;
    DECLARE @Generator          INT = 1335;  -- 0x537
    DECLARE @FormatMask         INT = 21522; -- 0x5412
    DECLARE @Bit                INT;
    DECLARE @FormatValue        INT;
    DECLARE @Result             CHAR(15);

    -- ------------------------------------------------------------------------
    -- 5 Format Data Bits
    -- Error Correction Level M: 00
    -- Thus, the lower three bits correspond directly to the mask pattern.
    -- ------------------------------------------------------------------------
    DECLARE @ECLBits INT;

    SET @ECLBits =
        CASE @ErrorCorrectionLevel
            WHEN 'L' THEN 1   -- 01
            WHEN 'M' THEN 0   -- 00
            WHEN 'Q' THEN 3   -- 11
            WHEN 'H' THEN 2   -- 10
            ELSE NULL
        END;

    IF @ECLBits IS NULL RETURN NULL;

    SET @FormatData = (@ECLBits * 8) + @MaskPattern;

    -- ------------------------------------------------------------------------
    -- Make room for 10 BCH bits
    --     FormatData << 10
    -- ------------------------------------------------------------------------
    SET @Value = @FormatData * 1024;
    SET @Remainder = @Value;

    -- ------------------------------------------------------------------------
    -- Polynomdivision ueber GF(2)
    -- ------------------------------------------------------------------------
    -- Generator:
    --     10100110111
    --     0x537
    -- The generator has a degree of 10.
    -- Therefore, we start at the highest possible bit, bit 14,
    -- and work down to bit 10.
    -- ------------------------------------------------------------------------
    SET @Bit = 14;

    WHILE @Bit >= 10
    BEGIN
        IF (@Remainder & POWER(2, @Bit)) <> 0
        BEGIN
            SET @Remainder = @Remainder ^ (@Generator * POWER(2, @Bit - 10));
        END;

        SET @Bit = @Bit - 1;
    END;

    -- ------------------------------------------------------------------------
    -- The lower 10 bits are the BCH remainder.
    -- Format code before QR masking:
    --     5 data bits + 10 BCH bits    
    -- ------------------------------------------------------------------------
    SET @FormatValue =  (@FormatData * 1024) + @Remainder;

    -- ------------------------------------------------------------------------
    -- Apply QR-specific format mask: 0x5412
    -- ------------------------------------------------------------------------
    SET @FormatValue = @FormatValue ^ @FormatMask;

    -- ------------------------------------------------------------------------
    -- Convert a numerical value to exactly 15 bits
    -- Bit 14 first, bit 0 last.
    -- ------------------------------------------------------------------------
    SET @Result =
          CASE WHEN (@FormatValue & 16384) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  8192) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  4096) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  2048) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &  1024) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   512) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   256) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &   128) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    64) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    32) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &    16) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     8) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     4) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     2) <> 0 THEN '1' ELSE '0' END
        + CASE WHEN (@FormatValue &     1) <> 0 THEN '1' ELSE '0' END;
    RETURN @Result;
END;
