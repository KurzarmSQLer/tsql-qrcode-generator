
-- ##############################################################################
-- ### Procedure: [QR].[pBuildDataBlocks]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Distributes generated data codewords into QR specification blocks      ###
-- ### according to the selected version and ECC level.                       ###
-- ###                                                                        ###
-- ### The resulting block structure is stored in [QR].[DataBlock].           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### @ErrorCorrectionLevel:        QR error correction level (L, M, Q or H) ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pBuildDataBlocks]
(
      @VersionNumber        TINYINT
    , @ErrorCorrectionLevel CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [QR].[DataBlock];

    DECLARE @GroupNumber                INTEGER
    DECLARE @BlockCount                 INTEGER
    DECLARE @DataCodewordsPerBlock      INTEGER
    DECLARE @SourcePosition             INTEGER = 0
    DECLARE @BlockNumber                INTEGER = 1

    DECLARE C CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          [GroupNumber]
        , [BlockCount]
        , [DataCodewordsPerBlock]
    FROM [QR].[VersionBlockStructure]
    WHERE 1 = 1
        AND [VersionNumber]        = @VersionNumber
        AND [ErrorCorrectionLevel] = @ErrorCorrectionLevel
    ORDER BY [GroupNumber];

    OPEN [C];

    FETCH NEXT FROM [C]
    INTO
          @GroupNumber
        , @BlockCount
        , @DataCodewordsPerBlock;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @CurrentBlock INTEGER = 1;

        WHILE @CurrentBlock <= @BlockCount
        BEGIN
            DECLARE @BlockPosition INTEGER = 0;

            WHILE @BlockPosition < @DataCodewordsPerBlock
            BEGIN
                INSERT INTO [QR].[DataBlock]
                (
                      [BlockNumber]
                    , [Position]
                    , [Value]
                )
                SELECT
                      @BlockNumber
                    , @BlockPosition
                    , [Value]
                FROM [QR].[DataCodeword]
                WHERE [Position] = @SourcePosition;

                SET @SourcePosition     += 1;
                SET @BlockPosition      += 1;
            END

            SET @BlockNumber            += 1;
            SET @CurrentBlock           += 1;
        END

        FETCH NEXT FROM [C]
        INTO
              @GroupNumber
            , @BlockCount
            , @DataCodewordsPerBlock;
    END
    CLOSE [C];
    DEALLOCATE [C];

    -----------------------------------------------------------------
    -- Kontrolle
    -----------------------------------------------------------------
    IF (SELECT COUNT(*) FROM [QR].[DataBlock])
       <>
       (SELECT COUNT(*) FROM [QR].[DataCodeword])
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(MAX)
        SET @ErrorMessage =
              N'DE: Nicht alle Data-Codewords wurden auf Blöcke verteilt.'
            + CHAR(13) + CHAR(10)
            + N'EN: Not all data codewords were distributed across blocks.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
