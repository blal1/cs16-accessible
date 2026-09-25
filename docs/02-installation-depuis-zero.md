# 02 — Installation depuis zéro

Ce guide reconstruit le jeu accessible sur n'importe quel PC Windows : téléchargement des sources,
application des modifications, compilation, assemblage avec vos données de jeu. Comptez environ
30 minutes, dont 10 de compilation.

Si quelqu'un vous a déjà donné le dossier du jeu assemblé (`CS16_Xash`), vous n'avez rien à faire
ici : lisez le [guide du joueur](01-guide-du-joueur.md).

## 1. Ce qu'il faut

| Élément | Où le trouver | Remarque |
|---|---|---|
| Windows 10 ou 11, 64 bits | | le jeu est compilé en 32 bits, ce qui est normal |
| NVDA | https://www.nvaccess.org | pour jouer ; pas nécessaire pour compiler |
| Counter-Strike 1.6 | votre copie, par exemple Steam : `...\steamapps\common\Half-Life` | il faut les dossiers `valve` et `cstrike` |
| Visual Studio 2022 ou 2026 (Community ou Build Tools) | https://visualstudio.microsoft.com | charge de travail **Développement Desktop en C++** avec **Outils CMake C++ pour Windows** |
| Git | https://git-scm.com | |
| Python 3 | https://www.python.org | utilisé par le système de compilation du moteur (waf) et par CMake ; cochez « Add to PATH » et le lanceur `py` |
| Le dossier du projet | `docs`, `patches`, `distribution`, `tools\scripts`, `tools\msvc_x86_env.bat`, `tools\tests` | c'est tout ce qu'il faut transmettre |

**Kit de développement Windows (SDK).** Deux possibilités :
- l'installer avec Visual Studio (composant « Windows 11 SDK »), ce qui demande des droits
  administrateur ;
- ou, **sans droits administrateur**, le télécharger localement dans le projet avec l'option
  `-LocalSdk` de l'étape 2. Les scripts utilisent automatiquement cette copie locale si elle est
  présente.

## 2. Télécharger les sources et appliquer les modifications

**Placez le projet dans un dossier au chemin court**, par exemple `C:\CS16`. Une bibliothèque du
moteur (mbedtls) contient des fichiers aux noms très longs ; dans un dossier profond, Windows
dépasse sa limite de 260 caractères et le téléchargement ou la compilation échoue. Le script
active `core.longpaths` pour git et vous avertit si le chemin est long.

Dans une invite PowerShell ouverte dans le dossier du projet :

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\setup_sources.ps1 -LocalSdk
```

Le script :
1. télécharge le moteur **Xash3D FWGS** et le client **cs16-client** (avec ses sous-projets :
   menus mainui, serveur ReGameDLL, bots) **aux versions exactes** testées ;
2. applique les trois patchs d'accessibilité de `patches\` sur une branche `accessibility-nvda` ;
3. télécharge **SDL2 2.32.10**, le **client contrôleur NVDA 2026.2** et, avec `-LocalSdk`, le SDK
   Windows depuis NuGet dans `tools\winsdk`.

Versions de référence :

| Projet | Commit |
|---|---|
| FWGS/xash3d-fwgs | 97cd12c4d4773db1231f52ef09cad56bb65aaea2 |
| Velaron/cs16-client | e30e27c3bd890f731ad7921d9c876d171aea4b32 |
| mainui_cpp (sous-module de cs16-client) | 6cb52ee726b8f0fb233be4fe01aad91037494e3e |

Vous préférez tout faire à la main ? L'équivalent :

```powershell
git clone https://github.com/FWGS/xash3d-fwgs repos\xash3d-fwgs
git -C repos\xash3d-fwgs checkout -b accessibility-nvda 97cd12c4d4773db1231f52ef09cad56bb65aaea2
git -C repos\xash3d-fwgs submodule update --init --recursive
git -C repos\xash3d-fwgs apply ..\..\patches\xash3d-fwgs.patch

git clone https://github.com/Velaron/cs16-client repos\cs16-client
git -C repos\cs16-client checkout -b accessibility-nvda e30e27c3bd890f731ad7921d9c876d171aea4b32
git -C repos\cs16-client submodule update --init --recursive
git -C repos\cs16-client apply ..\..\patches\cs16-client.patch
git -C repos\cs16-client\3rdparty\mainui_cpp apply ..\..\..\..\patches\mainui_cpp.patch
```

## 3. Compiler

```bat
tools\scripts\build_xash.bat configure
tools\scripts\build_velaron.bat
```

- `build_xash.bat` compile le **moteur** (`xash.dll`, `xash3d.exe`, rendu, système de fichiers)
  dans `repos\xash3d-fwgs\out`. Le mot `configure` n'est utile que la première fois ou après un
  changement d'outils.
- `build_velaron.bat` compile le **client** (`client.dll`), les **menus** (`menu.dll`), le
  **serveur** (`mp.dll`) et les données `extras.pk3` dans `repos\cs16-client\build-x86`.

Les scripts trouvent Visual Studio tout seuls. Pour en imposer un :
`set VSINSTALL=C:\Program Files\Microsoft Visual Studio\18\Community` avant de les lancer.

## 4. Assembler le jeu

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\assemble_game.ps1 `
    -Source "C:\Program Files (x86)\Steam\steamapps\common\Half-Life" `
    -Output "D:\Jeux\CS16_Accessible"
```

Le script **lit** votre installation sans la modifier, puis crée le dossier de sortie :
- copie `valve` et `cstrike` (cartes, sons, modèles) ;
- ajoute le moteur, le client, les menus et le serveur accessibles (les fichiers d'origine sont
  gardés sous les noms `client_original.dll` et `mp_original.dll`) ;
- installe NVDA Controller Client à côté du moteur et du client ;
- installe le profil `cstrike\access.cfg`, les traductions françaises (`resource\mainui_french.txt`,
  `titles.txt` ; l'original anglais devient `titles_english.txt`) ;
- règle le temps d'achat à 60 secondes dans `game.cfg` ;
- crée le raccourci `Counter-Strike accessible.lnk` (`xash3d.exe -game cstrike +ui_language french`).

Relancez avec `-Force` pour remplacer un dossier existant.

## 5. Vérifier

Lancez NVDA puis le raccourci : le menu principal doit être annoncé. Pour une vérification
automatique sans écouter, voir [05 — Tests automatisés](05-tests.md) :

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\menu_test.ps1 -GameDir "D:\Jeux\CS16_Accessible" `
    -StartupSeconds 20 -GameArgs "+maxplayers 4 +map de_dust2" -KeyList "2 5 F6 h F9"
```

## Partager le jeu avec quelqu'un

Donnez le dossier assemblé **sans** les données de Counter-Strike si la personne a sa propre copie :
elle lance `assemble_game.ps1` avec sa copie. Les données du jeu appartiennent à Valve ; ce projet
ne les redistribue pas.
