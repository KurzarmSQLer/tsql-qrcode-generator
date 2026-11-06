
-- ##############################################################################
-- ### View: [QR].[vLogoCandidates]                                           ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Identifies candidate regions that may be suitable for logo placement   ###
-- ### inside the QR matrix. Used during automatic logo area detection.       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Derived from:                [QR].[Module]                             ###
-- ##############################################################################
CREATE   VIEW [QR].[vLogoCandidates]
AS
SELECT
      [X]
    , [Y]
    , CASE
          WHEN [ModuleType] IS NULL THEN 1
          ELSE 0
      END AS [IsFree]
FROM [QR].[Module];
