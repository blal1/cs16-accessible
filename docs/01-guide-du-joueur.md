# 01 — Guide du joueur

## Avant de commencer

- **NVDA** doit être lancé avant le jeu (version 2024 ou plus récente ; testé avec 2026.2).
- **Un casque stéréo** est fortement conseillé : la gauche et la droite des sons portent l'information.
- Lancez `Counter-Strike accessible.lnk` dans le dossier du jeu.

## Les menus

Tous les menus parlent : menu principal, options, créer une partie, liste des serveurs, touches,
fenêtres de confirmation, menu Échap en cours de partie.

| Touche | Action |
|---|---|
| Flèche bas / haut, Tab | élément suivant / précédent |
| Entrée | valider, cocher une case, ouvrir une liste |
| Flèche gauche / droite | changer une valeur (curseur de volume, sélecteur) |
| Échap | revenir à la fenêtre précédente |

Ce que vous entendez :
- à l'ouverture d'une fenêtre : son **titre**, puis l'élément sélectionné ;
- pour chaque élément : son **nom**, son **type** (bouton, case à cocher, curseur, liste, zone de
  texte), sa **valeur** (« cochée », « 60 pour cent ») et une aide courte ;
- quand vous changez une valeur : **seulement la nouvelle valeur** ;
- dans une zone de texte : chaque lettre tapée, « effacé » quand vous effacez, la lettre sous le
  curseur quand vous le déplacez ;
- dans une liste (serveurs, cartes, touches) : « ligne 3 sur 20 », puis le contenu des colonnes ;
- « indisponible » pour un élément grisé.

**Créer une partie contre des bots** : Menu principal → Multijoueur → Créer une partie. Choisissez
la carte dans la liste, puis validez. Une fois en jeu, ajoutez des bots depuis la console (voir
plus bas) avec `bot_add`, ou réglez leur nombre avec `bot_quota 5`.

## En partie : les menus numérotés

Choix de l'équipe, de l'apparence, achat (touche B), radio : le menu est **lu en entier** dès qu'il
s'ouvre, par exemple « Choisissez une équipe. 1. Forces terroristes. 2. Forces antiterroristes… ».
Répondez avec les **touches numériques** ; 0 pour quitter le menu.

Le temps d'achat est réglé à 60 secondes (au lieu de 15) sur les parties que vous hébergez, pour
avoir le temps d'écouter les menus.

## Les touches d'accessibilité

| Touche | Ce qu'elle dit |
|---|---|
| F6 | santé, armure, argent, arme, balles dans le chargeur et en réserve |
| F7 | répète la dernière annonce |
| F8 | coupe la parole |
| F3 | tableau des scores (équipes, joueurs, frags, morts) |
| F4 | temps restant de la manche |
| F9 / F10 | choisit la cible de guidage suivante / précédente (bombe, sites de bombe, otages, zones de sauvetage, points de départ) et dit sa distance et sa direction |
| F12 | arrête le guidage |
| F11 | où suis-je : votre orientation, la cible, les deux objectifs les plus proches |
| H | balayage radar autour de vous, puis résumé : « Ouvertures à 2 heures. Mur le plus proche à 9 heures, 2 mètres » |
| J | ennemis actuellement visibles, avec direction et distance |
| I | boussole : « Face sud, 195 degrés » |
| O | relit le message du serveur |

Les directions sont données **comme une horloge** : 12 heures = devant, 3 heures = à droite,
6 heures = derrière, 9 heures = à gauche. Les distances sont en mètres.

### Déplacement

Les touches de jeu suivent la **position des touches d'un clavier QWERTY**. Sur un clavier AZERTY :
Z avancer, S reculer, Q pas à gauche, D pas à droite ; flèches gauche et droite pour tourner ;
radio W, X et C. Les touches d'accessibilité ci-dessus sont au même endroit sur les deux claviers.

## Les sons

Règle commune à tous les sons :
- **gauche / droite** : la direction de la chose par rapport à votre regard ;
- **son étouffé** : la chose est **derrière** vous ;
- **plus aigu** : au-dessus de vous, ou plus proche ;
- **répétition plus rapide** : plus proche ou plus urgent.

| Son | Signification |
|---|---|
| tapotement | mur proche sur le côté ; plus fort et plus aigu quand il est tout près |
| tapotement avec une note | mur juste devant |
| glissando descendant | vide devant vous ; plus grave si la chute est profonde (et « chute dangereuse » au-delà de 5 mètres) |
| glissando montant | obstacle bas que l'on peut sauter |
| cloche | direction du guidage : suivez-la ; elle accélère quand vous approchez |
| marimba | la bombe (quand la cible est la bombe) |
| arpège montant | vous êtes arrivé à la cible |
| bip de balayage | radar (H) : aigu = mur proche, grave = mur loin |
| souffle | radar (H) : espace ouvert, couloir, porte |
| blip montant | un ennemi vient d'apparaître dans votre champ de vision |
| bourdonnement à deux tons | ennemi visible (les trois plus proches) |
| bip de visée | votre viseur s'approche d'un ennemi : plus aigu et plus rapide quand vous êtes proche |
| clic brillant | le viseur est sur l'ennemi : tirez |
| coup sourd | vous êtes touché ; il vient de la direction du tir |
| crépitement | grenade qui vole près de vous (le type est annoncé : explosive, flash, fumigène) |
| double battement | santé inférieure à 25 |
| double clic sec | chargeur presque vide |
| petit tic en bois | votre vue passe par le nord |
| blip doux | coéquipier proche |

Pour apprendre les sons, écoutez les fichiers de `analysis\sons\`.

**Équité** : un ennemi n'est signalé que si vous pourriez le voir à l'écran (ligne de vue dégagée).
Rien ne vise ou ne tire à votre place.

## Console et chat

- **Chat** : Y (tous) ou U (équipe). Vous entendez « Message à tous », puis chaque lettre tapée ;
  Entrée : « Message envoyé » ; Échap : « Message annulé ». Les messages reçus sont lus.
- **Console** : touche au-dessus de Tab (² sur AZERTY). « Console » à l'ouverture ; chaque lettre ;
  flèches haut et bas pour l'historique ; Tab pour compléter ; les réponses sont lues ;
  « Console fermée » en sortant.

## Réglages

Tout se règle dans `cstrike\access.cfg` (fichier texte commenté), ou dans la console :

| Réglage | Effet |
|---|---|
| `access_speech 0/1` | toute la parole |
| `access_speech_chat`, `access_speech_kills`, `access_speech_hints`, `access_speech_timer`, `access_speech_aimtarget` | catégories d'annonces |
| `access_cues 0/1` | tous les sons |
| `access_cue_volume 0.8` | volume des sons (0 à 2) |
| `access_sonar 0/1/2` | murs : jamais / en mouvement / toujours |
| `access_sonar_range 128` | portée du sonar (128 ≈ 3 mètres) |
| `access_enemy_fov 360` | 120 = n'entendre que les ennemis devant vous |
| `access_aim_cone 30` | angle à partir duquel le bip de visée commence |
| `access_menu_mouse 0/1` | 0 : la souris ne peut pas déplacer la sélection des menus |
| `ui_language french` | langue du jeu et des menus |
