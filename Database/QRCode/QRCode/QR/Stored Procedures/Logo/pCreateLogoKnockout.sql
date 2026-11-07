


CREATE   PROCEDURE [QR].[pCreateLogoKnockout]
(
      @MarginModules INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------------
    -- Parameter prüfen
    ------------------------------------------------------------------------

    IF @MarginModules < 0
    BEGIN
        THROW 50700,
              'MarginModules darf nicht negativ sein.',
              1;
    END;

    ------------------------------------------------------------------------
    -- Keine Logoprojektion vorhanden?
    ------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM QR.LogoPlacement
    )
    BEGIN
        RETURN;
    END;

    ------------------------------------------------------------------------
    -- Nur tatsächlich belegte Logozellen freistellen
    ------------------------------------------------------------------------

    UPDATE M
    SET
          IsBlack = 0
        , ColorHex = NULL
    FROM QR.Module M
    WHERE
        M.ModuleType = 'Data'
        AND EXISTS
        (
            SELECT 1
            FROM QR.LogoPlacement P
            WHERE
                   P.TargetX = M.X
               AND P.TargetY = M.Y
        );

    ------------------------------------------------------------------------
    -- Optionaler Sicherheitsrand
    ------------------------------------------------------------------------

    IF @MarginModules > 0
    BEGIN

        UPDATE M
        SET
              IsBlack = 0
            , ColorHex = NULL
        FROM QR.Module M
        WHERE
            M.ModuleType = 'Data'
            AND EXISTS
            (
                SELECT 1
                FROM QR.LogoPlacement P
                WHERE
                       ABS(P.TargetX - M.X) <= @MarginModules
                   AND ABS(P.TargetY - M.Y) <= @MarginModules
            );

    END;

END;
