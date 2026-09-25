# Counter-Strike 1.6 accessible aux joueurs aveugles

Rendre Counter-Strike 1.6 **entièrement jouable sans la vue**, avec le lecteur d'écran
[NVDA](https://www.nvaccess.org) et des sons de repérage générés par le jeu.

- **Tous les écrans parlent** : menu principal, options, créer une partie, liste des serveurs,
  touches, dialogues, menu Échap, console, saisie du chat, menus d'équipe / d'achat / radio, HUD,
  messages de manche, tableau des scores.
- **Se repérer au son** : sonar des murs, vides et obstacles, balayage radar avec résumé parlé,
  guidage vers les objectifs le long du maillage de navigation des bots, boussole.
- **Combattre** : ennemis signalés seulement en ligne de vue (équité), tonalité de visée et clic
  quand le viseur est sur la cible, direction des dégâts, alertes de grenades, santé et munitions.
- **En français** : menus, messages du jeu et annonces.

Le projet s'appuie sur des logiciels libres, modifiés pour l'accessibilité :
[Xash3D FWGS](https://github.com/FWGS/xash3d-fwgs) (moteur),
[cs16-client](https://github.com/Velaron/cs16-client) (client CS, menus
[mainui_cpp](https://github.com/FWGS/mainui_cpp), serveur
[ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS)).

> Les **données du jeu** (cartes, sons, modèles) ne sont **pas** incluses : elles viennent de votre
> propre copie de Counter-Strike 1.6 (par exemple Steam). Un client modifié ne doit pas être utilisé
> sur des serveurs protégés par VAC.

## Démarrage

```powershell
# dans un dossier au chemin court, par exemple C:\CS16
git clone https://github.com/blal1/cs16-accessible C:\CS16
cd C:\CS16
powershell -ExecutionPolicy Bypass -File tools\scripts\setup_sources.ps1 -LocalSdk
tools\scripts\build_xash.bat configure
tools\scripts\build_velaron.bat
powershell -ExecutionPolicy Bypass -File tools\scripts\assemble_game.ps1 `
    -Source "C:\Program Files (x86)\Steam\steamapps\common\Half-Life" -Output C:\Jeux\CS16
```

Puis lancez NVDA et `C:\Jeux\CS16\Counter-Strike accessible.lnk`.
Prérequis et détails : [docs/02-installation-depuis-zero.md](docs/02-installation-depuis-zero.md).

## Documentation

| Document | Contenu |
|---|---|
| [01 — Guide du joueur](docs/01-guide-du-joueur.md) | menus, touches, les 19 sons, console, chat, réglages |
| [02 — Installation depuis zéro](docs/02-installation-depuis-zero.md) | prérequis, versions, compilation, assemblage |
| [03 — Architecture](docs/03-architecture.md) | comment moteur, menus et jeu parlent à NVDA |
| [04 — Étendre et personnaliser](docs/04-etendre-et-personnaliser.md) | ajouter un son, une annonce, une touche, une traduction |
| [05 — Tests automatisés](docs/05-tests.md) | journal de parole, pilote de clavier, scénarios avec bots |
| [06 — Méthode : rendre un jeu accessible](docs/06-methode-rendre-un-jeu-accessible.md) | la démarche pour **n'importe quel jeu**, et les pièges rencontrés |
| [07 — Dépannage](docs/07-depannage.md) | problèmes fréquents |
| [accessibility-design.md](docs/accessibility-design.md) | référence technique détaillée (anglais) |

## Contenu du dépôt

```
docs/            documentation
patches/         modifications d'accessibilité (xash3d-fwgs, cs16-client, mainui_cpp)
distribution/    fichiers ajoutés au jeu : access.cfg, traductions françaises, NVDA Controller Client
tools/scripts/   téléchargement des sources, compilation, assemblage, tests, décompilation Ghidra
tools/tests/     configurations de test (bots, visée, grenades)
tools/navtools/  test des cartes et du guidage + analyseurs Python .nav / .bsp
tools/audiotest/ test du moteur de sons
analysis/sons/   les 19 sons au format WAV, pour les apprendre
```

## État et limites connues

Vérifié automatiquement (journal de ce qui est envoyé à NVDA + touches envoyées au jeu) : tous les
menus parcourus, les menus en jeu, le HUD, la console, le chat, les sons de déplacement, une partie
contre des bots (ennemis, dégâts, visée, grenades), et la reconstruction complète depuis un dossier
vide. Détails dans [docs/05-tests.md](docs/05-tests.md).

- Les cartes sans titre affichent encore « No Title » en anglais, un texte qui vient du moteur.
- Surtout, **aucun joueur aveugle ne l'a encore essayé** : c'est le test qui manque. Les retours
  sont les bienvenus (onglet *Issues*).

## Licences

- Ce dépôt (code d'accessibilité, patchs, scripts, documentation) est publié sous
  **GNU GPL v3 ou ultérieure** : voir [LICENSE](LICENSE). Elle est compatible avec les projets
  modifiés (Xash3D FWGS : GPL v3+ ; cs16-client et mainui_cpp : GPL v2+).
- `distribution/engine/nvdaControllerClient.dll` : NV Access, LGPL 2.1 (licence jointe).
- Counter-Strike et Half-Life sont des marques de Valve ; aucun fichier de Valve n'est inclus en
  dehors de traductions de textes de menus.
