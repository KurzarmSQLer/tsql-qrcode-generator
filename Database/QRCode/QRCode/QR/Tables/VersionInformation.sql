CREATE TABLE [QR].[VersionInformation] (
    [VersionNumber] TINYINT   NOT NULL,
    [VersionBits]   CHAR (18) NOT NULL,
    CONSTRAINT [PK_QR_VersionInformation] PRIMARY KEY CLUSTERED ([VersionNumber] ASC)
);

