
-- ##############################################################################
-- ### Procedure: [QR].[pCreateDataCodewords]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Splits the QR data bit stream into 8-bit codewords and stores them     ###
-- ### in [QR].[DataCodeword].                                                ###
-- ###                                                                        ###
-- ### The resulting data codewords form the basis for block distribution     ###
-- ### and Reed-Solomon ECC generation.                                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                       Internal                              ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @DataBitStream:               QR payload bit stream                    ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateDataCodewords]
(
      @DataBitStream            VARCHAR(MAX)
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DataCodewords      INTEGER;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DELETE FROM [QR].[DataCodeword];

    DECLARE
          @Position             INTEGER = 0
        , @ByteBits             CHAR(8);

    WHILE @Position < @DataCodewords
    BEGIN
        SET @ByteBits =
            SUBSTRING
            (
                @DataBitStream,
                (@Position * 8) + 1,
                8
            );

        INSERT INTO [QR].[DataCodeword]
        (
              [Position]
            , [Value]
        )
        VALUES
        (
              @Position
            , [QR].[fnBinaryByteToInt](@ByteBits)
        );

        SET @Position += 1;
    END;
END;
