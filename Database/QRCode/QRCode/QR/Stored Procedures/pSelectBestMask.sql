
-- ##############################################################################
-- ### Procedure: [QR].[pSelectBestMask]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Evaluates all eight QR mask patterns and selects the mask with the     ###
-- ### lowest penalty score.                                                  ###
-- ### After selection, the corresponding format information is written       ###
-- ### to the QR matrix.                                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                  Internal                                   ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ErrorCorrectionLevel:      QR error correction level                  ###
-- ### @VersionNumber:             QR version number                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pSelectBestMask]
    @ErrorCorrectionLevel CHAR(1)       = 'M',
    @VersionNumber        TINYINT       = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- ========================================================================
    -- Determine the Best QR Mask
    -- ------------------------------------------------------------------------
    -- Prerequisites:
    --     - 208 data modules exist
    --     - These data modules are still unmasked
    --     - The format modules are reserved
    --     - Format modules have IsBlack = NULL
    --
    -- Procedure:
    --     1. Save the original state of the 208 data modules
    --     2. Test masks 0 through 7
    --     3. Set the respective format information
    --     4. Calculate penalty rules 1 through 4
    --     5. Determine the lowest total penalty
    --     6. Restore the original data
    --     7. Apply the winning mask
    --     8. Set the appropriate format information
    -- ========================================================================

    -- ------------------------------------------------------------------------
    -- Check Matrix State
    -- ------------------------------------------------------------------------
    DECLARE @DataModuleCount        INTEGER;
    DECLARE @FormatModuleCount      INTEGER;

    SELECT
        @DataModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF @DataModuleCount = 0
    BEGIN
        DECLARE @ErrorMessage       NVARCHAR(300);
        SET @ErrorMessage =
              N'Es wurden keine Datenmodule gefunden.'
            + CHAR(13) + CHAR(10)
            + N'No data modules were found.'
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    SELECT
        @FormatModuleCount = COUNT(*)
    FROM [QR].[Module]
    WHERE [ModuleType] = 'Format';


    IF @FormatModuleCount <> 30
    BEGIN
        SET @ErrorMessage =
              N'Es muessen exakt 30 reservierte Formatmodule vorhanden sein.'
            + CHAR(13) + CHAR(10)
            + N'There must be exactly 30 reserved format modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- ========================================================================
    -- Save the unmasked initial state
    -- ======================================================================== 
    DECLARE @OriginalData TABLE
    (
        [X]                 TINYINT NOT NULL,
        [Y]                 TINYINT NOT NULL,
        [IsBlack]           BIT     NOT NULL,

        PRIMARY KEY
        (
            [Y],
            [X]
        )
    );

    INSERT INTO @OriginalData
    (
        [X],
        [Y],
        [IsBlack]
    )
    SELECT
        [X],
        [Y],
        [IsBlack]
    FROM [QR].[Module]
    WHERE [ModuleType] IN ('Data', 'Remainder');

    IF (SELECT COUNT(*) FROM @OriginalData) <> @DataModuleCount
    BEGIN
        SET @ErrorMessage =
              N'Der unmaskierte Datenzustand konnte nicht vollständig gesichert werden.'
            + CHAR(13) + CHAR(10)
            + N'The unmasked data state could not be fully backed up.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;

    -- ========================================================================
    -- Results for the eight candidates
    -- ======================================================================== */
    DECLARE @MaskResults TABLE
    (
        [MaskPattern]           TINYINT NOT NULL PRIMARY KEY,
        [PenaltyRule1]          INTEGER NOT NULL,
        [PenaltyRule2]          INTEGER NOT NULL,
        [PenaltyRule3]          INTEGER NOT NULL,
        [PenaltyRule4]          INTEGER NOT NULL,
        [TotalPenalty]          INTEGER NOT NULL
    );

    DECLARE @MaskPattern        TINYINT = 0;
    DECLARE @P1                 INTEGER;
    DECLARE @P2                 INTEGER;
    DECLARE @P3                 INTEGER;
    DECLARE @P4                 INTEGER;
    DECLARE @Total              INTEGER;

       -- ========================================================================
       -- Test Masks 0 through 7
       -- ========================================================================
    WHILE @MaskPattern <= 7
    BEGIN

        -- --------------------------------------------------------------------
        -- Restore original, unmasked data
        -- --------------------------------------------------------------------
        UPDATE [M]
        SET
            [IsBlack] = O.[IsBlack]
        FROM [QR].[Module]                                  AS [M]
        INNER JOIN @OriginalData                            AS [O]
            ON 1 = 1
                AND [O].[X] = M.[X]
                AND [O].[Y] = M.[Y]
        WHERE
            [M].[ModuleType] IN ('Data', 'Remainder');

        -- --------------------------------------------------------------------
        -- Reset Format Information for This Candidate
        -- --------------------------------------------------------------------
        UPDATE [QR].[Module]
        SET
            [IsBlack] = NULL
        WHERE
            [ModuleType] = 'Format';

        -- --------------------------------------------------------------------
        -- Apply the candidate mask
        -- --------------------------------------------------------------------
        EXEC [QR].[pApplyMask]
            @MaskPattern = @MaskPattern;

        -- --------------------------------------------------------------------
        -- Set the appropriate format information
        -- --------------------------------------------------------------------
        EXEC [QR].[pSetFormatInformation]
            @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
            @MaskPattern            = @MaskPattern,
            @VersionNumber          = @VersionNumber;

        -- --------------------------------------------------------------------
        -- Calculate Penalty
        -- --------------------------------------------------------------------
        SET @P1         = 0;
        SET @P2         = 0;
        SET @P3         = 0;
        SET @P4         = 0;
        SET @Total      = 0;

        EXEC [QR].[pCalculateMaskPenalty]
            @OutPenaltyRule1 = @P1      OUTPUT,
            @OutPenaltyRule2 = @P2      OUTPUT,
            @OutPenaltyRule3 = @P3      OUTPUT,
            @OutPenaltyRule4 = @P4      OUTPUT,
            @OutTotalPenalty = @Total   OUTPUT,
            @ReturnResultSet = 0;

        -- --------------------------------------------------------------------
        -- Save Results
        -- --------------------------------------------------------------------
        INSERT INTO @MaskResults
        (
            [MaskPattern],
            [PenaltyRule1],
            [PenaltyRule2],
            [PenaltyRule3],
            [PenaltyRule4],
            [TotalPenalty]
        )
        VALUES
        (
            @MaskPattern,
            @P1,
            @P2,
            @P3,
            @P4,
            @Total
        );

        SET @MaskPattern = @MaskPattern + 1;

    END;

    -- ========================================================================
    -- Determining the Best Mask
    -- The mask with the lowest penalty score wins.
    -- If the scores are identical, we use the mask with the smaller number,
    -- so that the result remains deterministic.
    -- ========================================================================
    DECLARE @BestMaskPattern    TINYINT;
    DECLARE @BestPenalty        INTEGEr;

    SELECT TOP (1)
        @BestMaskPattern    = [MaskPattern],
        @BestPenalty        = [TotalPenalty]
    FROM @MaskResults
    ORDER BY
        [TotalPenalty],
        [MaskPattern];

    -- ========================================================================
    -- Restore the unmasked state one last time
    -- ========================================================================
    UPDATE [M]
    SET
        [IsBlack] = [O].[IsBlack]
    FROM [QR].[Module]                                      AS [M]
    INNER JOIN @OriginalData                                AS [O]
        ON 1 = 1
            AND [O].[X] = [M].[X]
            AND [O].[Y] = [M].[Y]
    WHERE
        [M].[ModuleType] IN ('Data', 'Remainder');

    UPDATE [QR].[Module]
    SET
        [IsBlack] = NULL
    WHERE
        [ModuleType] = 'Format';

    -- ========================================================================
    -- Apply the Winner Mask
    -- ========================================================================
    EXEC [QR].[pApplyMask]
        @MaskPattern = @BestMaskPattern;

    EXEC [QR].[pSetFormatInformation]
        @ErrorCorrectionLevel   = @ErrorCorrectionLevel,
        @MaskPattern            = @BestMaskPattern,
        @VersionNumber          = @VersionNumber;

    -- ========================================================================
    -- Final Inspection
    --=========================================================================
    IF EXISTS
    (
        SELECT 1
        FROM [QR].[Module]
        WHERE [IsBlack] IS NULL
    )
    BEGIN
        SET @ErrorMessage =
              N'Nach der Maskenauswahl enthaelt die Matrix noch undefinierte Module.'
            + CHAR(13) + CHAR(10)
            + N'After selecting the masks, the matrix still contains undefined modules.';
        RAISERROR (@ErrorMessage, 16, 1)
    END;
END;
