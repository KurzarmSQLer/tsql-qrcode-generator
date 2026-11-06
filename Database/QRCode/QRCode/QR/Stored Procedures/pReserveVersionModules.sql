


-- ##############################################################################
-- ### Procedure: [QR].[pReserveVersionModules]                               ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Reserves the matrix locations required for QR version information.     ###
-- ###                                                                        ###
-- ### Version information exists only for QR versions 7 and higher.          ###
-- ###                                                                        ###
-- ### Two dedicated version-information areas are reserved:                  ###
-- ###                                                                        ###
-- ###   - Top-right  (3 × 6 modules)                                         ###
-- ###   - Bottom-left (6 × 3 modules)                                        ###
-- ###                                                                        ###
-- ### Reserved modules are protected from later payload placement.           ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pReserveVersionModules]
(
    @VersionNumber TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VersionNumber < 7
        RETURN;

    DECLARE @MatrixSize INTEGER;

    SELECT
        @MatrixSize = MAX([X]) + 1
    FROM [QR].[Module];

    --------------------------------------------------------------------------
    -- Top Right
    --------------------------------------------------------------------------

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = 0
        , [ModuleType] = 'Version'
    WHERE
            [X] BETWEEN @MatrixSize - 11 AND @MatrixSize - 9
        AND [Y] BETWEEN 0 AND 5;

    --------------------------------------------------------------------------
    -- Bottom Left
    --------------------------------------------------------------------------

    UPDATE [QR].[Module]
    SET
          [IsBlack]    = 0
        , [ModuleType] = 'Version'
    WHERE
            [X] BETWEEN 0 AND 5
        AND [Y] BETWEEN @MatrixSize - 11 AND @MatrixSize - 9;
END;
