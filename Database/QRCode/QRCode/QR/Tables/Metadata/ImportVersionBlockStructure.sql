CREATE TABLE [QR].[ImportVersionBlockStructure]
(
      [VersionNumber]            TINYINT
    , [ErrorCorrectionLevel]     CHAR(1)

    , [EccCodewordsPerBlock]     SMALLINT

    , [Group1BlockCount]         SMALLINT
    , [Group1DataCodewords]      SMALLINT

    , [Group2BlockCount]         SMALLINT NULL
    , [Group2DataCodewords]      SMALLINT NULL
);