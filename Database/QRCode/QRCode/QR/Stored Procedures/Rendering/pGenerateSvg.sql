
-- ##############################################################################
-- ### Procedure: [QR].[pGenerateSvg]                                         ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Generates the final SVG representation of the QR matrix.               ###
-- ###                                                                        ###
-- ### Supports:                                                              ###
-- ###   - Custom module sizes                                                ###
-- ###   - Quiet zones                                                        ###
-- ###   - Rounded data modules                                               ###
-- ###   - Custom foreground colors                                           ###
-- ###   - Custom background colors                                           ###
-- ###   - Multi-color logo rendering                                         ###
-- ###                                                                        ###
-- ### The generated SVG is returned as a Unicode string.                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                   Internal                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ModuleSize:                 Module size in SVG pixels                 ###
-- ### @QuietZone:                  Width of the surrounding quiet zone       ###
-- ###                              measured in modules.                      ###
-- ### @ForegroundColor:            Default color of dark QR modules          ###
-- ### @BackgroundColor:            SVG background color                      ###
-- ### @RoundDataModulesOnly:       Enables rounded rendering of data modules ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @Svg:                        Generated SVG document                    ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pGenerateSvg]
(
      @ModuleSize               INTEGER     = 10
    , @QuietZone                INTEGER     = 4
    , @ForegroundColor          CHAR(7)     = '#000000'
    , @BackgroundColor          CHAR(7)     = '#FFFFFF'
    , @RoundDataModulesOnly     BIT         = 1
    , @Svg                      NVARCHAR(MAX)        OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------------
    -- Parameter prüfen
    ------------------------------------------------------------------------
    IF @ModuleSize < 1
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'ModuleSize muss mindestens 1 sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: ModuleSize must be at least 1.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @QuietZone < 0
    BEGIN
        SET @ErrorMessage =
              N'QuietZone darf nicht negativ sein.'
            + CHAR(13) + CHAR(10)
            + N'EN: QuietZone must not be negative.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    ------------------------------------------------------------------------
    -- Matrix prüfen
    ------------------------------------------------------------------------
    DECLARE @QrSize INT;

    SELECT
        @QrSize =
            MAX([X]) + 1
    FROM [QR].[Module];

    IF @QrSize IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix ist leer.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix is empty.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF
    (
        SELECT COUNT(*)
        FROM [QR].[Module]
    ) <> (@QrSize * @QrSize)
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix ist unvollständig.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix is incomplete.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE [IsBlack] IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'Die QR-Matrix enthält noch undefinierte Module.'
            + CHAR(13) + CHAR(10)
            + N'EN: The QR matrix still contains undefined modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    ------------------------------------------------------------------------
    -- Calculate Drawing Area
    ------------------------------------------------------------------------
    DECLARE @CanvasModules      INTEGER;
    DECLARE @CanvasPixels       INTEGER;

    SET @CanvasModules  = @QrSize + (@QuietZone * 2);
    SET @CanvasPixels   = @CanvasModules * @ModuleSize;

    ------------------------------------------------------------------------
    -- SVG Header
    ------------------------------------------------------------------------
    SET @Svg =
          '<svg xmlns="http://www.w3.org/2000/svg"'
        + ' width="'  + CONVERT(VARCHAR(20), @CanvasPixels) + '"'
        + ' height="' + CONVERT(VARCHAR(20), @CanvasPixels) + '"'
        + ' viewBox="0 0 '
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + ' '
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" shape-rendering="crispEdges">'

        + '<rect width="'
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" height="'
        + CONVERT(VARCHAR(20), @CanvasPixels)
        + '" fill="'
        + @BackgroundColor
        + '"/>';

    ------------------------------------------------------------------------
    -- Generate QR Modules
    ------------------------------------------------------------------------
    DECLARE @Modules VARCHAR(MAX);

    SELECT
        @Modules =
            STRING_AGG
            (
                CONVERT
                (
                    VARCHAR(MAX),
                    CASE
                    ----------------------------------------------------------------
                    -- Optional round data modules
                    ----------------------------------------------------------------
                    WHEN @RoundDataModulesOnly = 1 AND [ModuleType] = 'Data'
                    THEN
                          '<circle cx="'
                        + CONVERT
                          (VARCHAR(20), (((CONVERT(FLOAT,[X]) + @QuietZone) * @ModuleSize) + (@ModuleSize / 2.0)))
                        + '" cy="'
                        + CONVERT
                          (VARCHAR(20),(((CONVERT(FLOAT,[Y]) + @QuietZone) * @ModuleSize) + (@ModuleSize / 2.0)))
                        + '" r="'
                        + CONVERT
                          (VARCHAR(20), @ModuleSize * 0.45)
                        + '" fill="'
                        + CASE
                            WHEN [ColorHex] IS NOT NULL
                                THEN [ColorHex]
                            WHEN [IsBlack] = 1
                                THEN @ForegroundColor
                            ELSE
                                @BackgroundColor
                        END
                        + '"/>'

                    ----------------------------------------------------------------
                    -- Normale Module
                    ----------------------------------------------------------------
                    ELSE
                          '<rect x="'
                        + CONVERT(VARCHAR(20), (CONVERT(INT,[X]) + @QuietZone) * @ModuleSize)
                        + '" y="'
                        + CONVERT(VARCHAR(20), (CONVERT(INT,[Y]) + @QuietZone) * @ModuleSize)
                        + '" width="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" height="'
                        + CONVERT(VARCHAR(20), @ModuleSize)
                        + '" fill="'
                        + CASE
                            WHEN [ColorHex] IS NOT NULL
                                THEN [ColorHex]
                            WHEN [IsBlack] = 1
                                THEN @ForegroundColor
                            ELSE
                                @BackgroundColor
                        END
                        + '"/>'
                END
            ),
            ''
        )
        WITHIN GROUP
        (
            ORDER BY [Y], [X]
        )
        FROM [QR].[Module]
        WHERE
            [IsBlack] = 1 OR [ColorHex] IS NOT NULL;

    SET @Svg = @Svg + ISNULL(@Modules, '') + '</svg>';
END;
