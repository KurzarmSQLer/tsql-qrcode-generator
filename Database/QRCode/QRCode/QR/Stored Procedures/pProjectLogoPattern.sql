
-- ##############################################################################
-- ### Procedure: [QR].[pProjectLogoPattern]                                  ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Projects a logo stored in [QR].[LogoPattern] into the selected         ###
-- ### logo area of the QR matrix. The logo is automatically scaled to fit    ###
-- ### the target area while preserving the original aspect ratio. Source     ###
-- ### pixels are written to [QR].[LogoPlacement].                            ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @LogoName:               Logo identifier stored in [QR].[LogoPattern]  ###
-- ### @StartX:                 Left boundary of the target area              ###
-- ### @StartY:                 Upper boundary of the target area             ###
-- ### @Width:                  Width of the target area                      ###
-- ### @Height:                 Height of the target area                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pProjectLogoPattern]
(
      @LogoName VARCHAR(50)
    , @StartX   INT
    , @StartY   INT
    , @Width    INT
    , @Height   INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LogoWidth  INTEGER;
    DECLARE @LogoHeight INTEGER;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [QR].[LogoPattern]
        WHERE [LogoName] = @LogoName
    )
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Logo ' + @LogoName + N' wurde nicht gefunden.'
            + CHAR(13) + CHAR(10)
            + N'Logo ' + @LogoName + N' was not found.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
          @LogoWidth  = MAX([X]) + 1
        , @LogoHeight = MAX([Y]) + 1
    FROM [QR].[LogoPattern]
    WHERE [LogoName] = @LogoName;

    IF @LogoWidth IS NULL OR @LogoHeight IS NULL
    BEGIN
        SET @ErrorMessage =
              N'Logo besitzt keine gültigen Pixeldaten.'
            + CHAR(13) + CHAR(10)
            + N'The logo does not contain valid pixel data.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    IF @LogoWidth <= 0
       OR @LogoHeight <= 0
    BEGIN
        SET @ErrorMessage =
              N'Logo besitzt keine gültige Größe.'
            + CHAR(13) + CHAR(10)
            + N'The logo does not have a valid size.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    DELETE
    FROM [QR].[LogoPlacement]
    WHERE [LogoName] = @LogoName;

    ;WITH [TargetCells] AS
    (
        SELECT
              [X] = @StartX + [X].[N]
            , [Y] = @StartY + [Y].[N]
        FROM
        (
            SELECT TOP (@Width)
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
            FROM sys.objects
        ) AS X

        CROSS JOIN
        (
            SELECT TOP (@Height)
                   ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
            FROM sys.objects
        ) AS Y
    )

    INSERT INTO [QR].[LogoPlacement]
    (
          [LogoName]
        , [TargetX]
        , [TargetY]
        , [SourceX]
        , [SourceY]
        , [ColorClass]
    )
    SELECT
          @LogoName
        , [T].[X]
        , [T].[Y]
        , FLOOR([TX].[SourceX])
        , FLOOR([TY].[SourceY])
        , [P].[ColorClass]
    FROM [TargetCells]                                                                  AS [T]
    CROSS APPLY
    (
        SELECT ((([T].[X] - @StartX) + 0.5) * CONVERT(FLOAT,@LogoWidth) / @Width)       AS [SourceX]
    )                                                                                   AS [TX]

    CROSS APPLY
    (
        SELECT ((([T].[Y] - @StartY) + 0.5) * CONVERT(FLOAT,@LogoHeight) / @Height)     AS [SourceY]
    )                                                                                   AS [TY]
    INNER JOIN [QR].[LogoPattern]                                                       AS [P]
        ON 1 = 1
            AND [P].[LogoName] = @LogoName
            AND [P].[X] =
                CASE
                    WHEN FLOOR([TX].[SourceX]) >= @LogoWidth
                        THEN @LogoWidth - 1
                    ELSE FLOOR([TX].[SourceX])
                END
            AND [P].[Y] =
                CASE
                    WHEN FLOOR([TY].[SourceY]) >= @LogoHeight
                        THEN @LogoHeight - 1
                    ELSE FLOOR([TY].[SourceY])
                END
END;
