-- ##############################################################################
-- ### Seed Data: [QR].[Seed_VersionRemainderBits]                            ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Seeds QR Code remainder-bit metadata.                                  ###
-- ###                                                                        ###
-- ### The table defines the number of remainder bits that must be appended   ###
-- ### after placement of all data and error correction codewords for each    ###
-- ### QR Code version.                                                       ###
-- ###                                                                        ###
-- ### These values are defined by ISO/IEC 18004 and are used during          ###
-- ### placement validation in [QR].[pPlaceDataBits].                         ###
-- ###                                                                        ###
-- ### Version  1 : 0 remainder bits                                          ###
-- ### Version  2-6 : 7 remainder bits                                        ###
-- ### Version  7-13: 0 remainder bits                                        ###
-- ### Version 14-20: 3 remainder bits                                        ###
-- ### Version 21-27: 4 remainder bits                                        ###
-- ### Version 28-34: 3 remainder bits                                        ###
-- ### Version 35-40: 0 remainder bits                                        ###
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
-- ### - [QR].[pPlaceDataBits]                                                ###
-- ##############################################################################

SET NOCOUNT ON;

MERGE [QR].[VersionRemainderBits] AS [Target]
USING
(
    VALUES
        ( 1, 0),
        ( 2, 7),
        ( 3, 7),
        ( 4, 7),
        ( 5, 7),
        ( 6, 7),
        ( 7, 0),
        ( 8, 0),
        ( 9, 0),
        (10, 0),
        (11, 0),
        (12, 0),
        (13, 0),
        (14, 3),
        (15, 3),
        (16, 3),
        (17, 3),
        (18, 3),
        (19, 3),
        (20, 3),
        (21, 4),
        (22, 4),
        (23, 4),
        (24, 4),
        (25, 4),
        (26, 4),
        (27, 4),
        (28, 3),
        (29, 3),
        (30, 3),
        (31, 3),
        (32, 3),
        (33, 3),
        (34, 3),
        (35, 0),
        (36, 0),
        (37, 0),
        (38, 0),
        (39, 0),
        (40, 0)
)
AS [Source]
(
    [VersionNumber],
    [RemainderBits]
)
ON [Target].[VersionNumber] = [Source].[VersionNumber]

WHEN MATCHED
AND [Target].[RemainderBits] <> [Source].[RemainderBits]
THEN
    UPDATE
       SET [RemainderBits] = [Source].[RemainderBits]

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
        [VersionNumber],
        [RemainderBits]
    )
    VALUES
    (
        [Source].[VersionNumber],
        [Source].[RemainderBits]
    );

GO