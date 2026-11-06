CREATE TABLE [QR].[EccBlock] (
    [BlockNumber] INT NOT NULL,
    [Position]    INT NOT NULL,
    [Value]       INT NOT NULL,
    PRIMARY KEY CLUSTERED ([BlockNumber] ASC, [Position] ASC)
);

