
-- ##############################################################################
-- ### Function: [QR].[fnPadDataBits_V1]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Applies QR payload padding according to the QR specification.          ###
-- ###                                                                        ###
-- ### The function appends:                                                  ###
-- ###   - Terminator bits                                                    ###
-- ###   - Zero padding bits                                                  ###
-- ###   - Alternating pad codewords                                          ###
-- ###                                                                        ###
-- ### until the required payload size for the selected QR version and        ###
-- ### error correction level has been reached.                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input Parameters:                                                      ###
-- ### @BitStream:                   Encoded QR payload bit stream            ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Returns:                                                               ###
-- ###   Fully padded QR payload bit stream.                                  ###
-- ##############################################################################
CREATE   FUNCTION [QR].[fnPadDataBits_V1]
(
    @DataBits           VARCHAR(MAX),
    @DataCodewords      INTEGER
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Result             VARCHAR(MAX);
    DECLARE @MissingBits        INTEGER;
    DECLARE @TerminatorLength   INTEGER;
    DECLARE @BytePaddingLength  INTEGER;
    DECLARE @UseEC              BIT;

    SET @Result = @DataBits;

    IF @Result IS NULL                          RETURN NULL;
    IF @Result LIKE '%[^01]%'                   RETURN NULL;
    IF LEN(@Result) > (@DataCodewords * 8)      RETURN NULL;

    -- Terminator
    SET @MissingBits            = (@DataCodewords * 8) - LEN(@Result);
    SET @TerminatorLength       =
        CASE
            WHEN @MissingBits >= 4 THEN 4
            ELSE @MissingBits
        END;
    SET @Result = @Result + REPLICATE('0', @TerminatorLength);

    -- Fill to the byte limit
    SET @BytePaddingLength  = (8 - (LEN(@Result) % 8)) % 8;
    SET @Result             = @Result + REPLICATE('0', @BytePaddingLength);

    -- Pad Codewords EC and 11
    SET @UseEC = 1;
    
    DECLARE @TargetLength   INTEGER;
    SET @TargetLength   = @DataCodewords * 8;
    SET @MissingBits    = @TargetLength - LEN(@Result);

    WHILE LEN(@Result) < @TargetLength
    BEGIN
        SET @Result = @Result
            + CASE
                  WHEN @UseEC = 1
                      THEN '11101100'
                  ELSE '00010001'
              END;
        SET @UseEC =
            CASE
                WHEN @UseEC = 1 THEN 0
                ELSE 1
            END;
    END;

    RETURN @Result;
END;
