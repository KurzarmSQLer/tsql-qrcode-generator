
-- ##############################################################################
-- ### Procedure: [QR].[pCreateFinalBitStream]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Converts the interleaved codeword sequence into the final QR bit       ###
-- ### stream ready for matrix placement.                                     ###
-- ### The procedure appends version-specific remainder bits as required      ###
-- ### by the QR specification.                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @FinalBitStream:              Final QR bit stream ready for matrix     ###
-- ###                               placement.                               ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateFinalBitStream]
(
    @VersionNumber          TINYINT,
    @ErrorCorrectionLevel   CHAR(1),
    @FinalBitStream         VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataCodewords      INTEGER;
    DECLARE @EccCodewords       INTEGER;
    DECLARE @ExpectedBits       INTEGER;
    DECLARE @ExpectedCodewords  INTEGER;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    IF NOT EXISTS
    (
        SELECT 1
        FROM [QR].[InterleavedCodeword]
    )
    BEGIN 
        DECLARE @ErrorMessage NVARCHAR(MAX)
        SET @ErrorMessage =
              N'DE: Keine interleavten Codewords vorhanden.'
            + CHAR(13) + CHAR(10)
            + N'EN: No interleaved codewords are present.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
        @FinalBitStream =
            STRING_AGG
            (
                CONVERT
                (
                    VARCHAR(MAX),
                    [QR].[fnByteToBinary]([Value])
                ),
                ''
            )
            WITHIN GROUP
            (
                ORDER BY [Position]
            )
    FROM QR.InterleavedCodeword;

    SELECT
        @ExpectedCodewords = COUNT(*)
    FROM QR.InterleavedCodeword;

    SET @ExpectedBits = @ExpectedCodewords * 8;

    IF LEN(@FinalBitStream) <> @ExpectedBits
    BEGIN
        SET @ErrorMessage =
              N'FinalBitStream besitzt '
            + CAST(LEN(@FinalBitStream) AS NVARCHAR(10))
            + N' statt '
            + CAST(@ExpectedBits AS NVARCHAR(10))
            + N' Bits.'
            + CHAR(13) + CHAR(10)
            + N'EN: FinalBitStream has '
            + CAST(LEN(@FinalBitStream) AS NVARCHAR(10))
            + N'bits instead of '
            + CAST(@ExpectedBits AS NVARCHAR(10));
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
