CREATE TABLE [QR].[LogoArea] (
    [AreaName] VARCHAR (50) NOT NULL,
    [StartX]   TINYINT      NOT NULL,
    [StartY]   TINYINT      NOT NULL,
    [EndX]     TINYINT      NOT NULL,
    [EndY]     TINYINT      NOT NULL,
    [Width]    SMALLINT     NOT NULL,
    [Height]   SMALLINT     NOT NULL,
    [Area]     INT          NOT NULL,
    CONSTRAINT [PK_QR_LogoArea] PRIMARY KEY CLUSTERED ([AreaName] ASC)
);

