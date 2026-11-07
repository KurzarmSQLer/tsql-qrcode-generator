CREATE TABLE [QR].[VersionCapacity] (
    [VersionNumber]        TINYINT  NOT NULL,
    [ErrorCorrectionLevel] CHAR (1) NOT NULL,
    [DataCodewords]        SMALLINT NOT NULL,
    [EccCodewords]         SMALLINT NOT NULL,
    CONSTRAINT [PK_QR_VersionCapacity] PRIMARY KEY CLUSTERED ([VersionNumber] ASC, [ErrorCorrectionLevel] ASC)
);

