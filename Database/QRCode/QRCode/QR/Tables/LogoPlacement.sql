CREATE TABLE [QR].[LogoPlacement] (
    [LogoName]   VARCHAR (50) NOT NULL,
    [TargetX]    TINYINT      NOT NULL,
    [TargetY]    TINYINT      NOT NULL,
    [SourceX]    SMALLINT     NOT NULL,
    [SourceY]    SMALLINT     NOT NULL,
    [ColorClass] TINYINT      NOT NULL,
    CONSTRAINT [PK_QR_LogoPlacement] PRIMARY KEY CLUSTERED ([LogoName] ASC, [TargetY] ASC, [TargetX] ASC)
);

