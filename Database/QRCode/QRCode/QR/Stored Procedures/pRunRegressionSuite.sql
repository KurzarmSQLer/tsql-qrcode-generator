
-- ##############################################################################
-- ### Procedure: [QR].[pRunRegressionSuite]                                  ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Executes all registered QR regression test cases.                      ###
-- ###                                                                        ###
-- ### The procedure iterates through [QR].[RegressionTest] and executes      ###
-- ### every configured test scenario using [QR].[pRunRegressionTest].        ###
-- ###                                                                        ###
-- ### The resulting execution statistics allow verification that core QR     ###
-- ### functionality remains stable across code changes.                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### None                                                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pRunRegressionSuite]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TestName VARCHAR(100);

    DECLARE C CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT [TestName]
    FROM [QR].[RegressionTest]
    ORDER BY [TestName];

    OPEN C;

    FETCH NEXT
    FROM C
    INTO @TestName;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        EXEC [QR].[pRunRegressionTest]
             @TestName = @TestName;

        FETCH NEXT
        FROM C
        INTO @TestName;
    END;

    CLOSE C;
    DEALLOCATE C;

    SELECT
          [TestName]
        , [Success]
        , [Details]
        , [ExecutionTimestamp]
    FROM [QR].[RegressionTestResult]
    ORDER BY [ExecutionTimestamp] DESC;
END;
