# Accessibility regression suite: runs every scenario with menu_test.ps1 (real key presses
# posted to the game) and checks the speech transcript for the expected announcements.
#
#   powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1            # all offline scenarios
#   powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1 -Only zones,flash
#   powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1 -Online    # + a public server
#
# Keys: letters by US QWERTY position (w = forward), "Del" = wait (bound to nothing), menu
# scenarios start with "Del Up" (Up always lands on Quitter, whatever the startup focus).
# A failed scenario is run once more (PASS2 = passed the second time). Do not type while
# the suite runs: the game takes the keyboard focus at each launch.
# Report: tools\tests\last_report.txt. Exit code = number of failed scenarios.
param(
    [string[]]$Only = @(),
    [switch]$Online,
    [string]$OnlineServer = '5.196.165.2:27015',
    [string]$GameDir = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'CS16_Xash')
)
$ErrorActionPreference = 'Continue'
$Only = @($Only | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$driver = Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts\menu_test.ps1'
$cstrike = Join-Path $GameDir 'cstrike'
$report = Join-Path $PSScriptRoot 'last_report.txt'

$down = { param($n) (1..$n | ForEach-Object { 'Down' }) -join ' ' }
$wait = { param($n) (1..$n | ForEach-Object { 'Del' }) -join ' ' }
$bots0 = '+bot_quota 0 +mp_freezetime 0'

# Name, game arguments, keys, expected (regex, all must appear), extra files for cstrike\.
$scenarios = @(
    @{ Name = 'menu_main'; Args = ''; Keys = "Del Up Down"; Expect = @('Menu principal', 'Quitter, bouton', "Salle d'entraînement, bouton") },
    @{ Name = 'multiplayer'; Args = ''; Keys = "Del Up $(& $down 4) Enter $(& $down 2) Enter Del Del Down";
       Expect = @('Multijoueur', 'Partie en réseau local, bouton', 'Liste des serveurs', 'Rejoindre la partie, bouton') },
    @{ Name = 'options_audio'; Args = ''; Keys = "Del Up $(& $down 2) Enter $(& $down 2) Enter $(& $down 2) Right Left";
       Expect = @('Options audio', 'Volume des effets sonores, curseur, \d+ pour cent', '^! \d+ pour cent') },
    @{ Name = 'key_list'; Args = ''; Keys = "Del Up $(& $down 4) Enter $(& $down 4) Enter $(& $down 11)";
       Expect = @('Touches du clavier', 'liste de \d+ éléments', 'Section Mouvement', 'Avancer, flèche haut, [A-Z]') },
    @{ Name = 'crosshair'; Args = ''; Keys = "Del Up $(& $down 4) Enter $(& $down 3) Enter $(& $down 4) Enter $(& $down 7)";
       Expect = @('Réglage du viseur', 'Taille, sélecteur', 'Couleur, sélecteur', 'Annuler, bouton', 'OK, bouton') },
    @{ Name = 'mod_options'; Args = ''; Keys = "Del Up $(& $down 4) Enter $(& $down 3) Enter $(& $down 2) Enter $(& $down 3) Right";
       Expect = @('Options de jeu', 'Page, sélecteur, flèches gauche et droite, 1 sur \d', '2 sur \d') },
    @{ Name = 'ingame_queries'; Args = "+maxplayers 4 +map de_dust2 $bots0"; Keys = "2 5 Del p F11 F3 F4 F6 v l j i";
       Expect = @('de_dust2 : pose et désamorçage de bombe', 'Vous êtes ', 'Vous : \d+ frags', '(minute|seconde)', 'Santé 100',
                  'Aucune échelle', 'Aucun objet', 'Aucun ennemi', 'Face (nord|sud|est|ouest)') },
    @{ Name = 'guidance'; Args = "+maxplayers 4 +map de_dust2 $bots0"; Keys = "2 5 Del F9 Home w*4000 Del F12";
       Expect = @('site de bombe (est|ouest), \d+ mètres', 'Face .*, avancez', '(Entre|Près|Au milieu)', 'Guidage arrêté') },
    @{ Name = 'bomb_drop'; Args = "+maxplayers 4 +map de_dust2 +exec test_items.cfg"; Keys = "1 5 Del n g Del l";
       Files = @('test_items.cfg'); Expect = @('Vous portez la bombe', 'Bombe au sol en vue', 'bombe au sol, \d+ heure') },
    @{ Name = 'flash'; Args = "+maxplayers 4 +map de_dust2 +exec test_flash.cfg"; Keys = "2 5 Del Del n k Del Enter*500 $(& $wait 7)";
       Files = @('test_flash.cfg'); Expect = @('grenade flash', 'Aveuglé, \d+ seconde', 'Vue revenue') },
    @{ Name = 'reload'; Args = "+maxplayers 4 +map de_dust2 $bots0"; Keys = "2 5 Del Enter*150 Enter*150 Enter*150 r Del Del";
       Expect = @('Rechargé, \d+ balles') },
    @{ Name = 'zones_hostages'; Args = "+maxplayers 4 +map cs_office $bots0"; Keys = "2 5 Del p s*3000 Del w*3000 Del";
       Expect = @('sauvetage d''otages', '\d otages', 'Vous (entrez|quittez) : zone de sauvetage') },
    @{ Name = 'ladder'; Args = "+maxplayers 4 +map de_train $bots0"; Keys = "1 5 Del v Del F12";
       Expect = @('Échelle la plus proche, \d+ mètres', 'Guidage arrêté') },
    @{ Name = 'doors'; Args = "+maxplayers 4 +map cs_assault $bots0"; Keys = "1 5 Del l";
       Expect = @('Porte, \d+ heure') },
    @{ Name = 'motd_web'; Args = "+maxplayers 4 +motdfile motd_test.txt +map de_dust2 $bots0"; Keys = "Del";
       Files = @('motd_test.txt'); Expect = @('Message du serveur : page web') },
    @{ Name = 'spectator'; Args = "+maxplayers 6 +map de_dust2 +bot_quota 2 +mp_freezetime 0"; Keys = "6 Del Del F6";
       Expect = @('Spectateur, ', 'Entrée : joueur suivant', '^! Spectateur') },
    @{ Name = 'chat_console'; Args = "+maxplayers 4 +map de_dust2 +bind F2 toggleconsole $bots0"; Keys = "2 5 Del y s a Back Enter F2 e c h o Space o k Enter Esc";
       Expect = @('Message à tous', 'effacé', 'Message envoyé', 'Console\.', 'Console fermée') },
    @{ Name = 'enemies_bots'; Args = "+maxplayers 8 +map de_dust2 +bot_quota 5 +bot_join_team T +mp_freezetime 0";
       Keys = "2 5 Del w*3000 Del w*3000 $(& $wait 12)"; Optional = $true;
       Expect = @('Ennemi, \d+ heure', '(a tué|Vous êtes mort)') }
)
if ($Online) {
    $scenarios += @{ Name = 'online_server'; Args = "+bind F2 disconnect +connect $OnlineServer"; Startup = 3; Delay = 3000;
        Keys = "$(& $wait 10) 5 5 $(& $wait 4) F2 Del";
        Expect = @('Connexion à ', 'Connecté, chargement', 'Carte ', 'Choisissez une équipe', 'Déconnecté du serveur') }
}

# Files the scenarios copy into cstrike\ (removed afterwards).
$fileContents = @{
    'test_items.cfg' = "bind `"n`" `"use weapon_c4`"`nbot_quota 2`nmp_freezetime 0`n"
    'test_flash.cfg' = "bind `"n`" `"flash`"`nbind `"k`" `"slot4`"`nbot_quota 0`nmp_freezetime 0`nhud_fastswitch 1`n"
    'motd_test.txt'  = 'http://example.com/motd.html'
}

Remove-Item "$report.log" -ErrorAction SilentlyContinue
$results = @()
foreach ($s in $scenarios) {
    if ($Only.Count -and $Only -notcontains $s.Name) { continue }
    Write-Host "=== $($s.Name)"
    $attempt = 0
    do {
        $attempt++
        $copied = @()
        foreach ($f in @($s.Files)) {
            if (-not $f) { continue }
            $target = Join-Path $cstrike $f
            [IO.File]::WriteAllText($target, $fileContents[$f])
            $copied += $target
        }
        $startup = if ($s.Startup) { $s.Startup } elseif ($s.Args) { 22 } else { 25 }
        $delay = if ($s.Delay) { $s.Delay } elseif ($s.Args) { 2000 } else { 1400 }
        try {
            $argv = @('-ExecutionPolicy', 'Bypass', '-File', $driver, '-GameDir', $GameDir, '-StartupSeconds', $startup,
                '-KeyDelayMs', $delay, '-KeyList', "`"$($s.Keys)`"")
            if ($s.Args) { $argv += @('-GameArgs', "`"$($s.Args)`"") }
            $out = & powershell @argv 2>&1 | Out-String
        } finally {
            foreach ($c in $copied) { Remove-Item $c -ErrorAction SilentlyContinue }
        }
        $missing = @()
        foreach ($e in $s.Expect) {
            if (-not ([regex]::IsMatch($out, $e, 'Multiline'))) { $missing += $e }
        }
    } while ($missing.Count -and $attempt -lt 2)
    # PASS2: passed on the second try (timing, or a key typed on the real keyboard).
    $status = if (-not $missing.Count) { if ($attempt -gt 1) { 'PASS2' } else { 'PASS' } } elseif ($s.Optional) { 'WARN' } else { 'FAIL' }
    Write-Host "$status $($s.Name)"
    $results += [pscustomobject]@{ Scenario = $s.Name; Status = $status; Missing = ($missing -join ' | ') }
    if ($status -ne 'PASS') {
        $lines = ($out -split "`n" | Where-Object { $_ -notmatch '^#   ' }) -join "`n"
        Add-Content -Path "$report.log" -Value "===== $($s.Name) ($status)`n$lines" -Encoding UTF8
    }
}

$text = ($results | Format-Table -AutoSize -Wrap | Out-String -Width 200)
Set-Content -Path $report -Value $text -Encoding UTF8
Write-Host $text
$failed = @($results | Where-Object { $_.Status -eq 'FAIL' }).Count
Write-Host "$failed échec(s) ; transcriptions des échecs : $report.log"
exit $failed
