#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Chenron MSIX package and its signing certificate.
.DESCRIPTION
    Extracts the signing certificate from the MSIX, installs it into
    the TrustedPeople store (requires admin), then installs the app.
    Self-elevates to admin if not already running elevated.
#>

param(
    [string]$MsixPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Self-elevate if not admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $argList = "-ExecutionPolicy Bypass -File `"$scriptPath`""
    if ($MsixPath) {
        $argList += " -MsixPath `"$MsixPath`""
    }
    Start-Process powershell.exe -Verb RunAs -ArgumentList $argList
    exit
}

# --- Find the MSIX ---
if (-not $MsixPath) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $msixFile = Get-ChildItem -Path $scriptDir -Filter "*.msix" |
        Select-Object -First 1
    if (-not $msixFile) {
        Write-Host ""
        Write-Host "ERROR: No .msix file found in $scriptDir" `
            -ForegroundColor Red
        Write-Host "Place this script next to the .msix file and " `
            -NoNewline
        Write-Host "run it again." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    $MsixPath = $msixFile.FullName
}

if (-not (Test-Path $MsixPath)) {
    Write-Host "ERROR: File not found: $MsixPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "=== Chenron Installer ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "MSIX: $MsixPath"
Write-Host ""

# --- Extract and install certificate ---
Write-Host "Installing signing certificate..." -ForegroundColor Yellow

$sig = Get-AuthenticodeSignature -FilePath $MsixPath
if (-not $sig.SignerCertificate) {
    Write-Host "ERROR: Could not extract certificate from MSIX." `
        -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
    "TrustedPeople",
    [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
)
$store.Open("ReadWrite")
$store.Add($sig.SignerCertificate)
$store.Close()

Write-Host "Certificate installed to TrustedPeople store." `
    -ForegroundColor Green
Write-Host ""

# --- Install the MSIX ---
Write-Host "Installing Chenron..." -ForegroundColor Yellow

try {
    Add-AppxPackage -Path $MsixPath
    Write-Host ""
    Write-Host "Chenron installed successfully!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
