#Requires -Version 7.0
<#
.SYNOPSIS
  Builds, packages and (optionally) signs Terminal Vertical (x64, Release).
.PARAMETER PfxPath
  Code signing certificate (.pfx). Its subject must match the manifest Publisher (CN=Sostisoft).
.PARAMETER PfxPassword
  Password for the .pfx file. Read from $env:TERMINAL_VERTICAL_PFX_PASSWORD when omitted.
#>
param(
    [string]$PfxPath = "",
    [string]$PfxPassword = $env:TERMINAL_VERTICAL_PFX_PASSWORD,
    [string]$OutDir = (Join-Path $PSScriptRoot "..\..\out\sostisoft")
)
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$env:PATH = "C:\Program Files\dotnet;" + [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + $env:PATH

Set-Location $root
Import-Module .\tools\OpenConsole.psm1
Set-MsBuildDevEnvironment
& .\dep\nuget\nuget.exe restore OpenConsole.slnx | Out-Null
& .\dep\nuget\nuget.exe restore dep\nuget\packages.config | Out-Null
msbuild OpenConsole.slnx /m /nr:false /v:m `
    /p:Configuration=Release /p:Platform=x64 `
    "/t:Terminal\CascadiaPackage" /p:AppxBundle=Never
if ($LASTEXITCODE -ne 0) { throw "msbuild failed with exit code $LASTEXITCODE" }

$msix = Get-ChildItem -Recurse "src\cascadia\CascadiaPackage\AppPackages" -Filter *.msix |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $msix) { throw "No .msix produced" }

New-Item -ItemType Directory -Force $OutDir | Out-Null
$target = Join-Path $OutDir "TerminalVertical_x64.msix"
Copy-Item $msix.FullName $target -Force

if ($PfxPath) {
    if (-not $PfxPassword) { throw "PfxPassword (or TERMINAL_VERTICAL_PFX_PASSWORD) is required to sign" }
    $signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" |
        Sort-Object FullName -Descending | Select-Object -First 1
    & $signtool.FullName sign /fd SHA256 /f $PfxPath /p $PfxPassword $target
    if ($LASTEXITCODE -ne 0) { throw "signtool failed with exit code $LASTEXITCODE" }
}
Write-Host "Package: $target"
