

-- ##############################################################################
-- ### Procedure: [QR].[pCreateEccBlocks]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates Reed-Solomon error correction codewords for all data blocks    ###
-- ### belonging to the selected QR version and ECC level.                    ###
-- ###                                                                        ###
-- ### Internally calls [QR].[pCreateEccForBlock] for each block.             ###
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
CREATE   PROCEDURE [QR].[pCreateEccBlocks]
(
      @VersionNumber          TINYINT
    , @ErrorCorrectionLevel   CHAR(1)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxBlockNumber     INTEGER;
    DECLARE @BlockNumber        INTEGER = 1;

    DELETE FROM [QR].[EccBlock];

    SELECT
        @MaxBlockNumber = MAX(BlockNumber)
    FROM [QR].[DataBlock];

    WHILE @BlockNumber <= @MaxBlockNumber
    BEGIN
        EXEC [QR].[pCreateEccForBlock]
              @BlockNumber
            , @VersionNumber
            , @ErrorCorrectionLevel;

        SET @BlockNumber += 1;
    END
END;
