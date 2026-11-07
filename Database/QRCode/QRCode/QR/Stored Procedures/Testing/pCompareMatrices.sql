


-- ##############################################################################
-- ### Procedure: [QR].[pCompareMatrices]                                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Compares two QR matrices and identifies all differing modules.         ###
-- ###                                                                        ###
-- ### The procedure is intended for regression testing and validation        ###
-- ### against external reference implementations such as the Nayuki QR       ###
-- ### Code Generator reference implementation.                               ###
-- ###                                                                        ###
-- ### The matrices must be provided through temporary tables or persistent   ###
-- ### tables with the following structure:                                   ###
-- ###                                                                        ###
-- ###     X         INT                                                      ###
-- ###     Y         INT                                                      ###
-- ###     IsBlack   BIT                                                      ###
-- ###                                                                        ###
-- ### The procedure returns:                                                 ###
-- ###   - Total difference count                                             ###
-- ###   - First differing coordinate                                         ###
-- ###   - Detailed list of differences                                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ExpectedTableName:          Expected matrix table                     ###
-- ### @ActualTableName:            Actual matrix table                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @DifferenceCount:            Number of differing modules               ###
-- ### @FirstDifferenceX:           X coordinate of first difference          ###
-- ### @FirstDifferenceY:           Y coordinate of first difference          ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCompareMatrices]
(
      @ExpectedTableName     SYSNAME
    , @ActualTableName       SYSNAME
    , @TestName              VARCHAR(100)
    , @DifferenceCount       INTEGER            OUTPUT
    , @FirstDifferenceX      INTEGER            OUTPUT
    , @FirstDifferenceY      INTEGER            OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @DifferenceCount = COUNT(*)
    FROM [QR].[RegressionGoldenMatrix] AS [G]
    INNER JOIN [QR].[Module]           AS [M]
        ON  [M].[X] = [G].[X]
        AND [M].[Y] = [G].[Y]
    WHERE
            [G].[TestName] = @TestName
        AND CONVERT(TINYINT,[M].[IsBlack])
            <>
            CONVERT(TINYINT,[G].[IsBlack]);

    SELECT TOP (1)
          @FirstDifferenceX = [G].[X]
        , @FirstDifferenceY = [G].[Y]
    FROM [QR].[RegressionGoldenMatrix] AS [G]
    INNER JOIN [QR].[Module]           AS [M]
        ON  [M].[X] = [G].[X]
        AND [M].[Y] = [G].[Y]
    WHERE
            [G].[TestName] = @TestName
        AND CONVERT(TINYINT,[M].[IsBlack])
            <>
            CONVERT(TINYINT,[G].[IsBlack])
    ORDER BY
          [G].[Y]
        , [G].[X];

    -------------------------------------------------------------------------
    -- Summary Result
    -------------------------------------------------------------------------

    SELECT
          @DifferenceCount    AS [DifferenceCount]
        , @FirstDifferenceX   AS [FirstDifferenceX]
        , @FirstDifferenceY   AS [FirstDifferenceY];

    -------------------------------------------------------------------------
    -- Detailed Differences
    -------------------------------------------------------------------------

    SELECT
          [X]
        , [Y]
        , [Expected]
        , [Actual]
    FROM #Differences
    ORDER BY
          [Y]
        , [X];
END;
