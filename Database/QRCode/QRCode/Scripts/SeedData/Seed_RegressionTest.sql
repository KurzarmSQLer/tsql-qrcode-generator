-- ##############################################################################
-- ### Seed Data: [QR].[RegressionTest]                                       ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Seeds the QR regression test catalogue.                                ###
-- ###                                                                        ###
-- ### Test set covers representative QR versions and all ECC levels.         ###
-- ###                                                                        ###
-- ### Versions covered:                                                      ###
-- ###   - 1   (smallest QR)                                                  ###
-- ###   - 7   (first version including version information)                  ###
-- ###   - 10  (last historically validated version)                          ###
-- ###   - 20  (newly enabled medium-sized QR)                                ###
-- ###   - 40  (largest supported QR version)                                 ###
-- ##############################################################################

DECLARE @Source TABLE
(
      [TestName]             VARCHAR(100)
    , [InputText]            VARCHAR(MAX)
    , [VersionNumber]        TINYINT
    , [ErrorCorrectionLevel] CHAR(1)
);

INSERT INTO @Source
(
      [TestName]
    , [InputText]
    , [VersionNumber]
    , [ErrorCorrectionLevel]
)
VALUES

-- Version 1

('V01_L_HELLO', 'HELLO WORLD',  1, 'L'),
('V01_M_HELLO', 'HELLO WORLD',  1, 'M'),
('V01_Q_HELLO', 'HELLO WORLD',  1, 'Q'),
('V01_H_HELLO', 'HELLO WORLD',  1, 'H'),

-- Version 7

('V07_L_HELLO', 'HELLO WORLD',  7, 'L'),
('V07_M_HELLO', 'HELLO WORLD',  7, 'M'),
('V07_Q_HELLO', 'HELLO WORLD',  7, 'Q'),
('V07_H_HELLO', 'HELLO WORLD',  7, 'H'),

-- Version 10

('V10_L_HELLO', 'HELLO WORLD', 10, 'L'),
('V10_M_HELLO', 'HELLO WORLD', 10, 'M'),
('V10_Q_HELLO', 'HELLO WORLD', 10, 'Q'),
('V10_H_HELLO', 'HELLO WORLD', 10, 'H'),

-- Version 20

('V20_L_HELLO', 'HELLO WORLD', 20, 'L'),
('V20_M_HELLO', 'HELLO WORLD', 20, 'M'),
('V20_Q_HELLO', 'HELLO WORLD', 20, 'Q'),
('V20_H_HELLO', 'HELLO WORLD', 20, 'H'),

-- Version 40

('V40_L_HELLO', 'HELLO WORLD', 40, 'L'),
('V40_M_HELLO', 'HELLO WORLD', 40, 'M'),
('V40_Q_HELLO', 'HELLO WORLD', 40, 'Q'),
('V40_H_HELLO', 'HELLO WORLD', 40, 'H');


-- -----------------------------------------------------------------------------
-- Numeric Mode
-- -----------------------------------------------------------------------------

('NUMERIC_V01_L'
,'012345678901234567890123456789'
,1
,'L'),

('NUMERIC_V20_M'
,'012345678901234567890123456789'
,20
,'M'),

('NUMERIC_V40_H'
,'012345678901234567890123456789'
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Alphanumeric Mode
-- -----------------------------------------------------------------------------

('ALPHA_V01_L'
,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
,1
,'L'),

('ALPHA_V20_M'
,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
,20
,'M'),

('ALPHA_V40_H'
,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Byte Mode ASCII
-- -----------------------------------------------------------------------------

('BYTE_ASCII_V01_L'
,'Hello World'
,1
,'L'),

('BYTE_ASCII_V20_M'
,'Hello World'
,20
,'M'),

('BYTE_ASCII_V40_H'
,'Hello World'
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Byte Mode UTF-8 / Umlaute
-- -----------------------------------------------------------------------------

('UTF8_UMLAUT_V20_M'
,'Grüße aus Langenfeld'
,20
,'M'),

('UTF8_UMLAUT_V40_H'
,'Grüße aus Langenfeld'
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Sonderzeichen
-- -----------------------------------------------------------------------------

('SPECIAL_V20_M'
,'!@#$%^&*()[]{}<>?/|\'
,20
,'M'),

('SPECIAL_V40_H'
,'!@#$%^&*()[]{}<>?/|\'
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Leerstring
-- -----------------------------------------------------------------------------

('EMPTY_V01_L'
,''
,1
,'L'),

('EMPTY_V40_H'
,''
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Maximale Feldlänge Regression
-- -----------------------------------------------------------------------------

('MAX255_V20_M'
,REPLICATE('A',255)
,20
,'M'),

('MAX255_V40_H'
,REPLICATE('A',255)
,40
,'H'),

-- -----------------------------------------------------------------------------
-- Gemischte Zeichen
-- -----------------------------------------------------------------------------

('MIXED_V20_M'
,'Invoice-2026-11-10#4711'
,20
,'M'),

('MIXED_V40_H'
,'Invoice-2026-11-10#4711'
,40
,'H')

-- -----------------------------------------------------------------------------
-- invalid
-- -----------------------------------------------------------------------------

('INVALID_VERSION'
,'HELLO'
,41
,'M'),

('INVALID_ECC'
,'HELLO'
,1
,'X')

MERGE [QR].[RegressionTest] AS [Target]
USING @Source AS [Source]
ON [Target].[TestName] = [Source].[TestName]

WHEN MATCHED
AND
(
       ISNULL([Target].[InputText], '')            <> [Source].[InputText]
    OR ISNULL([Target].[VersionNumber], 0)         <> [Source].[VersionNumber]
    OR ISNULL([Target].[ErrorCorrectionLevel], '') <> [Source].[ErrorCorrectionLevel]
)
THEN
    UPDATE
       SET [InputText]            = [Source].[InputText]
         , [VersionNumber]        = [Source].[VersionNumber]
         , [ErrorCorrectionLevel] = [Source].[ErrorCorrectionLevel]

WHEN NOT MATCHED BY TARGET
THEN
    INSERT
    (
          [TestName]
        , [InputText]
        , [VersionNumber]
        , [ErrorCorrectionLevel]
    )
    VALUES
    (
          [Source].[TestName]
        , [Source].[InputText]
        , [Source].[VersionNumber]
        , [Source].[ErrorCorrectionLevel]
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;