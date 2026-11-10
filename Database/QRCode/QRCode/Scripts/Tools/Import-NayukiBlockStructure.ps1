# ##############################################################################
# ### Script: Import-NayukiBlockStructure.ps1                                ###
# ##############################################################################
# ### Purpose:                                                               ###
# ### Extracts QR block structure metadata from Nayuki QR Code sources       ###
# ### and generates SQL INSERT statements for                                ###
# ### [QR].[ImportVersionBlockStructure].                                    ###
# ##############################################################################

param
(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [string]$OutputFile =
        ".\ImportVersionBlockStructure.sql"
)

$Content = Get-Content $InputFile -Raw

# ECC_CODEWORDS_PER_BLOCK
$EccMatch =
    [regex]::Match(
        $Content,
        'ECC_CODEWORDS_PER_BLOCK.*?\{(.*?)\};',
        'Singleline'
    )

# NUM_ERROR_CORRECTION_BLOCKS
$BlockMatch =
    [regex]::Match(
        $Content,
        'NUM_ERROR_CORRECTION_BLOCKS.*?\{(.*?)\};',
        'Singleline'
    )

if (-not $EccMatch.Success)
{
    throw "ECC table not found."
}

if (-not $BlockMatch.Success)
{
    throw "Block table not found."
}

# Parser hier projektspezifisch erweitern
# Ausgabe zunächst in eine Staging-Tabelle

$Sql = @()

$Sql += "TRUNCATE TABLE [QR].[ImportVersionBlockStructure];"
$Sql += ""

# Hier wird später Version für Version erzeugt

Set-Content `
    -Path $OutputFile `
    -Value $Sql `
    -Encoding UTF8

Write-Host "Generated $OutputFile"