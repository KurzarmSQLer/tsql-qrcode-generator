
-- ##############################################################################
-- ### Procedure: [QR].[pReserveFormatModules]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Reserves matrix locations required for QR format information.          ###
-- ### Reserved modules are protected from later payload placement.           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pReserveFormatModules]
(
    @VersionNumber TINYINT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize INT;

    SET @MatrixSize = [QR].[fnGetMatrixSize](@VersionNumber);

    IF @MatrixSize <= 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Ungültige QR-Version.'
            + CHAR(13) + CHAR(10)
            + N'Invalid QR code version.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = NULL
        , [ModuleType] = 'Format'
    WHERE

        -- -----------------------------------------------------------
        -- First copy, top left
        -- ----------------------------------------------------------- */
        (X = 8 AND Y IN (0,1,2,3,4,5,7,8))          -- Note: Not 6, because that's where the sync line is
        OR
        (Y = 8 AND X IN (0,1,2,3,4,5,7,8))          -- Note: Not 6, because that's where the sync line is

        -- -----------------------------------------------------------
        -- Second copy, top right
        -- -----------------------------------------------------------
        OR
        (
                Y = 8
            AND X BETWEEN (@MatrixSize - 8)
                      AND (@MatrixSize - 1)
        )

        -- -----------------------------------------------------------
        -- third copy, bottom left
        -- -----------------------------------------------------------
        OR
        (
                X = 8
            AND Y BETWEEN (@MatrixSize - 7)
                      AND (@MatrixSize - 1)
        );
END;
