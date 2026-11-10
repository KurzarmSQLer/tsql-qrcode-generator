CREATE PROCEDURE [QR].[pBuildGaloisTables]
AS
BEGIN
    -- ##############################################################################
    -- ### Procedure: [QR].[pBuildGaloisTables]                                   ###
    -- ##############################################################################
    -- ### Purpose:                                                               ###
    -- ### Creates and populates the Galois lookup tables used for Reed-Solomon   ###
    -- ### error correction calculations.                                         ###
    -- ###                                                                        ###
    -- ### The procedure fills [QR].[GaloisLog] and [QR].[GaloisExp].             ###
    -- ###                                                                        ###
    -- ### This procedure only needs to be executed when the lookup tables are    ###
    -- ### missing or empty.                                                      ###
    -- ### ---------------------------------------------------------------------- ###
    -- ### API Level:                     Internal                                ###
    -- ### ---------------------------------------------------------------------- ###
    -- ### Input parameters:                                                      ###
    -- ### None                                                                   ###
    -- ### ---------------------------------------------------------------------- ###
    -- ### Output parameters:                                                     ###
    -- ### None                                                                   ###
    -- ##############################################################################
    SET NOCOUNT ON;

    TRUNCATE TABLE [QR].[GaloisExp];
    TRUNCATE TABLE [QR].[GaloisLog];

    DECLARE
          @Exponent INT = 0
        , @Value    INT = 1
        , @Next     INT;

    WHILE @Exponent < 255
    BEGIN

        INSERT INTO [QR].[GaloisExp]
        (
              [Exponent]
            , [Value]
        )
        VALUES
        (
              @Exponent
            , @Value
        );

        INSERT INTO [QR].[GaloisLog]
        (
              [Value]
            , [LogValue]
        )
        VALUES
        (
              @Value
            , @Exponent
        );

        SET @Next = @Value * 2;

        IF @Next >= 256
            SET @Next = @Next ^ 285;

        SET @Value = @Next;

        SET @Exponent += 1;
    END;

    INSERT INTO [QR].[GaloisExp]
    (
          [Exponent]
        , [Value]
    )
    SELECT
          [Exponent] + 255
        , [Value]
    FROM [QR].[GaloisExp]
    WHERE [Exponent] < 255;
END;
