-- ##############################################################################
-- ### Seed Data: [QR].[Seed_VersionDefinition]                               ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Seeds QR Code version metadata.                                        ###
-- ###                                                                        ###
-- ### The table contains the matrix dimensions for all QR Code versions      ###
-- ### defined by ISO/IEC 18004.                                              ###
-- ###                                                                        ###
-- ### Matrix size is calculated as:                                          ###
-- ###                                                                        ###
-- ###     MatrixSize = 17 + (4 * VersionNumber)                              ###
-- ###                                                                        ###
-- ### These values are static reference data and form the foundation for     ###
-- ### matrix construction, format information placement, version             ###
-- ### information placement and capacity calculations.                       ###
-- ### ---------------------------------------------------------------------- ###
-- ### Deployment Type:              Seed Data                                ###
-- ### ---------------------------------------------------------------------- ###
-- ### Execution:                                                             ###
-- ### Included from [PostDeployment.sql]                                     ###
-- ### ---------------------------------------------------------------------- ###
-- ### Notes:                                                                 ###
-- ###                                                                        ###
-- ### Script is idempotent.                                                  ###
-- ### Existing records are updated if values differ.                         ###
-- ### Missing records are inserted.                                          ###
-- ### ---------------------------------------------------------------------- ###
-- ### Dependencies:                                                          ###
-- ###                                                                        ###
-- ### Referenced by:                                                         ###
-- ### - [QR].[fnGetMatrixSize]                                               ###
-- ### - QR matrix initialization and construction procedures                 ###
-- ##############################################################################

SET NOCOUNT ON;

MERGE [QR].[VersionDefinition] AS [Target]
USING
(
    VALUES
        ( 1,  21),
        ( 2,  25),
        ( 3,  29),
        ( 4,  33),
        ( 5,  37),
        ( 6,  41),
        ( 7,  45),
        ( 8,  49),
        ( 9,  53),
        (10,  57),
        (11,  61),
        (12,  65),
        (13,  69),
        (14,  73),
        (15,  77),
        (16,  81),
        (17,  85),
        (18,  89),
        (19,  93),
        (20,  97),
        (21, 101),
        (22, 105),
        (23, 109),
        (24, 113),
        (25, 117),
        (26, 121),
        (27, 125),
        (28, 129),
        (29, 133),
        (30, 137),
        (31, 141),
        (32, 145),
        (33, 149),
        (34, 153),
        (35, 157),
        (36, 161),
        (37, 165),
        (38, 169),
        (39, 173),
        (40, 177)
)
AS [Source]
(
    [VersionNumber],
    [MatrixSize]
)
ON [Target].[VersionNumber] = [Source].[VersionNumber]

WHEN MATCHED
AND [Target].[MatrixSize] <> [Source].[MatrixSize]
THEN
    UPDATE
       SET [MatrixSize] = [Source].[MatrixSize]

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
        [VersionNumber],
        [MatrixSize]
    )
    VALUES
    (
        [Source].[VersionNumber],
        [Source].[MatrixSize]
    );
GO