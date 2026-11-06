
-- ##############################################################################
-- ### Procedure: [QR].[pInterleaveCodewords]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Interleaves data codewords and Reed-Solomon error correction           ###
-- ### codewords according to the QR specification.                           ###
-- ### The result is stored in [QR].[InterleavedCodeword].                    ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                      Internal                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pInterleaveCodewords]
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [QR].[InterleavedCodeword];

    DECLARE @Position INT = 0;
        DECLARE @MaxDataPosition INT;

    SELECT
        @MaxDataPosition = MAX(Position)
    FROM QR.DataBlock;

    DECLARE @DataPosition       INTEGER = 0;
    DECLARE @MaxEccPosition     INTEGER;
    DECLARE @EccPosition        INTEGER = 0;

    WHILE @DataPosition <= @MaxDataPosition
    BEGIN
        INSERT INTO [QR].[InterleavedCodeword]
        (
              [Position]
            , [Value]
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY [BlockNumber]
                ) - 1
            , Value
        FROM [QR].[DataBlock]
        WHERE [Position] = @DataPosition;

        SET @Position += @@ROWCOUNT;

        SET @DataPosition += 1;
    END;

    SELECT
        @MaxEccPosition = MAX([Position])
    FROM [QR].[EccBlock];

    WHILE @EccPosition <= @MaxEccPosition
    BEGIN
        INSERT INTO [QR].[InterleavedCodeword]
        (
              [Position]
            , [Value]
        )
        SELECT
              @Position
            + ROW_NUMBER()
                OVER
                (
                    ORDER BY [BlockNumber]
                ) - 1
            , [Value]
        FROM [QR].[EccBlock]
        WHERE [Position] = @EccPosition;

        SET @Position += @@ROWCOUNT;
        SET @EccPosition += 1;
    END;
END;
