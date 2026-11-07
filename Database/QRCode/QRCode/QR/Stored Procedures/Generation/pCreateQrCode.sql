
-- ##############################################################################
-- ### Procedure: [QR].[pCreateQrCode]                                        ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates a QR matrix according to the QR specification.                 ###
-- ### No logo projection or SVG generation is performed.                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:             Public                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                 Text to be encoded                              ###
-- ### @VersionNumber:        QR version number.                              ###
-- ### @ErrorCorrectionLevel: QR error correction level (L, M, Q or H)        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:     None                                            ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateQrCode]
(
    @Text                   VARCHAR(255), 
    @VersionNumber          TINYINT         = 1,
    @ErrorCorrectionLevel   CHAR(1)         = 'M'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataBitStream  VARCHAR(MAX);
    DECLARE @FinalBitStream VARCHAR(MAX);

    IF NOT EXISTS (SELECT 1 FROM [QR].[GaloisLog])
       OR NOT EXISTS (SELECT 1 FROM [QR].[GaloisExp])
    BEGIN
        EXEC [QR].[pBuildGaloisTables];
    END;

    DECLARE @EccCodewords INT;

    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    IF NOT EXISTS
    (
        SELECT 1
        FROM [QR].[GeneratorPolynomial]
        WHERE [EccCodewords] = @EccCodewords
    )
    BEGIN
        EXEC [QR].[pBuildGeneratorPolynomial]
             @EccCodewords = @EccCodewords;
    END;

    EXEC QR.pCreateBaseMatrix
        @VersionNumber = @VersionNumber;

    EXEC [QR].[pSetVersionInformation]
        @VersionNumber = @VersionNumber;

    EXEC [QR].[pCreateDataBitStream]
        @Text                   = @Text,
        @VersionNumber          = @VersionNumber,
        @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
        @DataBitStream          = @DataBitStream OUTPUT;

    EXEC [QR].[pCreateDataCodewords]
         @DataBitStream         = @DataBitStream,
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pBuildDataBlocks
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pCreateEccBlocks
         @VersionNumber         = @VersionNumber,
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel;

    EXEC QR.pInterleaveCodewords;

    EXEC [QR].[pCreateFinalBitStream]
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel,
         @VersionNumber         = @VersionNumber,
         @FinalBitStream        = @FinalBitStream OUTPUT;

    EXEC [QR].[pPlaceDataBits]
         @Bits                  = @FinalBitStream,
         @VersionNumber         = @VersionNumber;

    EXEC [QR].[pSelectBestMask]
         @ErrorCorrectionLevel  = @ErrorCorrectionLevel,
         @VersionNumber         = @VersionNumber;
END;
