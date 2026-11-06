CREATE TABLE [QR].[RegressionGoldenMatrix] (
    [TestName] VARCHAR (100) NOT NULL,
    [X]        INT           NOT NULL,
    [Y]        INT           NOT NULL,
    [IsBlack]  BIT           NOT NULL,
    CONSTRAINT [PK_RegressionGoldenMatrix] PRIMARY KEY CLUSTERED ([TestName] ASC, [Y] ASC, [X] ASC)
);

