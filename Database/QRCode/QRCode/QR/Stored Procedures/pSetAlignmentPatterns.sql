
-- ##############################################################################
-- ### Procedure: [QR].[pSetAlignmentPatterns]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Places all alignment patterns required by the selected QR version.     ###
-- ### Coordinates are obtained from [QR].[AlignmentPatternPosition].         ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pSetAlignmentPatterns]
(
    @VersionNumber      TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VersionNumber = 1
        RETURN;

    DECLARE
          @X INT
        , @Y INT;

    DECLARE [C] CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          [X]
        , [Y]
    FROM [QR].[AlignmentPatternPosition]
    WHERE [VersionNumber] = @VersionNumber;

    OPEN [C];

    FETCH NEXT FROM [C]
    INTO
          @X
        , @Y;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC [QR].[pSetAlignmentPattern]
              @CenterX = @X
            , @CenterY = @Y;

        FETCH NEXT FROM [C]
        INTO
              @X
            , @Y;
    END

    CLOSE [C];
    DEALLOCATE [C];
END;
