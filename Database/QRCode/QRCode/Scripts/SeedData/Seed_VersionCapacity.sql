-- ##############################################################################
-- ### Seed Data: [QR].[VersionCapacity]                                      ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Seeds QR capacity metadata.                                            ###
-- ###                                                                        ###
-- ### DataCodewords are derived from VersionBlockStructure.                  ###
-- ### EccCodewords represent ECC codewords per block according to the        ###
-- ### Nayuki / ISO-18004 reference implementation.                           ###
-- ### ---------------------------------------------------------------------- ###
-- ### Deployment Type: Seed Data                                             ###
-- ##############################################################################

SET NOCOUNT ON;

DECLARE @Source TABLE
(
      [VersionNumber]        TINYINT
    , [ErrorCorrectionLevel] CHAR(1)
    , [DataCodewords]        SMALLINT
    , [EccCodewords]         SMALLINT
);

WITH [BlockCapacity] AS
(
    SELECT
            [VersionNumber]
        , [ErrorCorrectionLevel]
        , SUM
            (
                [BlockCount]
                * [DataCodewordsPerBlock]
            ) AS [DataCodewords]
    FROM [QR].[VersionBlockStructure]
    GROUP BY
            [VersionNumber]
        , [ErrorCorrectionLevel]
)


MERGE [QR].[VersionCapacity] AS [Target]
USING
(
    SELECT
          [BC].[VersionNumber]
        , [BC].[ErrorCorrectionLevel]
        , [BC].[DataCodewords]
        , [ECC].[EccCodewords]
    FROM [BlockCapacity] AS [BC]
    INNER JOIN
    (
        VALUES

        -- L
        ( 1,'L', 7),( 2,'L',10),( 3,'L',15),( 4,'L',20),( 5,'L',26),
        ( 6,'L',18),( 7,'L',20),( 8,'L',24),( 9,'L',30),(10,'L',18),
        (11,'L',20),(12,'L',24),(13,'L',26),(14,'L',30),(15,'L',22),
        (16,'L',24),(17,'L',28),(18,'L',30),(19,'L',28),(20,'L',28),
        (21,'L',28),(22,'L',28),(23,'L',30),(24,'L',30),(25,'L',26),
        (26,'L',28),(27,'L',30),(28,'L',30),(29,'L',30),(30,'L',30),
        (31,'L',30),(32,'L',30),(33,'L',30),(34,'L',30),(35,'L',30),
        (36,'L',30),(37,'L',30),(38,'L',30),(39,'L',30),(40,'L',30),

        -- M
        ( 1,'M',10),( 2,'M',16),( 3,'M',26),( 4,'M',18),( 5,'M',24),
        ( 6,'M',16),( 7,'M',18),( 8,'M',22),( 9,'M',22),(10,'M',26),
        (11,'M',30),(12,'M',22),(13,'M',22),(14,'M',24),(15,'M',24),
        (16,'M',28),(17,'M',28),(18,'M',26),(19,'M',26),(20,'M',26),
        (21,'M',26),(22,'M',28),(23,'M',28),(24,'M',28),(25,'M',28),
        (26,'M',28),(27,'M',28),(28,'M',28),(29,'M',28),(30,'M',28),
        (31,'M',28),(32,'M',28),(33,'M',28),(34,'M',28),(35,'M',28),
        (36,'M',28),(37,'M',28),(38,'M',28),(39,'M',28),(40,'M',28),

        -- Q
        ( 1,'Q',13),( 2,'Q',22),( 3,'Q',18),( 4,'Q',26),( 5,'Q',18),
        ( 6,'Q',24),( 7,'Q',18),( 8,'Q',22),( 9,'Q',20),(10,'Q',24),
        (11,'Q',28),(12,'Q',26),(13,'Q',24),(14,'Q',20),(15,'Q',30),
        (16,'Q',24),(17,'Q',28),(18,'Q',28),(19,'Q',26),(20,'Q',30),
        (21,'Q',28),(22,'Q',30),(23,'Q',30),(24,'Q',30),(25,'Q',30),
        (26,'Q',28),(27,'Q',30),(28,'Q',30),(29,'Q',30),(30,'Q',30),
        (31,'Q',30),(32,'Q',30),(33,'Q',30),(34,'Q',30),(35,'Q',30),
        (36,'Q',30),(37,'Q',30),(38,'Q',30),(39,'Q',30),(40,'Q',30),

        -- H
        ( 1,'H',17),( 2,'H',28),( 3,'H',22),( 4,'H',16),( 5,'H',22),
        ( 6,'H',28),( 7,'H',26),( 8,'H',26),( 9,'H',24),(10,'H',28),
        (11,'H',24),(12,'H',28),(13,'H',22),(14,'H',24),(15,'H',24),
        (16,'H',30),(17,'H',28),(18,'H',28),(19,'H',26),(20,'H',28),
        (21,'H',30),(22,'H',24),(23,'H',30),(24,'H',30),(25,'H',30),
        (26,'H',30),(27,'H',30),(28,'H',30),(29,'H',30),(30,'H',30),
        (31,'H',30),(32,'H',30),(33,'H',30),(34,'H',30),(35,'H',30),
        (36,'H',30),(37,'H',30),(38,'H',30),(39,'H',30),(40,'H',30)

    ) AS [ECC]
    (
          [VersionNumber]
        , [ErrorCorrectionLevel]
        , [EccCodewords]
    )
        ON  [ECC].[VersionNumber]        = [BC].[VersionNumber]
        AND [ECC].[ErrorCorrectionLevel] = [BC].[ErrorCorrectionLevel]

) AS [Source]
(
      [VersionNumber]
    , [ErrorCorrectionLevel]
    , [DataCodewords]
    , [EccCodewords]
)
ON      [Target].[VersionNumber]        = [Source].[VersionNumber]
    AND [Target].[ErrorCorrectionLevel] = [Source].[ErrorCorrectionLevel]

WHEN MATCHED
AND
(
       [Target].[DataCodewords] <> [Source].[DataCodewords]
    OR [Target].[EccCodewords]  <> [Source].[EccCodewords]
)
THEN
    UPDATE
       SET [DataCodewords] = [Source].[DataCodewords]
         , [EccCodewords]  = [Source].[EccCodewords]

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
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;

GO