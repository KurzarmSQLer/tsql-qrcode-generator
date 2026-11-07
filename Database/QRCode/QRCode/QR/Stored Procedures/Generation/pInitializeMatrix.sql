
-- ##############################################################################
-- ### Procedure: [QR].[pInitializeMatrix]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates an empty QR matrix for the selected version.                   ###
-- ### The procedure initializes [QR].[Module] and creates one record for     ###
-- ### every matrix coordinate.                                               ###
-- ### All modules are initially marked as undefined and are populated by     ###
-- ### subsequent matrix construction procedures.                             ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                     Internal                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:                QR version number                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pInitializeMatrix]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize INT;

    SET @MatrixSize =
        QR.fnGetMatrixSize(@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'EN: Invalid QR code version.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    DELETE
    FROM [QR].[Module];

    ;WITH [N] AS
    (
        SELECT 0 AS [N]

        UNION ALL

        SELECT [N] + 1
        FROM [N]
        WHERE [N] + 1 < @MatrixSize
    )
    INSERT INTO [QR].[Module]
    (
          [X]
        , [Y]
        , [IsBlack]
        , [ModuleType]
        , [ColorHex]
    )
    SELECT
          [X].[N]
        , [Y].[N]
        , NULL
        , NULL
        , NULL
    FROM [N] AS [X]
    CROSS JOIN [N] AS [Y]
    OPTION (MAXRECURSION 200);
END;
