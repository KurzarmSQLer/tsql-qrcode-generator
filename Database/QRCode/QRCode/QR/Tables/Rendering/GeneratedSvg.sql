CREATE TABLE [QR].[GeneratedSvg] (
    [SvgID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedAt]            DATETIME2 (0)  NOT NULL,
    [VersionNumber]        TINYINT        NULL,
    [SvgContent]           NVARCHAR (MAX) NOT NULL,
    [TextEncoded]          VARCHAR (255)  NULL,
    [LogoName]             VARCHAR (50)   NULL,
    [ErrorCorrectionLevel] CHAR (1)       NULL,
    [SvgLength]            INT            NULL,
    [SvgHash]              VARBINARY (32) NULL,
    [TextLength]           INT            NULL,
    [InputHash]            VARBINARY (32) NULL,
    CONSTRAINT [PK_QR_GeneratedSvg] PRIMARY KEY CLUSTERED ([SvgID] ASC)
);

