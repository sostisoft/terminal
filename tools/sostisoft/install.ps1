<#
.SYNOPSIS
  Installs the latest Terminal Vertical release from GitHub.
.DESCRIPTION
  Run in an elevated Windows PowerShell:
    irm https://raw.githubusercontent.com/sostisoft/terminal/sostisoft/vertical/tools/sostisoft/install.ps1 | iex
  Trusts the Sostisoft signing certificate (LocalMachine\TrustedPeople) and installs the .msix.
#>
$ErrorActionPreference = 'Stop'
$repo = 'sostisoft/terminal'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this script from an elevated (Administrator) PowerShell."
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
$workDir = Join-Path $env:TEMP 'terminal-vertical'
New-Item -ItemType Directory -Force $workDir | Out-Null

$cerAsset = $release.assets | Where-Object { $_.name -like '*.cer' } | Select-Object -First 1
$msixAsset = $release.assets | Where-Object { $_.name -like '*.msix' } | Select-Object -First 1
if (-not $cerAsset -or -not $msixAsset) { throw "Release $($release.tag_name) is missing the .cer or .msix asset" }

$cerPath = Join-Path $workDir $cerAsset.name
$msixPath = Join-Path $workDir $msixAsset.name
Invoke-WebRequest $cerAsset.browser_download_url -OutFile $cerPath -UseBasicParsing
Invoke-WebRequest $msixAsset.browser_download_url -OutFile $msixPath -UseBasicParsing

Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople | Out-Null
Add-AppxPackage -Path $msixPath -ForceApplicationShutdown
Write-Host "Terminal Vertical $($release.tag_name) installed. Launch it from the Start menu or run 'wtd'."
