# 03 — Architecture

## Vue d'ensemble

Le jeu tourne dans un seul processus Windows, `xash3d.exe`, qui charge trois bibliothèques
modifiées. Chacune rend accessible ce qu'elle affiche :

```
xash3d.exe
 ├─ xash.dll ........ moteur        → console, saisie du chat
 │    engine/client/accessibility/con_access.c
 ├─ cstrike/cl_dlls/menu.dll ...... menus → toutes les fenêtres de menu
 │    3rdparty/mainui_cpp/menu_access.cpp
 └─ cstrike/cl_dlls/client.dll .... jeu   → HUD, menus numérotés, sons de repérage et de combat
      cl_dll/accessibility/*
Les trois utilisent access_tts.c pour parler à NVDA (nvdaControllerClient.dll).
```

Le serveur (`cstrike/dlls/mp.dll`, ReGameDLL) n'est pas modifié ; seul son réglage de temps d'achat
change (`game.cfg`).

## La parole : `access_tts`

Un petit fichier C (`access_tts.c/.h`) partagé par les trois bibliothèques :
- charge `nvdaControllerClient.dll` au premier besoin, d'abord à côté de la bibliothèque qui parle,
  puis dans le chemin de recherche normal : **le jeu marche aussi sans NVDA**, simplement muet ;
- `AccessTts_Speak(texte_utf8, interruption)` convertit en UTF-16 et appelle
  `nvdaController_speakText` (et `nvdaController_cancelSpeech` si l'annonce doit couper la
  précédente) ;
- si la variable d'environnement `ACCESS_TTS_LOG` contient un chemin de fichier, chaque phrase y est
  aussi écrite : c'est la base des [tests automatisés](05-tests.md).

Le même fichier est copié dans les trois projets (il ne dépend d'aucun en-tête du moteur).

## Les menus : observer plutôt qu'instrumenter

`menu_access.cpp` ne modifie aucun contrôle du menu. À chaque image, il regarde :
1. **quelle fenêtre** est au premier plan (pile `uiStatic.menu`, ou `uiStatic.client` en jeu) ;
2. **quel élément** a le curseur clavier (en descendant dans les conteneurs imbriqués) ;
3. **sa description** : nom, type (déduit de la classe : bouton, case, curseur, liste…), valeur.

Toute différence avec l'image précédente est annoncée : nouvelle fenêtre (titre + élément),
déplacement du focus (description complète), changement de valeur (valeur seule), modification
d'une zone de texte (caractère tapé, effacé, sous le curseur).

Pourquoi cette approche : elle couvre d'un coup **toutes** les fenêtres existantes et futures, les
changements faits à la souris ou par le jeu lui-même, et ne touche pas au code des contrôles.

Règles ajoutées après les tests :
- **stabilité** : un changement de focus n'est annoncé qu'après 80 ms sans nouveau changement
  (sinon les animations produisent des annonces parasites) ;
- **décorations** : bannières et images sont sautées ; si les flèches s'y arrêtent, le focus passe
  à l'élément suivant ;
- **jamais de focus forcé à l'ouverture d'une fenêtre** : les boutons s'activent quand la touche
  est *relâchée* ; la touche Entrée qui a ouvert la fenêtre est encore enfoncée, et déplacer le
  focus sur un bouton le déclencherait ;
- **souris neutralisée** (`access_menu_mouse 0`) : le pointeur du menu est placé hors de l'écran,
  sinon un pointeur oublié au-dessus d'un bouton vole le focus ;
- **libellés** : un contrôle sans nom prend le texte statique qui le précède (disposition
  « libellé : contrôle ») ; quand il n'existe aucun libellé visible (filtres du navigateur de
  serveurs), le contrôle reçoit un nom dans le code (`szName`, non affiché par les listes
  déroulantes) ;
- **pointeur à l'initialisation** : le menu replace son pointeur au centre de l'écran à chaque
  initialisation vidéo, souvent sur un bouton ; il est aussitôt remis hors écran ;
- **titres** : les fenêtres n'ont pas de titre textuel (c'est une image), d'où une table
  classe → titre français dans `KnownTitle()`.

