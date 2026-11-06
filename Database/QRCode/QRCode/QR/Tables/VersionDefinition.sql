CREATE TABLE [QR].[VersionDefinition] (
    [VersionNumber] TINYINT  NOT NULL,
    [MatrixSize]    SMALLINT NOT NULL,
    CONSTRAINT [PK_QR_VersionDefinition] PRIMARY KEY CLUSTERED ([VersionNumber] ASC)
);

