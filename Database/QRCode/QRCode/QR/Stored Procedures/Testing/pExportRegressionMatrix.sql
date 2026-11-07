
-- ##############################################################################
-- ### Procedure: [QR].[pExportRegressionMatrix]                              ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Exports the currently generated QR matrix in a deterministic format    ###
-- ### suitable for comparison against external reference implementations.    ###
-- ###                                                                        ###
-- ### The result set is intentionally aligned with the CSV structure used    ###
-- ### during validation against the Nayuki QR Code Generator reference       ###
-- ### implementation.                                                        ###
-- ###                                                                        ###
-- ### Typical use cases:                                                     ###
-- ###   - Regression testing                                                 ###
-- ###   - Matrix comparison                                                  ###
-- ###   - Validation against Nayuki                                          ###
-- ###   - Root-cause analysis of QR generation defects                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Result Set:                                                            ###
-- ### X:                           Matrix X coordinate                       ###
-- ### Y:                           Matrix Y coordinate                       ###
-- ### IsBlack:                     Module color (0/1)                        ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pExportRegressionMatrix]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
          [X]
        , [Y]
        , CONVERT(TINYINT, [IsBlack]) AS [IsBlack]
    FROM [QR].[Module]
    ORDER BY
          [Y]
        , [X];
END;
