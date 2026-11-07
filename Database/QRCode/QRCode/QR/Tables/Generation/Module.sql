CREATE TABLE [QR].[Module] (
    [X]          TINYINT      NOT NULL,
    [Y]          TINYINT      NOT NULL,
    [IsBlack]    BIT          NULL,
    [ModuleType] VARCHAR (20) NULL,
    [ColorHex]   CHAR (7)     NULL,
    CONSTRAINT [PK_QR_Module] PRIMARY KEY CLUSTERED ([Y] ASC, [X] ASC)
);

