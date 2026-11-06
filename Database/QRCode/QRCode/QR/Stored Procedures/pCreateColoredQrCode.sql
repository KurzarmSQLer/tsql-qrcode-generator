
-- ##############################################################################
-- ### Procedure: [QR].[pCreateColoredQrCode]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates a complete QR code including logo projection, color mapping    ###
-- ### and SVG rendering. This procedure represents the primary public API    ###
-- ### of the project.                                                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:             Public                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @Text:                 Text to be encoded into the QR code.            ###
-- ### @LogoName:             Name of the logo stored in [QR].[LogoPattern].  ###
-- ###                        NULL disables logo projection.                  ###
-- ### @ErrorCorrectionLevel: QR error correction level (L, M, Q or H)        ###
-- ### @ModuleSize:           Module size in SVG pixels.                      ###
-- ### @QuietZone:            Number of quiet-zone modules surrounding        ###
-- ###                        the QR code.                                    ###
-- ### @ForegroundColor:      Default color of dark QR modules                ###
-- ### @BackgroundColor:      Background color of the SVG document            ###
-- ### @RoundDataModulesOnly: Enables rounded rendering of data modules       ###
-- ### @VersionNumber:        QR version number                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @Svg:                       Generated SVG document                     ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateColoredQrCode]
(
      @Text                     VARCHAR(255)
    , @LogoName                 VARCHAR(50)
    , @ErrorCorrectionLevel     CHAR(1)     = 'M'
    , @ModuleSize               INTEGER     = 10
    , @QuietZone                INTEGER     = 4
    , @ForegroundColor          CHAR(7)     = '#000000'
    , @BackgroundColor          CHAR(7)     = '#FFFFFF'
    , @RoundDataModulesOnly     BIT         = 1
    , @VersionNumber            TINYINT     = 1
    , @Svg                      NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DataBitStream      VARCHAR(MAX)
    DECLARE @FinalBitStream     VARCHAR(MAX);

    IF NOT EXISTS
    (
        SELECT 1
        FROM QR.GaloisLog
    )
    OR NOT EXISTS
    (
        SELECT 1
        FROM QR.GaloisExp
    )
    BEGIN
        EXEC QR.pBuildGaloisTables;
    END;

    ------------------------------------------------
    -- QR erzeugen
    ------------------------------------------------

    -- '1 BaseMatrix';
    EXEC [QR].[pCreateBaseMatrix]
        @VersionNumber = @VersionNumber;

    -- '2 DataBitStream';
    EXEC [QR].[pCreateDataBitStream]
          @Text                     = @Text
        , @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel
        , @DataBitStream            = @DataBitStream OUTPUT;

    -- '3 DataCodewords';
    EXEC [QR].[pCreateDataCodewords]
          @DataBitStream            = @DataBitStream
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 
        , @VersionNumber            = @VersionNumber

    -- '4 ECC';
    EXEC [QR].[pBuildDataBlocks]
          @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 

    EXEC [QR].[pCreateEccBlocks]
          @VersionNumber            = @VersionNumber
        , @ErrorCorrectionLevel     = @ErrorCorrectionLevel 

    EXEC [QR].[pInterleaveCodewords];

    -- '5 FinalBitStream';
    EXEC [QR].[pCreateFinalBitStream]
          @ErrorCorrectionLevel     = @ErrorCorrectionLevel
        , @VersionNumber            = @VersionNumber
        , @FinalBitStream           = @FinalBitStream OUTPUT;

    EXEC [QR].[pSetVersionInformation]
        @VersionNumber = @VersionNumber;

    -- '6 PlaceDataBits';
    EXEC [QR].[pPlaceDataBits]
         @Bits                      = @FinalBitStream,
         @VersionNumber             = @VersionNumber;

    -- '7 SelectBestMask';
    EXEC [QR].[pSelectBestMask]
        @ErrorCorrectionLevel       = @ErrorCorrectionLevel,
        @VersionNumber              = @VersionNumber;

    ------------------------------------------------
    -- Logo
    ------------------------------------------------
    IF NULLIF(@LogoName, '') IS NOT NULL
    BEGIN

        -- '8 LargestLogoArea';
        EXEC [QR].[pDetermineLargestLogoArea];

        DECLARE
              @StartX       INTEGER
            , @StartY       INTEGER
            , @Width        INTEGER
            , @Height       INTEGER;

        SELECT
              @StartX = [StartX]
            , @StartY = [StartY]
            , @Width  = [Width]
            , @Height = [Height]
        FROM [QR].[LogoArea]
        WHERE [AreaName] = 'LargestFreeRectangle';

        IF @Width IS NULL
           OR @Height IS NULL
        BEGIN
            THROW 50000,
                  'DE: Es konnte kein Logo-Bereich ermittelt werden.
        EN: No logo area could be determined.',
                  1;
        END;

        -- '9 ProjectLogo';
        EXEC [QR].[pProjectLogoPattern]
              @LogoName
            , @StartX
            , @StartY
            , @Width
            , @Height;

        -- '10 ApplyColors';
        EXEC [QR].[pApplyLogoColors]
             @LogoName;
    END

    ------------------------------------------------
    -- SVG
    ------------------------------------------------
    EXEC [QR].[pGenerateSvg]
          @ModuleSize           = @ModuleSize
        , @QuietZone            = @QuietZone
        , @ForegroundColor      = @ForegroundColor
        , @BackgroundColor      = @BackgroundColor
        , @RoundDataModulesOnly = @RoundDataModulesOnly
        , @Svg                  = @Svg OUTPUT;

    INSERT INTO [QR].[GeneratedSvg]
    (
          [CreatedAt]
        , [VersionNumber]
        , [TextEncoded]
        , [LogoName]
        , [ErrorCorrectionLevel]
        , [SvgLength]
        , [SvgHash]
        , [SvgContent]
        , [TextLength]
        , [InputHash]
    )
    VALUES
    (
          SYSDATETIME()
        , @VersionNumber
        , @Text
        , @LogoName
        , @ErrorCorrectionLevel
        , LEN(@Svg)
        , HASHBYTES
          (
              'SHA2_256',
              CONVERT(VARBINARY(MAX), @Svg)
          )
        , @Svg
        , LEN(@Svg)
        , HASHBYTES
          (
              'SHA2_256',
              CONCAT
              (
                    ISNULL(@Text,''),                       '|'
                  , ISNULL(@LogoName,''),                   '|'
                  , CONVERT(VARCHAR(10),@VersionNumber),    '|'
                  , ISNULL(@ErrorCorrectionLevel,'')
              )
          )
    );
END;
