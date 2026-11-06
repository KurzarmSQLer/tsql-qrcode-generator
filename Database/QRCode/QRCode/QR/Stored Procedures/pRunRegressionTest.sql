
-- ##############################################################################
-- ### Procedure: [QR].[pRunRegressionTest]                                   ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Executes a single predefined QR regression test case.                  ###
-- ###                                                                        ###
-- ### The procedure loads the specified test definition from                 ###
-- ### [QR].[RegressionTest], generates the corresponding QR code and         ###
-- ### validates the resulting matrix.                                        ###
-- ###                                                                        ###
-- ### Execution results are persisted in [QR].[RegressionTestResult].        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @TestName:                    Name of the regression test case         ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pRunRegressionTest]
(
    @TestName VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InputText              VARCHAR(MAX)
    DECLARE @VersionNumber          TINYINT
    DECLARE @ErrorCorrectionLevel   CHAR(1);
    DECLARE @ExecutionId            UNIQUEIDENTIFIER = NEWID();

    BEGIN TRY
        SELECT
              @InputText            = [InputText]
            , @VersionNumber        = [VersionNumber]
            , @ErrorCorrectionLevel = [ErrorCorrectionLevel]
        FROM [QR].[RegressionTest]
        WHERE [TestName] = @TestName;

        IF @InputText IS NULL
        BEGIN
            THROW 78000,
                  'RegressionTest not found.',
                  1;
        END;

        EXEC [QR].[pCreateQrCode]
             @Text                 = @InputText,
             @VersionNumber        = @VersionNumber,
             @ErrorCorrectionLevel = @ErrorCorrectionLevel;

        DECLARE @ExpectedModuleCount        INTEGER
        DECLARE @ActualModuleCount          INTEGER
        DECLARE @NullModuleCount            INTEGER
        DECLARE @Success                    BIT;
        DECLARE @DifferenceCount            INTEGER
        DECLARE @FirstDifferenceX           INTEGER
        DECLARE @FirstDifferenceY           INTEGER
        DECLARE @TestStatus                 VARCHAR(20);

        EXEC [QR].[pValidateRegressionResult]
             @VersionNumber       = @VersionNumber,
             @ExpectedModuleCount = @ExpectedModuleCount    OUTPUT,
             @ActualModuleCount   = @ActualModuleCount      OUTPUT,
             @NullModuleCount     = @NullModuleCount        OUTPUT,
             @Success             = @Success                OUTPUT;

        EXEC [QR].[pCompareMatrices]
             @TestName         = @TestName
           , @DifferenceCount  = @DifferenceCount           OUTPUT
           , @FirstDifferenceX = @FirstDifferenceX          OUTPUT
           , @FirstDifferenceY = @FirstDifferenceY          OUTPUT;

        IF @DifferenceCount = 0
        BEGIN
            SET @TestStatus = 'PASS';
            SET @Success = 1;
        END;
        ELSE
        BEGIN
            SET @TestStatus = 'FAIL';
            SET @Success = 0;
        END;

        INSERT INTO [QR].[RegressionTestResult]
        (
              [ExecutionId]
            , [TestName]
            , [ExecutionTimestamp]
            , [VersionNumber]
            , [ErrorCorrectionLevel]
            , [ExpectedModuleCount]
            , [ActualModuleCount]
            , [NullModuleCount]
            , [Success]
            , [Details]
            , [DifferenceCount]
            , [FirstDifferenceX]
            , [FirstDifferenceY]
            , [TestStatus]
        )
        VALUES
        (
              NEWID()
            , @TestName
            , SYSUTCDATETIME()
            , @VersionNumber
            , @ErrorCorrectionLevel
            , @ExpectedModuleCount
            , @ActualModuleCount
            , @NullModuleCount
            , @Success
            , CASE
                  WHEN @Success = 1
                      THEN N'OK'
                  ELSE N'Validation failed'
              END
            , @DifferenceCount
            , @FirstDifferenceX
            , @FirstDifferenceY
            , @TestStatus
        );
    END TRY
    BEGIN CATCH

        INSERT INTO [QR].[RegressionTestResult]
        (
              [ExecutionId]
            , [ExecutionTimestamp]
            , [TestName]
            , [InputText]
            , [VersionNumber]
            , [ErrorCorrectionLevel]
            , [MatrixSize]
            , [ExpectedModuleCount]
            , [ActualModuleCount]
            , [NullModuleCount]
            , [DarkModuleCount]
            , [FormatModuleCount]
            , [VersionModuleCount]
            , [DifferenceCount]
            , [FirstDifferenceX]
            , [FirstDifferenceY]
            , [DurationMilliseconds]
            , [Success]
            , [TestStatus]
            , [ErrorNumber]
            , [ErrorMessage]
            , [Details]
        )
        VALUES
        (
              @ExecutionId
            , SYSUTCDATETIME()
            , @TestName
            , @InputText
            , @VersionNumber
            , @ErrorCorrectionLevel
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , NULL
            , NULL
            , NULL
            , NULL
            , 0
            , 'ERROR'
            , ERROR_NUMBER()
            , ERROR_MESSAGE()
            , N'Regression test aborted.'
        );

    END CATCH;
END;
