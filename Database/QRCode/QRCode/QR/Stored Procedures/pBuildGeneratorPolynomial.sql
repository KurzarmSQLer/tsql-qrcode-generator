

CREATE   PROCEDURE [QR].[pBuildGeneratorPolynomial]
(
    @EccCodewords INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @EccCodewords < 1
    BEGIN
        THROW 71000,
              'EccCodewords muss größer als 0 sein.',
              1;
    END;

    DELETE
    FROM [QR].[GeneratorPolynomial]
    WHERE [EccCodewords] = @EccCodewords;

    -------------------------------------------------------------------------
    -- Startpolynom g(x)=1
    -------------------------------------------------------------------------

    DECLARE @Poly TABLE
    (
          [Position]    INT NOT NULL
        , [Coefficient] INT NOT NULL
    );

    INSERT INTO @Poly
    (
          [Position]
        , [Coefficient]
    )
    VALUES
    (
          0
        , 1
    );

    DECLARE @Exponent INT = 0;

    WHILE @Exponent < @EccCodewords
    BEGIN

        DECLARE @RootValue INT;

        SELECT
            @RootValue = [Value]
        FROM [QR].[GaloisExp]
        WHERE [Exponent] = @Exponent;

        ---------------------------------------------------------------------
        -- Produktterme bilden
        ---------------------------------------------------------------------

        DECLARE @Products TABLE
        (
              [Position] INT NOT NULL
            , [Value]    INT NOT NULL
        );

        INSERT INTO @Products
        (
              [Position]
            , [Value]
        )
        SELECT
              [P].[Position] + [F].[Position]
            , [QR].[fnGaloisMultiply]
              (
                    [P].[Coefficient]
                  , [F].[Coefficient]
              )
        FROM @Poly AS [P]
        CROSS JOIN
        (
            VALUES
                  (0, @RootValue)
                , (1, 1)
        ) AS [F]
        (
              [Position]
            , [Coefficient]
        );

        ---------------------------------------------------------------------
        -- XOR-Reduktion
        ---------------------------------------------------------------------

        DECLARE @Result TABLE
        (
              [Position]    INT NOT NULL
            , [Coefficient] INT NOT NULL
        );

        DECLARE @ResultPosition INT = 0;
        DECLARE @MaxPosition INT;

        SELECT
            @MaxPosition = MAX([Position])
        FROM @Products;

        WHILE @ResultPosition <= @MaxPosition
        BEGIN

            DECLARE @ResultCoeff INT = 0;

            DECLARE @Values TABLE
            (
                  [ID] INT IDENTITY(1,1)
                , [Value] INT
            );

            INSERT INTO @Values
            (
                  [Value]
            )
            SELECT
                [Value]
            FROM @Products
            WHERE [Position] = @ResultPosition;

            DECLARE
                  @ResultID INT = 1
                , @ResultMaxID INT;

            SELECT
                @ResultMaxID = MAX([ID])
            FROM @Values;

            WHILE @ResultID <= ISNULL(@ResultMaxID,0)
            BEGIN

                DECLARE @CurrentValue INT;

                SELECT
                    @CurrentValue = [Value]
                FROM @Values
                WHERE [ID] = @ResultID;

                SET @ResultCoeff =
                    @ResultCoeff ^ @CurrentValue;

                SET @ResultID += 1;
            END;

            INSERT INTO @Result
            (
                  [Position]
                , [Coefficient]
            )
            VALUES
            (
                  @ResultPosition
                , @ResultCoeff
            );

            SET @ResultPosition += 1;
        END;

        ---------------------------------------------------------------------
        -- Neues Polynom übernehmen
        ---------------------------------------------------------------------

        DELETE
        FROM @Poly;

        INSERT INTO @Poly
        (
              [Position]
            , [Coefficient]
        )
        SELECT
              [Position]
            , [Coefficient]
        FROM @Result
        ORDER BY [Position];

        SET @Exponent += 1;
    END;

    -------------------------------------------------------------------------
    -- Ergebnis speichern
    -------------------------------------------------------------------------


    SELECT
      [Position]
    , [Coefficient]
FROM @Poly
ORDER BY [Position];

SELECT
      [Position]
    , COUNT(*) AS [Anzahl]
FROM @Poly
GROUP BY [Position]
HAVING COUNT(*) > 1;

SELECT
      [Position]
    , [Coefficient]
FROM @Poly
ORDER BY
      [Position]
    , [Coefficient];

SELECT
      [Position]
    , COUNT(*) AS [Anzahl]
FROM @Poly
GROUP BY [Position];

    INSERT INTO [QR].[GeneratorPolynomial]
    (
          [EccCodewords]
        , [Position]
        , [Coefficient]
    )
    SELECT
          @EccCodewords
        , [Position]
        , [Coefficient]
    FROM @Poly
    ORDER BY [Position];

END;
