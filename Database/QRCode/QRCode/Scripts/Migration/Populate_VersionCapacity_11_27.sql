-- ##############################################################################
-- ### Script: Populate Version Capacity (Versions 11-27)                     ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Extends [QR].[VersionCapacity] with official QR Code capacity data     ###
-- ### for versions 11 through 27.                                            ###
-- ###                                                                        ###
-- ### Data originates from ISO/IEC 18004 QR Code capacity tables.            ###
-- ###                                                                        ###
-- ### Existing records remain unchanged.                                     ###
-- ##############################################################################

DECLARE @Source TABLE
(
      [VersionNumber]        TINYINT
    , [ErrorCorrectionLevel] CHAR(1)
    , [DataCodewords]        SMALLINT
    , [EccCodewords]         SMALLINT
);

INSERT INTO @Source
VALUES

    (11,'L', 324,  80),
    (11,'M', 254, 150),
    (11,'Q', 180, 224),
    (11,'H', 140, 264),

    (12,'L', 370,  96),
    (12,'M', 290, 176),
    (12,'Q', 206, 260),
    (12,'H', 158, 308),

    (13,'L', 428, 104),
    (13,'M', 334, 198),
    (13,'Q', 244, 288),
    (13,'H', 180, 352),

    (14,'L', 461, 120),
    (14,'M', 365, 216),
    (14,'Q', 261, 320),
    (14,'H', 197, 384),

    (15,'L', 523, 132),
    (15,'M', 415, 240),
    (15,'Q', 295, 360),
    (15,'H', 223, 432),

    (16,'L', 589, 144),
    (16,'M', 453, 280),
    (16,'Q', 325, 408),
    (16,'H', 253, 480),

    (17,'L', 647, 168),
    (17,'M', 507, 308),
    (17,'Q', 367, 448),
    (17,'H', 283, 532),

    (18,'L', 721, 180),
    (18,'M', 563, 338),
    (18,'Q', 397, 504),
    (18,'H', 313, 588),

    (19,'L', 795, 196),
    (19,'M', 627, 364),
    (19,'Q', 445, 546),
    (19,'H', 341, 650),

    (20,'L', 861, 224),
    (20,'M', 669, 416),
    (20,'Q', 485, 600),
    (20,'H', 385, 700),

    (21,'L', 932, 224),
    (21,'M', 714, 442),
    (21,'Q', 512, 644),
    (21,'H', 406, 750),

    (22,'L',1006, 252),
    (22,'M', 782, 476),
    (22,'Q', 568, 690),
    (22,'H', 442, 816),

    (23,'L',1094, 270),
    (23,'M', 860, 504),
    (23,'Q', 614, 750),
    (23,'H', 464, 900),

    (24,'L',1174, 300),
    (24,'M', 914, 560),
    (24,'Q', 664, 810),
    (24,'H', 514, 960),

    (25,'L',1276, 312),
    (25,'M',1000, 588),
    (25,'Q', 718, 870),
    (25,'H', 538,1050),

    (26,'L',1370, 336),
    (26,'M',1062, 644),
    (26,'Q', 754, 952),
    (26,'H', 596,1110),

    (27,'L',1468, 360),
    (27,'M',1128, 700),
    (27,'Q', 808,1020),
    (27,'H', 628,1200);

MERGE [QR].[VersionCapacity] AS [Target]
USING @Source AS [Source]
ON      [Target].[VersionNumber]        = [Source].[VersionNumber]
    AND [Target].[ErrorCorrectionLevel] = [Source].[ErrorCorrectionLevel]

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
          [VersionNumber]
        , [ErrorCorrectionLevel]
        , [DataCodewords]
        , [EccCodewords]
    )
    VALUES
    (
          [Source].[VersionNumber]
        , [Source].[ErrorCorrectionLevel]
        , [Source].[DataCodewords]
        , [Source].[EccCodewords]
    );