
-- ##############################################################################
-- ### Procedure: [QR].[pDetermineLargestLogoArea]                            ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Identifies the largest rectangular area inside the QR matrix that can  ###
-- ### be used for logo placement without overwriting structural QR elements. ###
-- ###                                                                        ###
-- ### The procedure analyzes the current QR matrix and determines the        ###
-- ### largest available free rectangle suitable for logo projection.         ###
-- ###                                                                        ###
-- ### The resulting area definition is stored in [QR].[LogoArea].            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                                                             ###
-- ###   Internal                                                             ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ###   None                                                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ###   None                                                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Generated Data:                                                        ###
-- ###   [QR].[LogoArea]                                                      ###
-- ###     AreaName                                                           ###
-- ###     StartX                                                             ###
-- ###     StartY                                                             ###
-- ###     EndX                                                               ###
-- ###     EndY                                                               ###
-- ###     Width                                                              ###
-- ###     Height                                                             ###
-- ###     Area                                                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Notes:                                                                 ###
-- ###   The preferred placement area is stored using the area name           ###
-- ###   'LargestFreeRectangle'.                                              ###
-- ###                                                                        ###
-- ###   The resulting coordinates are later consumed by                      ###
-- ###   [QR].[pProjectLogoPattern].                                          ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pDetermineLargestLogoArea]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BestStartX                 INTEGER = NULL
    DECLARE @BestStartY                 INTEGER = NULL
    DECLARE @BestEndX                   INTEGER = NULL
    DECLARE @BestEndY                   INTEGER = NULL
    DECLARE @BestArea                   INTEGER = 0;
    DECLARE @StartX                     INTEGER
    DECLARE @StartY                     INTEGER
    DECLARE @EndX                       INTEGER
    DECLARE @EndY                       INTEGER
    DECLARE @Area                       INTEGER
    DECLARE @MatrixSize                 INTEGER;
    DECLARE @ProtectAlignmentPatterns   BIT;

    SELECT
        @ProtectAlignmentPatterns =
            TRY_CAST([ConfigurationValue] AS BIT)
    FROM [QR].[Configuration]
    WHERE [ConfigurationKey] =
          'ProtectAlignmentPatterns';

    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    SET @StartY = 0;

    WHILE @StartY <= @MatrixSize - 1
    BEGIN
        SET @StartX = 0;

        WHILE @StartX <= @MatrixSize - 1
        BEGIN

            SET @EndY = @StartY;

            WHILE @EndY <= @MatrixSize - 1
            BEGIN

                SET @EndX = @StartX;

                WHILE @EndX <= @MatrixSize - 1
                BEGIN

                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM [QR].[Module]
                        WHERE 1 = 1
                            AND [X] BETWEEN @StartX AND @EndX
                            AND [Y] BETWEEN @StartY AND @EndY
                            AND
                            (
                                   [ModuleType] IN
                                   (
                                        'Finder',
                                        'Separator',
                                        'Timing',
                                        'Format',
                                        'Version',
                                        'DarkModule'
                                   )
                                OR (
                                        @ProtectAlignmentPatterns   = 1
                                    AND [ModuleType]                = 'Alignment'
                                   )
                            )
                    )
                    BEGIN
                        SET @Area =
                            (@EndX - @StartX + 1)
                          * (@EndY - @StartY + 1);

                        IF @Area > @BestArea
                        BEGIN
                            SET @BestArea   = @Area;
                            SET @BestStartX = @StartX;
                            SET @BestStartY = @StartY;
                            SET @BestEndX   = @EndX;
                            SET @BestEndY   = @EndY;
                        END
                    END

                    SET @EndX = @EndX + 1;
                END

                SET @EndY = @EndY + 1;
            END

            SET @StartX = @StartX + 1;
        END

        SET @StartY = @StartY + 1;
    END

    DELETE
    FROM [QR].[LogoArea]
    WHERE [AreaName] = 'LargestFreeRectangle';

    INSERT INTO [QR].[LogoArea]
    (
          [AreaName]
        , [StartX]
        , [StartY]
        , [EndX]
        , [EndY]
        , [Width]
        , [Height]
        , [Area]
    )
    VALUES
    (
          'LargestFreeRectangle'
        , @BestStartX
        , @BestStartY
        , @BestEndX
        , @BestEndY
        , (@BestEndX - @BestStartX + 1)
        , (@BestEndY - @BestStartY + 1)
        , @BestArea
    );
END;
