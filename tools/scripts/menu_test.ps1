# Launches Xash3D (menu or map), posts key presses straight to its window, and prints the
# speech transcript (ACCESS_TTS_LOG). Keys: Up Down Left Right Enter Esc Tab Space Back, a-z, 0-9.
param(
    [string]$KeyList = 'Down Down Enter Esc',
    [int]$StartupSeconds = 15,
    [int]$KeyDelayMs = 1500,
    [string]$GameArgs = '',
    # Game folder to test (default: the game next to this repository layout).
    [string]$GameDir = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'CS16_Xash')
)
if (-not (Test-Path (Join-Path $GameDir 'xash3d.exe'))) { Write-Host "ERREUR : pas de xash3d.exe dans $GameDir"; exit 1 }
$game = (Resolve-Path $GameDir).Path   # the game runs in its own folder: the log path must be absolute
$log = Join-Path $game 'speech_transcript.txt'
Remove-Item $log -ErrorAction SilentlyContinue
$env:ACCESS_TTS_LOG = $log
Write-Host "journal : [$log]"

Add-Type @"
using System; using System.Runtime.InteropServices;
public static class K {
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] public static extern uint MapVirtualKey(uint code, uint type);
    public static void Press(IntPtr h, uint vk, bool extended, int holdMs) {
        uint sc = MapVirtualKey(vk, 0);
        uint ext = extended ? (1u << 24) : 0u;
        PostMessage(h, 0x0100, (IntPtr)vk, (IntPtr)(1 | (sc << 16) | ext));
        System.Threading.Thread.Sleep(holdMs);
        PostMessage(h, 0x0101, (IntPtr)vk, (IntPtr)(1 | (sc << 16) | ext | (1u << 30) | (1u << 31)));
    }
}
"@

$vk = @{ Grave = 0xC0; F1 = 0x70; F2 = 0x71; F3 = 0x72; F4 = 0x73; F5 = 0x74; F6 = 0x75; F7 = 0x76; F8 = 0x77; F9 = 0x78; F10 = 0x79; F11 = 0x7A; F12 = 0x7B; Up = 0x26; Down = 0x28; Left = 0x25; Right = 0x27; Enter = 0x0D; Esc = 0x1B; Tab = 0x09; Space = 0x20; Back = 0x08 }
$extended = @('Up', 'Down', 'Left', 'Right')

$argsList = @('-game', 'cstrike', '-windowed', '-width', '800', '-height', '600', '-log') + ($GameArgs -split ' ' | Where-Object { $_ })
$p = Start-Process -FilePath (Join-Path $game 'xash3d.exe') -WorkingDirectory $game -ArgumentList $argsList -PassThru
# Wait for the game window itself (keys posted to handle 0 are silently lost),
# then give the game StartupSeconds to reach the menu or load the map.
$deadline = (Get-Date).AddSeconds(90)
do {
    Start-Sleep -Milliseconds 500
    $p.Refresh()
} while ($p.MainWindowHandle -eq 0 -and -not $p.HasExited -and (Get-Date) -lt $deadline)
if ($p.MainWindowHandle -eq 0) { Write-Host 'ERREUR : fenêtre du jeu introuvable'; exit 1 }
Start-Sleep -Seconds $StartupSeconds
$p.Refresh()
$hwnd = $p.MainWindowHandle
Write-Host ("fenêtre cible : {0} '{1}'" -f $hwnd, $p.MainWindowTitle)

foreach ($entry in ($KeyList -split ' ' | Where-Object { $_ })) {
    # "key*ms" holds the key down for ms milliseconds (movement)
    $k, $hold = $entry -split '\*'
    if (-not $hold) { $hold = 60 }
    if ($vk.ContainsKey($k)) { $code = $vk[$k] }
    elseif ($k.Length -eq 1) { $code = [int][char]$k.ToUpper() }
    else { Write-Host "unknown key $k"; continue }
    Add-Content -Path $log -Value "[touche $entry]" -Encoding UTF8
    [K]::Press($hwnd, [uint32]$code, $extended -contains $k, [int]$hold)
    Start-Sleep -Milliseconds $KeyDelayMs
}
Start-Sleep -Seconds 1
Stop-Process -Id $p.Id -Force
if (Test-Path $log) { Get-Content $log -Encoding UTF8 } else { 'NO TRANSCRIPT' }
