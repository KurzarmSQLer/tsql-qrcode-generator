
-- ##############################################################################
-- ### Procedure: [QR].[pCreateDataBitStream]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Encodes the input payload using QR Byte Mode and generates the         ###
-- ### complete QR data bit stream.                                           ###
-- ###                                                                        ###
-- ### The procedure performs:                                                ###
-- ###   - Mode indicator creation                                            ###
-- ###   - Character count indicator generation                               ###
-- ###   - Payload encoding                                                   ###
-- ###   - Terminator insertion                                               ###
-- ###   - Bit padding                                                        ###
-- ###   - Pad codeword generation                                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                        Text to be encoded                       ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @DataBitStream:               Generated QR payload bit stream          ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateDataBitStream]
(
      @Text                     VARCHAR(255)
    , @VersionNumber            TINYINT
    , @ErrorCorrectionLevel     CHAR(1)
    , @DataBitStream            VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ModeIndicator      CHAR(4)      = '0100';
    DECLARE @CharacterCount     INTEGER;
    DECLARE @CharacterCountBits CHAR(8);
    DECLARE @PayloadBits        VARCHAR(MAX);
    DECLARE @RawDataBits        VARCHAR(MAX);
    DECLARE @DataCodewords      INTEGER;
    DECLARE @CapacityBits       INTEGER;
    DECLARE @Bytes TABLE
    (
          [Position]            INTEGER
        , [ByteValue]           TINYINT
        , [BitValue]            CHAR(8)
    );

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    SET @CharacterCount = LEN(@Text);

    ;WITH [N] AS
    (
        SELECT 1                                        AS Position

        UNION ALL

        SELECT Position + 1
        FROM [N]
        WHERE [Position] < LEN(@Text)
    )
    INSERT INTO @Bytes
    (
          [Position]
        , [ByteValue]
        , [BitValue]
    )
    SELECT
          [Position]
        , ASCII(SUBSTRING(@Text, [Position], 1))

        , CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN ASCII(SUBSTRING(@Text, [Position], 1)) &   1 =   1 THEN '1' ELSE '0' END
    FROM [N]
    OPTION (MAXRECURSION 255);

    SET @CharacterCountBits =
          CASE WHEN @CharacterCount & 128 = 128 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  64 =  64 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  32 =  32 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &  16 =  16 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   8 =   8 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   4 =   4 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   2 =   2 THEN '1' ELSE '0' END
        + CASE WHEN @CharacterCount &   1 =   1 THEN '1' ELSE '0' END;

    SELECT
        @PayloadBits =
            STRING_AGG(CONVERT(VARCHAR(MAX), [BitValue]), '')
            WITHIN GROUP (ORDER BY [Position])
    FROM @Bytes;

    SET @RawDataBits =
          @ModeIndicator
        + @CharacterCountBits
        + @PayloadBits;

    SET @CapacityBits = @DataCodewords * 8;

    IF LEN(@RawDataBits) > @CapacityBits
    BEGIN
        DECLARE @ErrorMessage60002       NVARCHAR(500);
        SET @ErrorMessage60002 =
              N'DE: Die Nutzdaten überschreiten die Kapazität der gewählten QR-Version '
            + CAST(@VersionNumber AS NVARCHAR(10))
            + N'-'
            + @ErrorCorrectionLevel
            + N'.'
            + CHAR(13) + CHAR(10)
            + N'EN: The payload exceeds the capacity of the selected QR version '
            + CAST(@VersionNumber AS NVARCHAR(10))
            + N'-'
            + @ErrorCorrectionLevel
            + N'.';
        THROW 60002, @ErrorMessage60002, 1;
    END;

    SET @DataBitStream =
        QR.fnPadDataBits_V1
        (
            @RawDataBits,
            @DataCodewords
        );

    IF LEN(@DataBitStream) <> (@DataCodewords * 8)
    BEGIN
        DECLARE @ErrorMessage60001       NVARCHAR(500);
        SET @ErrorMessage60002 =
              N'DE: Unerwartete Bitlänge im DataBitStream.'
            + CHAR(13) + CHAR(10)
            + N'EN: Unexpected bit length in the DataBitStream.';
        THROW 60001, @ErrorMessage60001, 1;
    END
END;
