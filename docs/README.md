# Counter-Strike 1.6 accessible aux joueurs aveugles

Ce projet rend Counter-Strike 1.6 jouable sans la vue, avec le lecteur d'écran NVDA et des sons
de repérage générés par le jeu. Tout est lu : menu principal, options, console, chat, menus
d'équipe et d'achat, HUD, messages de manche. Des sons indiquent les murs, les vides, la direction
à suivre, les ennemis visibles, la visée, les grenades et les dégâts.

Il repose sur des logiciels libres existants, modifiés pour l'accessibilité :

| Composant | Rôle | Projet d'origine |
|---|---|---|
| Moteur | fait tourner le jeu, console, chat | [Xash3D FWGS](https://github.com/FWGS/xash3d-fwgs) |
| Client CS | HUD, armes, menus en jeu | [cs16-client de Velaron](https://github.com/Velaron/cs16-client) |
| Menus | menu principal, options, serveurs | [mainui_cpp](https://github.com/FWGS/mainui_cpp) (version fournie avec cs16-client) |
| Serveur | règles du jeu, bots | [ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS) (fourni avec cs16-client) |
| Parole | envoie le texte à NVDA | [NVDA Controller Client](https://www.nvaccess.org/) |

Les **données du jeu** (cartes, sons, modèles) ne sont pas fournies : elles viennent de votre propre
copie de Counter-Strike 1.6 (par exemple celle de Steam).

## Par où commencer

| Vous voulez… | Lisez |
|---|---|
| jouer | [01 — Guide du joueur](01-guide-du-joueur.md) |
| installer le projet sur un autre PC, à partir de zéro | [02 — Installation depuis zéro](02-installation-depuis-zero.md) |
| comprendre comment c'est construit | [03 — Architecture](03-architecture.md) |
| ajouter un son, une annonce, une traduction, régler le comportement | [04 — Étendre et personnaliser](04-etendre-et-personnaliser.md) |
| vérifier que tout marche après une modification | [05 — Tests automatisés](05-tests.md) |
| rendre accessible un **autre** jeu avec la même méthode | [06 — Méthode : rendre un jeu accessible](06-methode-rendre-un-jeu-accessible.md) |
| résoudre un problème | [07 — Dépannage](07-depannage.md) |

Référence technique détaillée (en anglais) : `repos\cs16-client\docs\accessibility-design.md`.

## Démarrage rapide (le jeu est déjà assemblé)

1. Lancez NVDA.
2. Ouvrez `CS16_Xash\Counter-Strike accessible.lnk`.
3. Le menu principal est annoncé : flèches haut et bas pour naviguer, Entrée pour valider,
   Échap pour revenir.

## Contenu du dossier

```
CS16_Accessible\
  CS16_Xash\          le jeu jouable (dossier assemblé)
  docs\               cette documentation
  patches\            les modifications d'accessibilité, à appliquer aux projets d'origine
  distribution\       fichiers ajoutés au jeu : profil access.cfg, traductions françaises, NVDA
  tools\scripts\      scripts : téléchargement, compilation, assemblage, tests
  tools\tests\        configurations de test (bots, grenades, visée)
  repos\              sources (créé par setup_sources.ps1)
  analysis\sons\      les 26 sons au format WAV, pour les apprendre
```
