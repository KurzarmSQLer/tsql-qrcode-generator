CREATE TABLE [QR].[VersionBlockStructure] (
    [VersionNumber]         TINYINT  NOT NULL,
    [ErrorCorrectionLevel]  CHAR (1) NOT NULL,
    [GroupNumber]           TINYINT  NOT NULL,
    [BlockCount]            SMALLINT NOT NULL,
    [DataCodewordsPerBlock] SMALLINT NOT NULL,
    CONSTRAINT [PK_QR_VersionBlockStructure] PRIMARY KEY CLUSTERED ([VersionNumber] ASC, [ErrorCorrectionLevel] ASC, [GroupNumber] ASC)
);

