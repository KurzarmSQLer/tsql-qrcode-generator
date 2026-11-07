CREATE TABLE [QR].[ErrorCorrectionLevel] (
    [LevelCode]     CHAR (1) NOT NULL,
    [DataCodewords] TINYINT  NOT NULL,
    [EccCodewords]  TINYINT  NOT NULL,
    PRIMARY KEY CLUSTERED ([LevelCode] ASC)
);

