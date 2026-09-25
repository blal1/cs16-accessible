<#
.SYNOPSIS
  Assembles the accessible Counter-Strike 1.6 game folder (Xash3D FWGS + accessible client, menus
  and engine) from an existing CS 1.6 installation and the compiled binaries.

.DESCRIPTION
  -Source   folder of a legitimate CS 1.6 installation that contains "valve" and "cstrike"
            (Steam: ...\steamapps\common\Half-Life). It is only read, never modified.
  -Output   folder to create (default: CS16_Accessible\CS16_Xash_new).

  Uses:
    repos\xash3d-fwgs\out                      engine (tools\scripts\build_xash.bat)
    repos\cs16-client\build-x86                client.dll, menu.dll, mp.dll, extras.pk3 (build_velaron.bat)
    tools\SDL2-2.32.10\lib\x86\SDL2.dll
    distribution\                              accessibility profile, French translations, NVDA client

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\scripts\assemble_game.ps1 `
      -Source "C:\Program Files (x86)\Steam\steamapps\common\Half-Life" -Output D:\Jeux\CS16_Accessible
#>
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Output = '',
    [switch]$Force
)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)   # CS16_Accessible
if (-not $Output) { $Output = Join-Path $Root 'CS16_Xash_new' }

function Need([string]$path, [string]$hint) {
    if (-not (Test-Path $path)) { throw "Introuvable : $path`n$hint" }
}

$engineOut = Join-Path $Root 'repos\xash3d-fwgs\out'
$clientOut = Join-Path $Root 'repos\cs16-client\build-x86'
$sdl = Join-Path $Root 'tools\SDL2-2.32.10\lib\x86\SDL2.dll'
$dist = Join-Path $Root 'distribution'

Need (Join-Path $Source 'valve') 'Le dossier source doit contenir "valve" (Half-Life).'
Need (Join-Path $Source 'cstrike') 'Le dossier source doit contenir "cstrike" (Counter-Strike).'
Need (Join-Path $engineOut 'xash.dll') 'Compilez le moteur : tools\scripts\build_xash.bat configure'
Need (Join-Path $clientOut 'cl_dll\client.dll') 'Compilez le client : tools\scripts\build_velaron.bat'
Need $sdl 'Téléchargez SDL2-devel-2.32.10-VC.zip dans tools\ (voir la documentation).'
Need $dist 'Dossier distribution manquant.'

if (Test-Path $Output) {
    if (-not $Force) { throw "Le dossier $Output existe déjà (utilisez -Force pour le remplacer)." }
    Remove-Item $Output -Recurse -Force
}
New-Item -ItemType Directory -Path $Output | Out-Null
Write-Host "Assemblage dans $Output"

# 1. Game data from the user's own installation.
Write-Host '- copie des données du jeu (valve, cstrike)...'
Copy-Item (Join-Path $Source 'valve') (Join-Path $Output 'valve') -Recurse
Copy-Item (Join-Path $Source 'cstrike') (Join-Path $Output 'cstrike') -Recurse

# Closed-source GoldSrc/Steam UI libraries are not used by Xash3D; drop them so nothing loads them.
foreach ($f in 'cstrike\cl_dlls\GameUI.dll', 'cstrike\cl_dlls\client_mini.dll', 'valve\cl_dlls\GameUI.dll') {
    $p = Join-Path $Output $f
    if (Test-Path $p) { Remove-Item $p -Force }
}

# 2. Engine.
Write-Host '- moteur Xash3D accessible...'
foreach ($f in 'xash3d.exe', 'xash.dll', 'ref_gl.dll', 'filesystem_stdio.dll', 'vgui.dll') {
    Copy-Item (Join-Path $engineOut $f) $Output
}
Copy-Item (Join-Path $engineOut 'valve\extras.pk3') (Join-Path $Output 'valve\extras.pk3') -Force
Copy-Item $sdl $Output

# 3. Accessible client, menus and server (the original mp.dll is kept as mp_original.dll).
Write-Host '- client, menus et serveur accessibles...'
$cl = Join-Path $Output 'cstrike\cl_dlls'
$dl = Join-Path $Output 'cstrike\dlls'
New-Item -ItemType Directory -Force -Path $cl, $dl | Out-Null
$clientDll = Join-Path $cl 'client.dll'
if ((Test-Path $clientDll) -and -not (Test-Path (Join-Path $cl 'client_original.dll'))) {
    Rename-Item $clientDll 'client_original.dll'
}
$mpDll = Join-Path $dl 'mp.dll'
if ((Test-Path $mpDll) -and -not (Test-Path (Join-Path $dl 'mp_original.dll'))) {
    Rename-Item $mpDll 'mp_original.dll'
}
Copy-Item (Join-Path $clientOut 'cl_dll\client.dll') $cl -Force
Copy-Item (Join-Path $clientOut '3rdparty\mainui_cpp\menu.dll') $cl -Force
Copy-Item (Join-Path $clientOut '3rdparty\ReGameDLL_CS\regamedll\mp.dll') $dl -Force
Copy-Item (Join-Path $clientOut 'extras.pk3') (Join-Path $Output 'cstrike\extras.pk3') -Force

# 4. Screen reader bridge (next to the engine and to the client/menu libraries).
Copy-Item (Join-Path $dist 'engine\nvdaControllerClient.dll') $Output -Force
Copy-Item (Join-Path $dist 'engine\nvdaControllerClient.dll') $cl -Force

# 5. Accessibility profile and French translations.
Write-Host '- profil d''accessibilité et traductions françaises...'
Copy-Item (Join-Path $dist 'cstrike\access.cfg') (Join-Path $Output 'cstrike\access.cfg') -Force
New-Item -ItemType Directory -Force -Path (Join-Path $Output 'cstrike\resource') | Out-Null
Copy-Item (Join-Path $dist 'cstrike\resource\mainui_french.txt') (Join-Path $Output 'cstrike\resource') -Force
$titles = Join-Path $Output 'cstrike\titles.txt'
$titlesEn = Join-Path $Output 'cstrike\titles_english.txt'
if ((Test-Path $titles) -and -not (Test-Path $titlesEn)) { Copy-Item $titles $titlesEn }
Copy-Item (Join-Path $dist 'cstrike\titles_french.txt') $titles -Force

# 6. Host settings: 60 s buy time, so buy menus can be listened to and used.
$gameCfg = Join-Path $Output 'cstrike\game.cfg'
$line = 'mp_buytime 1 // accessibilité : 60 s pour écouter et utiliser les menus d''achat'
if (Test-Path $gameCfg) {
    $text = Get-Content $gameCfg -Raw
    if ($text -match '(?m)^mp_buytime.*$') { $text = $text -replace '(?m)^mp_buytime.*$', $line }
    else { $text = $text.TrimEnd() + "`r`n" + $line + "`r`n" }
    Set-Content $gameCfg $text -Encoding UTF8
} else {
    Set-Content $gameCfg $line -Encoding UTF8
}

# 7. Shortcut. ui_language on the command line so the very first menu frame is already French.
$lnk = Join-Path $Output 'Counter-Strike accessible.lnk'
$s = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$s.TargetPath = Join-Path $Output 'xash3d.exe'
$s.Arguments = '-game cstrike +ui_language french'
$s.WorkingDirectory = $Output
$s.Description = 'Counter-Strike 1.6 accessible (NVDA)'
$s.Save()

Write-Host ''
Write-Host "Terminé. Lancez : $lnk (NVDA doit être en marche)."
