CREATE TABLE [QR].[GeneratorPolynomial] (
    [EccCodewords] INT NOT NULL,
    [Position]     INT NOT NULL,
    [Coefficient]  INT NOT NULL,
    CONSTRAINT [PK_QR_GeneratorPolynomial] PRIMARY KEY CLUSTERED ([EccCodewords] ASC, [Position] ASC)
);

