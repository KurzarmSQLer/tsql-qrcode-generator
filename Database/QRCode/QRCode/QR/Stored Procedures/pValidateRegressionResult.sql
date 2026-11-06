
-- ##############################################################################
-- ### Procedure: [QR].[pValidateRegressionResult]                            ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Performs technical validation checks on a generated QR matrix.         ###
-- ###                                                                        ###
-- ### The procedure verifies structural integrity including matrix size,     ###
-- ### module count and completeness of module assignment.                    ###
-- ###                                                                        ###
-- ### Validation results are returned through output parameters and can be   ###
-- ### consumed by regression-test runners or automated quality checks.       ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                    Internal                                 ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:               QR version number                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @ExpectedModuleCount:         Expected module count                    ###
-- ### @ActualModuleCount:           Actual module count                      ###
-- ### @NullModuleCount:             Number of uninitialized modules          ###
-- ### @Success:                     Validation result flag                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pValidateRegressionResult]
(
      @VersionNumber         TINYINT
    , @Success               BIT            OUTPUT
    , @ExpectedModuleCount   INTEGER        OUTPUT
    , @ActualModuleCount     INTEGER        OUTPUT
    , @NullModuleCount       INTEGER        OUTPUT
    , @MatrixSize            INTEGER        OUTPUT
    , @DarkModuleCount       INTEGER        OUTPUT
    , @FormatModuleCount     INTEGER        OUTPUT
    , @VersionModuleCount    INTEGER        OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @MatrixSize =
        [QR].[fnGetMatrixSize]
        (
            @VersionNumber
        );

    SELECT
        @DarkModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [IsBlack] = 1;

    SELECT
        @FormatModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] = 'Format';

    SELECT
        @VersionModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] = 'Version';

    SET @ExpectedModuleCount =
        @MatrixSize * @MatrixSize;

    SELECT
        @ActualModuleCount = COUNT(*)
    FROM [QR].[Module];

    SELECT
        @NullModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [IsBlack] IS NULL;

    SET @Success =
        CASE
            WHEN @ActualModuleCount <> @ExpectedModuleCount THEN 0
            WHEN @NullModuleCount > 0 THEN 0
            ELSE 1
        END;
END;
