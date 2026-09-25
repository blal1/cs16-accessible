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
- les sous-groupes d'un écran (réglages du viseur…) font partie de la même liste : les flèches
  en sortent au bout, sans boucler ;
- **Lire le fichier Lisez-moi** ouvre `readme.txt` dans le Bloc-notes ; **Options de jeu** (dans
  Personnalisation) a plusieurs pages : le premier élément, « Page », change de page avec les flèches
  gauche et droite.

**Créer une partie contre des bots** : Menu principal → Multijoueur → Créer une partie. Choisissez
la carte dans la liste, puis validez. Une fois en jeu, ajoutez des bots depuis la console (voir
plus bas) avec `bot_add`, ou réglez leur nombre avec `bot_quota 5`.

**Jouer sur Internet** : Multijoueur → Partie sur Internet. Descendez jusqu'à la liste (après les
boutons), choisissez un serveur avec les flèches, Entrée pour le rejoindre. La ligne n'est pas
relue quand seuls le ping ou le nombre de joueurs changent. Pendant la connexion, le jeu dit
« Connexion à … », « Connecté, chargement », la progression des téléchargements toutes les
5 secondes, puis « Carte … ». À la déconnexion (ou si le serveur vous expulse) : « Déconnecté du
serveur », suivi de la raison quand le serveur en donne une.

Sur les serveurs : les menus des plugins (AMX, « /guns »…) sont lus comme les menus du jeu ; les
comptes à rebours affichés à l'écran ne sont lus que toutes les 10 secondes puis les 5 dernières ;
les codes couleur des pseudos (`^1`…) sont ignorés.

## En partie : les menus numérotés

Choix de l'équipe, de l'apparence, achat (touche B), radio : le menu est **lu en entier** dès qu'il
s'ouvre, par exemple « Choisissez une équipe. 1. Forces terroristes. 2. Forces antiterroristes… ».
Répondez avec les **touches numériques** ; 0 pour quitter le menu.

Le temps d'achat est réglé à 60 secondes (au lieu de 15) sur les parties que vous hébergez, pour
avoir le temps d'écouter les menus.

## Les touches d'accessibilité

| Touche | Ce qu'elle dit |
|---|---|
| F6 | santé, armure, argent, arme, balles dans le chargeur et en réserve ; mort ou spectateur : le joueur que vous regardez et votre argent (l'écran montre alors sa santé et ses armes, qui ne sont pas annoncées comme les vôtres) |
| F7 | répète la dernière annonce |
| F8 | coupe la parole |
| F3 | tableau des scores : d'abord vous (« Vous : 3 frags, 1 mort, 2e sur 10 »), puis équipes et joueurs |
| F4 | temps restant de la manche ; après la pose de la bombe : « Bombe posée depuis 12 secondes » |
| F9 / F10 | choisit la cible de guidage suivante / précédente (bombe, sites de bombe, otages, zones de sauvetage, points de départ) et dit sa distance et sa direction |
| F12 | arrête le guidage |
| F11 | où suis-je : votre orientation, le lieu (« couloir étroit, 2 mètres de large, dans l'axe nord, sud », « pièce », « grande zone ouverte »), la cible, les deux objectifs les plus proches |
| H | balayage radar autour de vous, puis résumé : « Ouvertures à 2 heures. Mur le plus proche à 9 heures, 2 mètres » |
| J | ennemis actuellement visibles, avec direction et distance |
| L | objets en vue (armes au sol, bombe, kit de désamorçage, otages) puis échelles et portes proches, avec direction et distance |
| I | boussole : « Face sud, 195 degrés » |
| O | relit le message du serveur ; si c'est une page web, l'ouvre dans le navigateur |
| P | description de la carte : mission, chaque objectif avec la distance à pied depuis votre départ et sa direction, otages, échelles, portes |
| V | guidage vers l'échelle la plus proche (même cloche que F9 ; F12 pour arrêter) |
| Début | se tourne vers la prochaine étape du guidage en cours : « Face sud, vers site de bombe ouest, avancez » |
| Retour arrière | tir secondaire (lunette, silencieux, coup de couteau fort) ; en spectateur : joueur précédent |

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
| carillon à deux notes | objet à ramasser en vue à moins de 10 mètres (arme, bombe, kit) ; plus aigu quand vous êtes dessus |
| double pas sourd | un ennemi **court** près de vous, hors de vue (le jeu fait entendre ses pas) |
| claquement avec un grondement | un ennemi tire, même hors de vue |
| trois clics montants | échelle proche (annoncée « Échelle, 2 heures, 4 mètres ») |
| toc-toc | porte proche (annoncée une fois) |
| coup sourd | votre tir a touché un ennemi ; plus aigu : à la tête |
| bulles | vous entrez dans l'eau (« Dans l'eau », « Sous l'eau », « Hors de l'eau ») |

Pour apprendre les sons, écoutez les fichiers de `analysis\sons\`.

Annonces de zones : « Vous entrez : site de bombe est », « Vous quittez : zone de sauvetage ouest ».

Lieux : en marchant, le jeu dit où vous êtes par rapport aux objectifs, d'après les distances à pied :
« Près du site de bombe ouest », « Entre le départ terroriste et le site de bombe est », « Au milieu de
la carte ». F11 le redit. Ces noms sont calculés pour toutes les cartes qui ont un fichier de navigation.

Combat : le premier ennemi qui apparaît est dit à voix haute (« Ennemi, 2 heures, 13 mètres, en
hauteur ») ; quand votre tir touche un ennemi, un coup sourd (plus aigu pour la tête) : c'est
l'équivalent du sang qu'un voyant voit, rien ne vise à votre place ;
chaque élimination dit combien il reste d'ennemis ou de coéquipiers en vie ; « Rechargé, 30 balles »
à la fin d'un rechargement, « Plus de munitions » quand l'arme est vide ; « Bombe posée sur le site
de bombe est » ; « Bombe lâchée, 8 mètres, 3 heures » (terroristes) ; « X parle » au chat vocal ;
« Ramassé : AK-47 » quand vous ramassez une arme au sol ; les icônes d'état (poison, radiation,
brûlure) et les icônes inconnues des serveurs moddés sont nommées ; une flash
dit « Aveuglé, 7 secondes » puis « Vue revenue » (pendant ce temps les ennemis ne sont plus
signalés comme vus, seulement entendus) ; poser ou désamorcer la bombe dit « Action en cours,
10 secondes, ne bougez pas », ou « Action interrompue ».

Annonces de terrain : « Montée » et « Descente » quand le sol monte ou descend devant vous
(escalier, rampe), « Sur l'échelle » / « Hors de l'échelle », « Bombe au sol en vue » la première
fois que vous la voyez.

**Spectateur** (mort ou équipe spectateur) : Entrée = joueur suivant, Retour arrière = joueur
précédent, Espace = changer de vue. Le jeu annonce qui vous regardez et son équipe ; F6 le redit.

**Équité** : un ennemi n'est signalé que si vous pourriez le voir à l'écran (ligne de vue dégagée),
ou l'entendre (pas de course, tirs) comme n'importe quel joueur.
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
| `access_hearing 0/1` | ennemis entendus hors de vue (pas de course, tirs) |
| `access_items 0/1` | carillon de l'objet le plus proche en vue |
| `access_features 0/1` | échelles, portes, eau, montées et descentes |
| `access_menu_mouse 0/1` | 0 : la souris ne peut pas déplacer la sélection des menus |
| `ui_language french` | langue du jeu et des menus |
