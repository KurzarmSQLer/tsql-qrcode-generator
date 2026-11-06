
-- ##############################################################################
-- ### Procedure: [QR].[pCalculateMaskPenalty]                                ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Calculates QR mask penalty scores according to the QR specification.   ###
-- ###                                                                        ###
-- ### All four QR penalty rules are evaluated and combined into a total      ###
-- ### penalty score. Lower scores indicate higher visual quality and         ###
-- ### improved scanability.                                                  ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:               Internal                                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @ReturnResultSet:        Controls whether the calculated penalty       ###
-- ###                          values are additionally returned as a result  ###
-- ###                          set.                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### @OutPenaltyRule1:        Penalty score for rule 1 (runs of identical   ###
-- ###                          modules)                                      ###
-- ### @OutPenaltyRule2:        Penalty score for rule 2 (2x2 module blocks)  ###
-- ### @OutPenaltyRule3:        Penalty score for rule 3 (finder-like         ###
-- ###                          patterns)                                     ###
-- ### @OutPenaltyRule4:        Penalty score for rule 4 (black/white module  ###
-- ###                          ratio)                                        ###
-- ### @OutTotalPenalty:        Sum of all penalty rules                      ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCalculateMaskPenalty]
    @OutPenaltyRule1 INT OUTPUT,
    @OutPenaltyRule2 INT OUTPUT,
    @OutPenaltyRule3 INT OUTPUT,
    @OutPenaltyRule4 INT OUTPUT,
    @OutTotalPenalty INT OUTPUT,
    @ReturnResultSet BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    /* ========================================================================
       QR Mask Penalty Score
       The four rules are calculated separately:
           Rule 1: Long sequences of the same color
           Rule 2: 2x2 blocks of the same color
           Rule 3: “Finder”-like patterns
           Rule 4: Deviation from the 50 percent black ratio
       Finally, all four results are added together.
       ======================================================================== */
    DECLARE @PenaltyRule1   INTEGER = 0;
    DECLARE @PenaltyRule2   INTEGER = 0;
    DECLARE @PenaltyRule3   INTEGER = 0;
    DECLARE @PenaltyRule4   INTEGER = 0;
    DECLARE @MatrixSize     INTEGER;

    SELECT
        @MatrixSize = MAX(X) + 1
    FROM QR.Module;
    /* ========================================================================
       Rule 1
       Long horizontal and vertical sequences of the same color

       For a sequence of at least 5 modules:
           5 modules  -> 3 points
           6 modules  -> 4 points
           7 modules  -> 5 points
       In general:
           3 + RunLength - 5
       ======================================================================== */

    DECLARE @RunLength      INTEGER;
    DECLARE @PreviousColor  BIT;
    DECLARE @CurrentColor   BIT;
    DECLARE @X              INTEGER;
    DECLARE @Y              INTEGER;

    ------------------------------------------------------------------------
    -- Horizontal Chain
    ------------------------------------------------------------------------
    SET @Y = 0;

    WHILE @Y <= @MatrixSize - 1
    BEGIN
        SET @X              = 0;
        SET @RunLength      = 0;
        SET @PreviousColor  = NULL;

        WHILE @X <= @MatrixSize - 1
        BEGIN
            SELECT
                @CurrentColor = [IsBlack]
            FROM [QR].[Module]
            WHERE [X] = @X AND [Y] = @Y;

            IF @CurrentColor IS NULL
            BEGIN
                DECLARE @ErrorMessage NVARCHAR(MAX)
                SET @ErrorMessage =
                      N'DE: Die Matrix enthaelt noch Module ohne Farbwert.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: The matrix still contains modules without color values.'
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @PreviousColor IS NULL
            BEGIN
                SET @PreviousColor  = @CurrentColor;
                SET @RunLength      = 1;
            END
            ELSE IF @CurrentColor = @PreviousColor
            BEGIN
                SET @RunLength = @RunLength + 1;
            END
            ELSE
            BEGIN
                IF @RunLength >= 5
                BEGIN
                    SET @PenaltyRule1 =
                        @PenaltyRule1
                        + 3
                        + (@RunLength - 5);
                END;
                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END;
            SET @X = @X + 1;
        END;

        -- Evaluate the last row
        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;

        SET @Y = @Y + 1;
    END;

    ------------------------------------------------------------------------
    -- Vertical Chain
    ------------------------------------------------------------------------
    SET @X = 0;

    WHILE @X <= @MatrixSize - 1
    BEGIN
        SET @Y              = 0;
        SET @RunLength      = 0;
        SET @PreviousColor  = NULL;

        WHILE @Y <= @MatrixSize - 1
        BEGIN
            SELECT
                @CurrentColor = [IsBlack]
            FROM [QR].[Module]
            WHERE [X] = @X AND [Y] = @Y;

            IF @CurrentColor IS NULL
            BEGIN
                SET @ErrorMessage =
                      N'DE: Die Matrix enthaelt noch Module ohne Farbwert.'
                    + CHAR(13) + CHAR(10)
                    + N'EN: The matrix still contains modules without color values.'
                RAISERROR (@ErrorMessage, 16, 1)
            END;

            IF @PreviousColor IS NULL
            BEGIN
                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END
            ELSE IF @CurrentColor = @PreviousColor
            BEGIN
                SET @RunLength = @RunLength + 1;
            END
            ELSE
            BEGIN
                IF @RunLength >= 5
                BEGIN
                    SET @PenaltyRule1 =
                        @PenaltyRule1
                        + 3
                        + (@RunLength - 5);
                END;

                SET @PreviousColor = @CurrentColor;
                SET @RunLength = 1;
            END;

            SET @Y = @Y + 1;
        END;

        IF @RunLength >= 5
        BEGIN
            SET @PenaltyRule1 =
                @PenaltyRule1
                + 3
                + (@RunLength - 5);
        END;
        SET @X = @X + 1;
    END;

    -- ========================================================================
    -- Rule 2       2x2 blocks of the same color
    -- Each 2x2 block consisting of four black or four white modules:
    --  +3 points
    -- The blocks may and should overlap.
    -- ========================================================================
    SELECT
        @PenaltyRule2 =
            COUNT(*) * 3
    FROM [QR].[Module]                                          AS [M00]

    INNER JOIN [QR].[Module]                                    AS [M10]
        ON [M10].[X] = [M00].[X] + 1
        AND [M10].[Y] = [M00].[Y]

    INNER JOIN [QR].[Module]                                    AS [M01]
        ON [M01].[X] = [M00].[X]
        AND [M01].[Y] = [M00].[Y] + 1

    INNER JOIN [QR].[Module]                                    AS [M11]
        ON [M11].[X] = [M00].[X] + 1
        AND [M11].[Y] = [M00].[Y] + 1

    WHERE 1 = 1
        AND [M00].[X] BETWEEN 0 AND @MatrixSize - 2
        AND [M00].[Y] BETWEEN 0 AND @MatrixSize - 2
        AND [M00].[IsBlack] = [M10].[IsBlack]
        AND [M00].[IsBlack] = [M01].[IsBlack]
        AND [M00].[IsBlack] = [M11].[IsBlack];

    -- ------------------------------------------------------------------------
    -- Penalty Rule 3: Finder-like Patterns
    -- This is the most important rule and also the one with the highest weighting.
    -- The pattern sought is the ratio 1 : 1 : 3 : 1 : 1, i.e., the bit pattern 
    -- 1011101 with four light modules before or after it, such as 10111010000 
    -- or 00001011101 (horizontal or vertical).
    -- ------------------------------------------------------------------------

    DECLARE @PatternA CHAR(11) = '10111010000';
    DECLARE @PatternB CHAR(11) = '00001011101';
    DECLARE @Sequence CHAR(11);

    -- ------------------------------------------------------------------------
    -- Horizontal
    -- ------------------------------------------------------------------------ */
    SET @Y = 0;

    WHILE @Y <= @MatrixSize - 1
    BEGIN

        SET @X = 0;

        WHILE @X <= @MatrixSize - 11
        BEGIN

            SELECT
                @Sequence =
                    STRING_AGG
                    (
                        CONVERT
                        (
                            VARCHAR(MAX),
                            CONVERT(INT, [IsBlack])
                        ),
                        ''
                    )
                    WITHIN GROUP
                    (
                        ORDER BY [X]
                    )
            FROM [QR].[Module]
            WHERE 1 = 1
                AND [Y] = @Y
                AND [X] BETWEEN @X AND @X + 10;

            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 = @PenaltyRule3 + 40;
            END;

            SET @X = @X + 1;
        END;

        SET @Y = @Y + 1;
    END;

    -- ------------------------------------------------------------------------
    -- Vertical
    -- ------------------------------------------------------------------------
    SET @X = 0;

    WHILE @X <= @MatrixSize - 1
    BEGIN

        SET @Y = 0;

        WHILE @Y <= @MatrixSize - 11
        BEGIN
            SELECT
                @Sequence =
                    STRING_AGG
                    (
                        CONVERT
                        (
                            VARCHAR(MAX),
                            CONVERT(INT, [IsBlack])
                        ),
                        ''
                    )
                    WITHIN GROUP
                    (
                        ORDER BY [Y]
                    )
            FROM [QR].[Module]
            WHERE 1 = 1
                AND [X] = @X
                AND [Y] BETWEEN @Y AND @Y + 10;

            IF @Sequence = @PatternA
                OR @Sequence = @PatternB
            BEGIN
                SET @PenaltyRule3 = @PenaltyRule3 + 40;
            END;

            SET @Y = @Y + 1;
        END;

        SET @X = @X + 1;
    END;

    -- ----------------------------------------------------------------------------- 
    -- Penalty Rule 4: Black-to-White Ratio: Ideally, the percentage of black modules 
    -- should be close to 50 percent. The further it deviates from this, the higher 
    -- the penalty score. Rule 4 operates in 5-percent increments and assigns 10 
    -- points per increment.
    -- ----------------------------------------------------------------------------- 
    DECLARE @TotalModules       INTEGER;
    DECLARE @BlackModules       INTEGER;
    DECLARE @BlackPercent       DECIMAL(10,4);
    DECLARE @DeviationFrom50    DECIMAL(10,4);
    DECLARE @FivePercentSteps   INTEGEr;

    SELECT
        @TotalModules = COUNT(*),
        @BlackModules =
            SUM
            (
                CASE
                    WHEN [IsBlack] = 1 THEN 1
                    ELSE 0
                END
            )
    FROM [QR].[Module];

    SET @BlackPercent       = 100.0 * CONVERT(DECIMAL(10,4), @BlackModules) / CONVERT(DECIMAL(10,4), @TotalModules);
    SET @DeviationFrom50    = ABS(@BlackPercent - 50.0);
    SET @FivePercentSteps   = FLOOR(@DeviationFrom50 / 5.0);
    SET @PenaltyRule4       = @FivePercentSteps * 10;

    -- Now let's add the four partial results
    DECLARE @TotalPenalty   INTEGER;
    SET @TotalPenalty = @PenaltyRule1 + @PenaltyRule2 + @PenaltyRule3 + @PenaltyRule4;

    -- ------------------------------------------------------------------------
    -- Return results to the caller
    -- ------------------------------------------------------------------------
    SET @OutPenaltyRule1 = @PenaltyRule1;
    SET @OutPenaltyRule2 = @PenaltyRule2;
    SET @OutPenaltyRule3 = @PenaltyRule3;
    SET @OutPenaltyRule4 = @PenaltyRule4;
    SET @OutTotalPenalty = @TotalPenalty;

    -- ------------------------------------------------------------------------
    -- Optional Output Control
    -- When calling the function manually, we still want to be able to see the 
    -- previous result set. 
    -- pSelectBestMask, on the other hand, sets @ReturnResultSet to 0.
    -- ------------------------------------------------------------------------
    IF @ReturnResultSet = 1
    BEGIN

        SELECT
            @PenaltyRule1 AS [PenaltyRule1],
            @PenaltyRule2 AS [PenaltyRule2],
            @PenaltyRule3 AS [PenaltyRule3],
            @PenaltyRule4 AS [PenaltyRule4],

            @TotalPenalty AS [TotalPenalty],

            @BlackModules AS [BlackModules],
            @TotalModules AS [TotalModules],
            @BlackPercent AS [BlackPercent];
    END;
END;