Petites modifications aux contrôles : des accesseurs en lecture seule (valeur d'un curseur, texte
d'un sélecteur, curseur d'une zone de texte, ligne d'un tableau…), et le sélecteur à onglets
`CMenuSwitch`, qui ne se changeait qu'à la souris, défile maintenant avec Entrée.

## La console et le chat : `con_access.c`

Même principe dans le moteur : à chaque image (`Con_RunConsole`), comparaison de l'état
(`cls.key_dest`, contenu et curseur des champs `con.input` / `con.chat`). Deux points d'accroche
supplémentaires : chaque ligne ajoutée à la console (lue seulement quand la console est ouverte) et
l'envoi d'un message de chat.

## Le jeu : `cl_dll/accessibility/`

| Fichier | Rôle |
|---|---|
| `access_speech.cpp` | annonces du HUD (santé, armure, argent, arme, zones), chat, radio, messages centraux, menus numérotés, frags ; regroupement des rafales ; `access_status` ; exécution de `access.cfg` ; rechargement de la langue |
| `access_screens.cpp` | tableau des scores, minuterie, MOTD (HTML nettoyé), textes d'aide, joueur visé, spectateur, fin de partie |
| `access_audio.cpp` | synthèse des 26 sons au démarrage et lecture spatialisée avec XAudio2 |
| `access_map.cpp` | lecture des objectifs dans le fichier `.bsp` et du maillage de navigation des bots (`.nav`) ; recherche de chemin A* |
| `access_nav.cpp` | à chaque image : sonar, vides, balayage radar, guidage, ennemis, visée, grenades, dégâts, battements de cœur, boussole |

Les points d'accroche dans le code d'origine sont des **appels d'une ligne** placés dans les
fonctions qui reçoivent les messages du serveur (`MsgFunc_Health`, `MsgFunc_ShowMenu`,
`MsgFunc_DeathMsg`…) et dans `HUD_Init`, `HUD_Frame`, `HUD_Redraw`, `HUD_Shutdown`. La liste
complète est dans `patches\cs16-client.patch`.

### Les sons

- Tous synthétisés en mémoire au démarrage (sinus, bruit filtré, glissandos, enveloppes) : aucun
  fichier son.
- XAudio2 (fourni avec Windows 10/11) tourne sur **son propre fil d'exécution**, parce que sa sortie
  audio exige COM, et que le fil principal appartient au moteur.
- Spatialisation : panoramique gauche/droite à puissance constante selon l'angle ; filtre
  passe-bas + légère baisse de hauteur quand la source est derrière ; hauteur +/− une demi-octave
  selon l'élévation ; volume selon la distance.

### La carte

- **Objectifs** : lus dans le bloc d'entités du `.bsp` (`func_bomb_target`, `hostage_entity`,
  `info_player_start`…) ; les zones sont des brush models dont on prend le centre.
- **Noms** : les cartes ne disent pas quel site est A ou B ; avec deux sites, ils sont nommés selon
  l'axe qui les sépare le plus (« site de bombe est / ouest »).
- **Navigation** : le fichier `.nav` des bots (format version 5 de CS 1.6) fournit des zones
  praticables et leurs connexions. A* calcule un chemin ; les points de passage sont les milieux des
  bords communs entre zones. La balise sonore se place sur le point le plus lointain encore en ligne
  de vue, pour contourner les murs. Si la cible est dans une partie du maillage inaccessible, le
  chemin mène à la zone accessible la plus proche.

### Équité

Un ennemi n'est signalé que si un tracé entre vos yeux et son torse ou sa tête ne rencontre aucun
obstacle : c'est l'information qu'un joueur voyant aurait à l'écran. `access_enemy_fov` limite en
plus à un angle devant soi.

## Données ajoutées au jeu (`distribution\`)

| Fichier | Rôle |
|---|---|
| `cstrike\access.cfg` | touches et réglages d'accessibilité |
| `cstrike\resource\mainui_french.txt` | 394 textes du menu en français |
| `cstrike\titles_french.txt` | menus numérotés et messages en français (installé comme `titles.txt`) |
| `engine\nvdaControllerClient.dll` | pont vers NVDA (NV Access, licence LGPL, voir le fichier de licence) |
