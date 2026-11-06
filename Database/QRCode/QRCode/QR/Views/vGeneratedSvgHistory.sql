




-- ##############################################################################
-- ### View: [QR].[vGeneratedSvgHistory]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Provides a convenient view of generated SVG documents together with    ###
-- ### their associated metadata. The view is intended for reporting,         ###
-- ### testing, debugging and history analysis.                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Derived from:             [QR].[GeneratedSvg]                          ###
-- ##############################################################################
CREATE   VIEW [QR].[vGeneratedSvgHistory]
AS
SELECT
      [SvgID]                                           AS [SvgID]
    , [CreatedAt]                                       AS [CreatedAt]
    , [VersionNumber]                                   AS [VersionNumber]
    , [ErrorCorrectionLevel]                            AS [ErrorCorrectionLevel]
    , [LogoName]                                        AS [LogoName]
    , [TextLength]                                      AS [TextLength]
    , [SvgLength]                                       AS [SvgLength]
    , [TextEncoded]                                     AS [TextEncoded]
    , CONVERT(VARCHAR(64), [InputHash], 2)              AS [InputHashHex]
    , CONVERT(VARCHAR(64), [SvgHash],   2)              AS [SvgHashHex]
FROM [QR].[GeneratedSvg];
