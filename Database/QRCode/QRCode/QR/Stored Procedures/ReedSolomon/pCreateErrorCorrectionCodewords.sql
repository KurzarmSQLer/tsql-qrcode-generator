


CREATE   PROCEDURE [QR].[pCreateErrorCorrectionCodewords]
(
     @VersionNumber         TINYINT,
     @ErrorCorrectionLevel  CHAR(1)
)
AS
BEGIN
    DECLARE @DataCodewords INT;

    SET @DataCodewords =
        [QR].[fnGetDataCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DECLARE @EccCodewords INT;

    SET @EccCodewords =
        [QR].[fnGetEccCodewords]
        (
              @VersionNumber
            , @ErrorCorrectionLevel
        );

    DECLARE @Generator TABLE
    (
          [Position]        INTEGER             PRIMARY KEY
        , [Coefficient]     INTEGER NOT NULL
    );

    INSERT INTO @Generator
    (
          [Position]
        , [Coefficient]
    )
    SELECT
          [Position]
        , [Coefficient]
    FROM [QR].[GeneratorPolynomial]
    WHERE [EccCodewords] = @EccCodewords;

    IF NOT EXISTS
    (
        SELECT 1
        FROM @Generator
    )
    BEGIN
        THROW 70002, 'Kein Generatorpolynom für diese ECC-Länge vorhanden.', 1;
    END;
END;
