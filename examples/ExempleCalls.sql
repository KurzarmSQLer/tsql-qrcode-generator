USE [Kopfnuesse];
GO


-- Example 1
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'Hello World'
    , @LogoName             = NULL
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M'
    , @Svg                  = @Svg OUTPUT;

SELECT @Svg




-- Example 2
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'Logo Projection'
    , @LogoName             = 'TA'
    , @VersionNumber        = 6
    , @ErrorCorrectionLevel = 'H'
    , @ModuleSize           = 10
    , @QuietZone            = 4
    , @ForegroundColor      = '#000000'
    , @BackgroundColor      = '#FFFFFF'
    , @RoundDataModulesOnly = 0
    , @Svg                  = @Svg OUTPUT;

SELECT @Svg



-- ####################################################################################
-- ### Conference Showcase                                                          ###
-- ####################################################################################
-- ### Demonstrates the full feature set of the project:                            ###
-- ###                                                                              ###
-- ###   * Higher QR version                                                        ###
-- ###   * High error correction level                                              ###
-- ###   * Logo projection                                                          ###
-- ###   * SVG generation                                                           ###
-- ###   * Rounded data modules                                                     ###
-- ###   * Larger module size                                                       ###
-- ####################################################################################

DECLARE @Svg NVARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'T-SQL QR Code Generator'
    , @LogoName             = 'TA'
    , @VersionNumber        = 6
    , @ErrorCorrectionLevel = 'H'
    , @ModuleSize           = 12
    , @QuietZone            = 4
    , @ForegroundColor      = '#000000'
    , @BackgroundColor      = '#FFFFFF'
    , @RoundDataModulesOnly = 1
    , @Svg                  = @Svg OUTPUT;

SELECT
      LEN(@Svg) AS [SvgLength]
    , CAST(@Svg AS XML) AS [SvgDocument];
GO
