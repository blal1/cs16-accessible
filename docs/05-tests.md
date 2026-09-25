# 05 — Tests automatisés

On ne peut pas vérifier un jeu accessible en le regardant, et écouter chaque annonce à chaque
modification est lent. Le projet enregistre donc **tout ce qui est envoyé à NVDA** dans un fichier
texte, et un script pilote le jeu avec de vraies touches.

## Le journal de parole

Si la variable d'environnement `ACCESS_TTS_LOG` contient un chemin de fichier, chaque bibliothèque
(moteur, menus, client) y écrit une ligne par événement :

| Préfixe | Signification |
|---|---|
| `! ` | annonce qui coupe la précédente (changement de focus, menu…) |
| `  ` (deux espaces) | annonce mise en file d'attente (messages, HUD) |
| `# ` | diagnostic, jamais prononcé : fenêtre ouverte et ses éléments, premier emploi de chaque son avec sa position (`pan` −1 gauche → +1 droite, `étouffé` 0 devant → 1 derrière) |

Exemple réel :

```
# fenêtre CMenuAudio, 10 éléments, curseur 0
! Options audio
[touche Right]
! Volume des effets sonores, curseur, 60 pour cent
[touche Right]
! 65 pour cent
```

## Le pilote : `tools\scripts\menu_test.ps1`

Il lance le jeu en fenêtre, attend qu'elle existe, envoie les touches **directement à la fenêtre du
jeu** (sans dépendre du premier plan), puis affiche le journal.

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\menu_test.ps1 `
    -GameDir CS16_Xash `
    -StartupSeconds 20 -KeyDelayMs 1500 `
    -GameArgs "+maxplayers 4 +map de_dust2" `
    -KeyList "2 5 F6 h F9 z*2000"
```

| Paramètre | Rôle |
|---|---|
| `-GameDir` | dossier du jeu (défaut `CS16_Xash` à côté du projet) |
| `-StartupSeconds` | attente après l'apparition de la fenêtre (menu : 15 ; carte : 20) |
| `-KeyDelayMs` | pause entre deux touches |
| `-GameArgs` | arguments du jeu : `+map de_dust2`, `+exec fichier.cfg`, réglages… |
| `-KeyList` | touches séparées par des espaces : `Up Down Left Right Enter Esc Tab Space Back F1`…`F12`, lettres et chiffres ; `z*2000` maintient Z pendant 2 secondes (se déplacer) |

Les touches sont envoyées par code de touche virtuel : sur un clavier AZERTY, `z` correspond à la
touche Z (avancer), `w` à la radio.

## La suite complète : `tools\tests\run_suite.ps1`

Une commande lance tous les scénarios (menus, options, touches, viseur, pages d'options, requêtes en jeu,
guidage, bombe lâchée, flash, rechargement, zones d'otages, échelles, portes, MOTD web, spectateur,
chat et console, ennemis avec bots) et vérifie dans le journal les phrases attendues :

```powershell
powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1             # hors ligne, ~20 minutes
powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1 -Only flash,zones_hostages
powershell -ExecutionPolicy Bypass -File tools\tests\run_suite.ps1 -Online     # + un vrai serveur public
```

Un scénario en échec est relancé une fois (PASS2 : réussi au second essai). Ne tapez pas au clavier
pendant la suite : le jeu prend le focus à chaque lancement et recevrait vos touches.

Résultat : un tableau PASS / PASS2 / FAIL / WARN (WARN = scénario dépendant des bots, non bloquant) dans
`tools\tests\last_report.txt`, et la transcription des échecs dans `last_report.txt.log`. Le code de
sortie est le nombre d'échecs. Les fichiers de test nécessaires (configs, faux MOTD) sont créés dans
`cstrike\` puis supprimés.

Les lettres sont envoyées par **position QWERTY**, comme le jeu nomme ses touches : `w` avance sur
n'importe quel clavier. `Del` (Suppr) sert d'attente : elle n'est liée à rien (F1 lance « autobuy »).
Les scénarios de menu commencent par `Del Up` : Haut place toujours le focus sur « Quitter ».

## Scénarios utiles

| Vérifier | Commande (paramètres) |
|---|---|
| menus principaux | `-KeyList "Down Down Enter Down Esc Esc"` |
| options audio (curseurs) | `-KeyList "Down Down Enter Down Down Enter Down Right Right Left"` |
| menus en jeu, HUD, touches | `-StartupSeconds 20 -GameArgs "+maxplayers 4 +map de_dust2" -KeyList "2 5 b 8 0 F6 h F9 F11 F3 F4 j i"` |
| chat et console | `-GameArgs "+maxplayers 4 +map de_dust2 +bind F2 toggleconsole" -KeyList "2 5 y s a l u Back Enter F2 e c h o Space o k Enter Esc"` |
| sons de déplacement | `-GameArgs "+maxplayers 4 +map de_dust2" -KeyList "2 5 z*3000 q*1200 z*3000"` |
| combat contre des bots | `-GameArgs "+maxplayers 8 +map de_dust2 +bot_join_team T +bot_quota 5" -KeyDelayMs 6000 -KeyList "2 5 j z*3000 j F6 j"` |
| visée (bots figés) | copier `tools\tests\test_aim.cfg` dans `cstrike`, `-GameArgs "+maxplayers 8 +map de_dust2 +exec test_aim.cfg"`, puis U pour figer les bots et de nombreux `Left*25` pour tourner |
| grenade personnelle | copier `tools\tests\test_attack.cfg`, acheter (`b 8 4`), sélectionner (`4`), lancer (`p*800`) |
| grenades ennemies | copier `tools\tests\test_nades.cfg` (bots limités aux grenades et au couteau) |

Pensez à retirer les fichiers `test_*.cfg` du dossier du jeu après usage.

## Tests sans le jeu

| Test | Commande | Vérifie |
|---|---|---|
| cartes et chemins | `tools\navtools\build_test.bat` puis `test_access_map.exe <dossier maps> de_dust2 cs_office …` | lecture des 25 cartes, un chemin de chaque départ vers chaque objectif (attendu : `unreachable paths: 0`) |
| sons | `tools\audiotest\build.bat` puis `test_access_audio.exe` | initialisation de XAudio2, chaque son joué à 4 positions, export WAV |
| formats | `py tools\navtools\navparse.py <fichier.nav>`, `py tools\navtools\bspents.py <fichier.bsp>` | analyseurs Python indépendants, pour recouper le code C++ |

## Reproduction complète

Pour vérifier que le projet se reconstruit depuis zéro, copiez `tools\scripts`,
`tools\msvc_x86_env.bat`, `patches` et `distribution` dans un dossier vide **au chemin court**,
puis enchaînez `setup_sources.ps1 -LocalSdk`, `build_xash.bat configure`, `build_velaron.bat`,
`assemble_game.ps1` et `menu_test.ps1`. C'est ainsi que les scripts de ce projet ont été validés.

## Ce qui a été vérifié

Voir la section « Verification » de `repos\cs16-client\docs\accessibility-design.md`. Ce qui n'a pas
encore été fait : une partie jouée par une personne aveugle. Les retours d'un vrai joueur restent le
meilleur test.
