-- ##############################################################################
-- ### Seed Data: [QR].[ErrorCorrectionLevel]                                 ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Seeds QR Code error correction level metadata.                         ###
-- ###                                                                        ###
-- ### The table contains the Version 1 QR Code codeword distribution         ###
-- ### between data codewords and error correction codewords for each         ###
-- ### supported error correction level.                                      ###
-- ###                                                                        ###
-- ### Level L : 19 data codewords,  7 ECC codewords                          ###
-- ### Level M : 16 data codewords, 10 ECC codewords                          ###
-- ### Level Q : 13 data codewords, 13 ECC codewords                          ###
-- ### Level H :  9 data codewords, 17 ECC codewords                          ###
-- ###                                                                        ###
-- ### Values originate from the QR Code specification and are treated as     ###
-- ### static reference data.                                                 ###
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
-- ##############################################################################

SET NOCOUNT ON;

MERGE [QR].[ErrorCorrectionLevel] AS [Target]
USING
(
    VALUES
        ('L', 19,  7),
        ('M', 16, 10),
        ('Q', 13, 13),
        ('H',  9, 17)
)
AS [Source]
(
    [LevelCode],
    [DataCodewords],
    [EccCodewords]
)
ON [Target].[LevelCode] = [Source].[LevelCode]

WHEN MATCHED
AND
(
       [Target].[DataCodewords] <> [Source].[DataCodewords]
    OR [Target].[EccCodewords]  <> [Source].[EccCodewords]
)
THEN
    UPDATE
       SET [DataCodewords] = [Source].[DataCodewords],
           [EccCodewords]  = [Source].[EccCodewords]

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
        [LevelCode],
        [DataCodewords],
        [EccCodewords]
    )
    VALUES
    (
        [Source].[LevelCode],
        [Source].[DataCodewords],
        [Source].[EccCodewords]
    );

GO