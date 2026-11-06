CREATE TABLE [QR].[Configuration] (
    [ConfigurationKey]   VARCHAR (100)  NOT NULL,
    [ConfigurationValue] VARCHAR (100)  NOT NULL,
    CONSTRAINT [PK_QR_Configuration] PRIMARY KEY CLUSTERED ([ConfigurationKey] ASC)
);

