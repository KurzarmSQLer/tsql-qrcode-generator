CREATE TABLE [QR].[LogoPattern] (
    [LogoName]   VARCHAR (50) NOT NULL,
    [X]          SMALLINT     NOT NULL,
    [Y]          SMALLINT     NOT NULL,
    [ColorClass] TINYINT      NOT NULL,
    CONSTRAINT [PK_QR_LogoPattern] PRIMARY KEY CLUSTERED ([LogoName] ASC, [Y] ASC, [X] ASC)
);

