USE [Kopfnuesse]
GO

-- ####################################################################################
-- ### Example 1 - Smallest Possible QR Code                                        ###
-- ####################################################################################
-- ### This example generates a simple QR code measuring 21x21 pixels with a        ###
-- ### colored logo superimposed on the code. The logo was previously stored in the ###
-- ### [QR].[Logo] table as a colored pattern.                                      ###
-- ####################################################################################
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'Hello World'
    , @LogoName             = 'TA'
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M'
    , @Svg                  = @Svg OUTPUT;

SELECT 
    LEN(@Svg)        AS SvgLength,
    @Svg             AS SVG;






-- ####################################################################################
-- ### Example 2 - Capacity Limits                                                  ###
-- ####################################################################################
-- ### In this example, a parameter is intentionally set too small. After checking, ###
-- ### the program should respond with an appropriate error message. If you call    ###
-- ### the same procedure again with a validly adjusted parameter, the error        ###
-- ### message disappears and the QR code is generated.                             ###
-- ####################################################################################

-- Step 2a
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text =
          REPLICATE
          (
              'A',
              40  -- The participant deliberately triggers an error message.
          )
    , @LogoName             = 'TA'
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M'
    , @Svg                  = @Svg OUTPUT;


-- Step 2b
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text =
          REPLICATE
          (
              'A',
              100
          )
    , @LogoName             = 'TA'
    , @VersionNumber        = 1
    , @ErrorCorrectionLevel = 'M'
    , @Svg                  = @Svg OUTPUT;

-- The capacity check does indeed exist.






-- ####################################################################################
-- ### Example 3 - Higher Versions                                                  ###
-- ####################################################################################
-- ### Now the matrix size is growing                                               ###
-- ####################################################################################

-- Step 3a
SELECT
      VersionNumber
    , MatrixSize
FROM [QR].[VersionDefinition]
WHERE VersionNumber BETWEEN 1 AND 10;


-- Step 3b
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'Hello Conference'
    , @LogoName             = 'TA'
    , @VersionNumber        = 6
    , @ErrorCorrectionLevel = 'H'
    , @Svg                  = @Svg OUTPUT;



-- ####################################################################################
-- ### Example 4 - Error Correction Levels                                          ###
-- ####################################################################################
-- ### The program has several error-correction levels                              ###
-- ####################################################################################

SELECT *
FROM [QR].[VersionCapacity]
WHERE VersionNumber = 6;




-- ####################################################################################
-- ### Example 5 - Reed Solomon Is Real                                             ###
-- ####################################################################################
-- ### The Error Correction Process                                                 ###
-- ####################################################################################

-- Step 5a
SELECT *
FROM [QR].[DataCodeword];

SELECT *
FROM [QR].[DataBlock];

SELECT *
FROM [QR].[EccBlock];

-- Step5b
EXEC [QR].[pCreateQrCode]
      @Text = 'QR'
    , @VersionNumber = 3
    , @ErrorCorrectionLevel = 'H';


-- ####################################################################################
-- ### Example 6 - Mask Selection                                                   ###
-- ####################################################################################
-- ### The QR masks are actually being evaluated.                                   ###
-- ####################################################################################

-- Step 6a
EXEC [QR].[pCalculateMaskPenalty];

-- Step 6b
EXEC [QR].[pSelectBestMask]
      @ErrorCorrectionLevel = 'H'
    , @VersionNumber        = 6;

-- Step 6c
SELECT *
FROM [QR].[Module];

-- The implementation evaluates all 8 QR masks
-- and automatically chooses the best one.

-- ####################################################################################
-- ### Example 7 - SVG Persistence                                                  ###
-- ####################################################################################
-- ### The SVG is being converted to a historical format.                           ###
-- ####################################################################################
SELECT TOP (10)
      SvgID
    , CreatedAt
    , VersionNumber
    , LogoName
    , TextLength
    , SvgLength
FROM [QR].[GeneratedSvg]
ORDER BY SvgID DESC;


-- ####################################################################################
-- ### Example 8 - Logo Projection                                                  ###
-- ####################################################################################
-- ### The logo isn't just displayed.                                               ###
-- ####################################################################################
SELECT *
FROM [QR].[LogoArea];

SELECT *
FROM [QR].[LogoPlacement]
ORDER BY TargetY, TargetX;


-- ####################################################################################
-- ### Example 9 - Full Showcase                                                    ###
-- ####################################################################################
-- ### A more complex example with many parameters that demonstrates the            ###
-- ### capabilities of this project.                                                ###
-- ####################################################################################
DECLARE @Svg VARCHAR(MAX);

EXEC [QR].[pCreateColoredQrCode]
      @Text                 = 'SQL Saturday 2026'
    , @LogoName             = 'TA'
    , @VersionNumber        = 6
    , @ErrorCorrectionLevel = 'H'
    , @ModuleSize           = 10
    , @QuietZone            = 4
    , @ForegroundColor      = '#000000'
    , @BackgroundColor      = '#FFFFFF'
    , @RoundDataModulesOnly = 0
    , @Svg                  = @Svg OUTPUT;

SELECT CAST(@Svg AS XML);
-- The returned SVG string is too large for the default SSMS output—it is displayed as 
-- truncated. Of course, it exists in its full length in the database, as evidenced 
-- by its XML representation.



-- ####################################################################################
-- ### Example 10 - Your Own Experiments                                            ###
-- ####################################################################################
-- ### This is your chance to put the program through its paces. Just experiment    ###
-- ### with the parameters for the different settings, upload your own logos, and   ###
-- ### play around with the colors.                                                 ###
-- ####################################################################################
-- Suggestions:
--
-- * Change the QR version.
-- * Change the ECC level.
-- * Change the logo size.
-- * Change the module size.
-- * Create your own logo pattern.
-- * Compare SVG sizes.
-- * Compare mask penalties.

