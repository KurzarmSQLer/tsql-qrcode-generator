CREATE TABLE [QR].[AlignmentPatternPosition] (
    [VersionNumber] TINYINT  NOT NULL,
    [X]             SMALLINT NOT NULL,
    [Y]             SMALLINT NOT NULL,
    CONSTRAINT [PK_QR_AlignmentPatternPosition] PRIMARY KEY CLUSTERED ([VersionNumber] ASC, [X] ASC, [Y] ASC)
);

