<#
.SYNOPSIS
  Downloads everything needed to build the accessible Counter-Strike 1.6, at the exact versions
  used by this project, and applies the accessibility patches.

.DESCRIPTION
  Into the project folder (the parent of "tools"):
    repos\xash3d-fwgs            FWGS/xash3d-fwgs @ 97cd12c + patches\xash3d-fwgs.patch
    repos\cs16-client            Velaron/cs16-client @ e30e27c (+ submodules) + patches\cs16-client.patch
      3rdparty\mainui_cpp        + patches\mainui_cpp.patch
    repos\nvda_controllerClient  NVDA 2026.2 controller client
    tools\SDL2-2.32.10           SDL2 development files (Visual C++)
    tools\winsdk                 (-LocalSdk) Windows SDK headers/libs from NuGet, no admin rights needed

  Each repository is left on a branch "accessibility-nvda" with the patch applied (not committed).
  Existing folders are kept; delete them to download again.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\scripts\setup_sources.ps1 -LocalSdk
#>
param([switch]$LocalSdk)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is very slow with the progress bar

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ($Root.Length -gt 60) {
    Write-Warning "Le dossier du projet a un chemin long ($($Root.Length) caractères). Certains fichiers du moteur ont des noms très longs : préférez un dossier court comme C:\CS16 si la compilation échoue."
}
$Repos = Join-Path $Root 'repos'
$Tools = Join-Path $Root 'tools'
$PatchDir = Join-Path $Root 'patches'
New-Item -ItemType Directory -Force -Path $Repos | Out-Null

# Named Invoke-Git: PowerShell names are case-insensitive, so a function called "Git" would
# call itself instead of git.exe.
function Invoke-Git([string[]]$gitArgs) {
    # core.longpaths: some submodules (mbedtls) have paths longer than Windows' 260 characters.
    & git.exe -c core.longpaths=true @gitArgs
    if ($LASTEXITCODE -ne 0) { throw "git $($gitArgs -join ' ') a échoué" }
}

# Clone one commit (shallow) with its submodules, then apply our patches on a local branch.
# Resumable: a marker file records that the patches were applied, so a rerun after an
# interruption applies them to an existing checkout instead of skipping it.
function Get-Repo([string]$url, [string]$dir, [string]$commit, [string[]]$patchList) {
    $marker = Join-Path $dir '.access_patched'
    if (Test-Path $marker) {
        Write-Host "  déjà présent : $dir"
        return
    }
    $haveCheckout = $false
    if (Test-Path (Join-Path $dir '.git')) {
        & git.exe -C $dir rev-parse --verify -q HEAD *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "$dir contient un dépôt incomplet (échec précédent) : supprimez ce dossier puis relancez."
        }
        $haveCheckout = $true
    }
    if (-not $haveCheckout) {
        Write-Host "  $url @ $($commit.Substring(0, 7))"
        Invoke-Git @('init', '-q', $dir)
        Invoke-Git @('-C', $dir, 'remote', 'add', 'origin', $url)
        Invoke-Git @('-C', $dir, 'fetch', '-q', '--depth', '1', 'origin', $commit)
        Invoke-Git @('-C', $dir, 'checkout', '-q', '-b', 'accessibility-nvda', $commit)
    }
    Invoke-Git @('-C', $dir, 'submodule', 'update', '-q', '--init', '--recursive', '--depth', '1')
    foreach ($p in $patchList) {
        $parts = $p -split '\|'
        $target = if ($parts.Count -gt 1) { Join-Path $dir $parts[1] } else { $dir }
        Write-Host "    patch $($parts[0]) -> $target"
        Invoke-Git @('-C', $target, 'apply', '--whitespace=nowarn', (Join-Path $PatchDir $parts[0]))
    }
    Set-Content -Path $marker -Value "patches: $($patchList -join ', ')"
}

function Get-Zip([string]$url, [string]$dest, [string]$check) {
    if (Test-Path $check) {
        Write-Host "  déjà présent : $check"
        return
    }
    $zip = Join-Path $env:TEMP ([IO.Path]::GetFileName($url))
    Write-Host "  $url"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $dest -Force
    Remove-Item $zip
}

Write-Host 'Sources :'
Get-Repo 'https://github.com/FWGS/xash3d-fwgs.git' (Join-Path $Repos 'xash3d-fwgs') `
    '97cd12c4d4773db1231f52ef09cad56bb65aaea2' @('xash3d-fwgs.patch')
Get-Repo 'https://github.com/Velaron/cs16-client.git' (Join-Path $Repos 'cs16-client') `
    'e30e27c3bd890f731ad7921d9c876d171aea4b32' @('cs16-client.patch', 'mainui_cpp.patch|3rdparty\mainui_cpp')

Write-Host 'Bibliothèques :'
Get-Zip 'https://github.com/libsdl-org/SDL/releases/download/release-2.32.10/SDL2-devel-2.32.10-VC.zip' `
    $Tools (Join-Path $Tools 'SDL2-2.32.10\lib\x86\SDL2.dll')
Get-Zip 'https://download.nvaccess.org/releases/stable/nvda_2026.2_controllerClient.zip' `
    (Join-Path $Repos 'nvda_controllerClient') (Join-Path $Repos 'nvda_controllerClient\x86\nvdaControllerClient.dll')

if ($LocalSdk) {
    Write-Host 'SDK Windows local (NuGet) :'
    $sdkDir = Join-Path $Tools 'winsdk'
    if (Test-Path (Join-Path $sdkDir 'c\Include')) {
        Write-Host "  déjà présent : $sdkDir"
    } else {
        $version = '10.0.28000.2705'
        foreach ($pkg in 'microsoft.windows.sdk.cpp', 'microsoft.windows.sdk.cpp.x86') {
            $url = "https://api.nuget.org/v3-flatcontainer/$pkg/$version/$pkg.$version.nupkg"
            $zip = Join-Path $env:TEMP "$pkg.zip"
            Write-Host "  $url"
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
            Expand-Archive -Path $zip -DestinationPath $sdkDir -Force
            Remove-Item $zip
        }
    }
}

Write-Host ''
Write-Host 'Terminé. Étapes suivantes :'
Write-Host '  tools\scripts\build_xash.bat configure'
Write-Host '  tools\scripts\build_velaron.bat'
Write-Host '  powershell -ExecutionPolicy Bypass -File tools\scripts\assemble_game.ps1 -Source "<dossier Half-Life>"'
