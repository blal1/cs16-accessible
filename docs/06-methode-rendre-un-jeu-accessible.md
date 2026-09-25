# 06 — Méthode : rendre un jeu accessible aux joueurs aveugles

Ce document généralise ce qui a été fait pour Counter-Strike 1.6. Il s'adresse à quelqu'un qui veut
rendre accessible **un autre jeu** et suit l'ordre réel du travail, avec les pièges rencontrés.

## 0. Ce que « entièrement accessible » veut dire

Un joueur aveugle doit pouvoir, sans aide voyante :
1. **lancer** le jeu et **utiliser tous les écrans** au clavier : menus, options, dialogues,
   console, saisie de texte ;
2. **savoir ce qui se passe** : état du personnage, messages, résultats ;
3. **se déplacer** : murs, vides, obstacles, directions, objectifs ;
4. **agir** : trouver et viser ce qu'il faut, réagir aux dangers ;
5. **ne jamais rester dans le silence** : toute touche produit une réponse, même « impossible
   maintenant ».

Deux canaux, chacun pour ce qu'il fait le mieux :
- la **parole** (lecteur d'écran) pour les faits discrets : textes, nombres, menus ;
- des **sons** pour l'espace et le temps réel : directions, distances, alertes.

## 1. Identifier ce qu'on a

- **Installeur** : l'ouvrir sans l'exécuter. `innoextract` (Inno Setup), 7-Zip (NSIS, archives,
  la plupart des autres). Pour CS 1.6 : Inno Setup, 5 090 fichiers extraits.
- **Binaires** : pour chaque `.exe` / `.dll`, regarder date, sections, entropie, imports et exports
  (Python + `pefile`). Une section d'entropie proche de 8 ou aux noms étranges signale un binaire
  compressé ou protégé, inutile à décompiler tel quel.
- **Chaînes de caractères** : elles révèlent souvent l'origine exacte. Le `mp.dll` du jeu contenait
  « ReGameDLL version 5.23.0.620-dev, commit ac07e89 » : son code source exact était disponible.
- **Moteur** : Unity, Unreal, GoldSrc, Source, Godot… change toute la stratégie (outils de mod,
  réimplémentations, SDK).

## 2. Chercher du code ouvert avant de décompiler

Par ordre de préférence :

| Situation | Approche | Exemple |
|---|---|---|
| moteur et jeu réimplémentés en libre | modifier les sources | **CS 1.6 : Xash3D FWGS + cs16-client + mainui** (choix final) |
| SDK officiel ou client réimplémenté, moteur fermé | modifier la partie ouverte | CS 1.6 Steam + client FuryBaM (première version, abandonnée) |
| mods / scripts officiels | greffon (Lua, C#, BepInEx, MelonLoader…) | jeux Unity, Minecraft… |
| rien d'ouvert | DLL intercalée (proxy), hooks, lecture mémoire | dernier recours |

**Leçon principale de ce projet** : la première version, sur le moteur fermé de Valve, rendait
accessible tout le jeu **sauf** le menu principal, les options, la console et la saisie du chat,
parce qu'ils vivent dans `GameUI.dll`, une bibliothèque fermée. Passer à un moteur entièrement libre
compatible (Xash3D) a résolu les quatre d'un coup. **Vérifiez tôt qui dessine chaque écran** et si
vous pouvez modifier ce code.

Sources utiles pour ce type de jeu : les index de réimplémentations (HLSources pour GoldSrc), les
listes de mods supportés par les moteurs libres (`Documentation/supported-mod-list.md` de Xash3D).

## 3. Décompiler quand il le faut

- **Ghidra en mode automatique** (`analyzeHeadless`) avec un script qui exporte toutes les fonctions
  décompilées, les imports / exports et les chaînes avec les fonctions qui les utilisent
  (`tools\scripts\ExportDecompiled.java`, `run_decompile.sh`).
- **Faire correspondre** les exports d'un binaire fermé avec une réimplémentation ouverte : ici
  83 exports sur 88 du `client.dll` de Valve ont été retrouvés dans le code libre
  (`analysis\client_exports_map.md`). La décompilation sert alors de **référence de comportement**,
  pas de code à maintenir.

## 4. La couche de parole

- **API** : NVDA fournit `nvdaControllerClient.dll` (`nvdaController_speakText`,
  `nvdaController_cancelSpeech`). Pour viser aussi JAWS et la synthèse Windows (SAPI), la
  bibliothèque libre *Tolk* regroupe plusieurs lecteurs.
- **Chargement dynamique** (`LoadLibrary`) : le jeu doit fonctionner, muet, sans le lecteur.
- **Un seul petit module partagé** (`access_tts.c`) par toutes les parties du jeu (moteur, menus,
  client), sans dépendance au moteur, facile à copier.
- **Encodage** : les jeux manipulent de l'UTF-8 ou une page de code ; convertir en UTF-16 avec
  repli sur la page ANSI.
- **Interrompre ou mettre en file** : un changement de focus coupe l'annonce précédente ; un
  message de chat s'ajoute à la file.
- **Regrouper les rafales** : la santé qui baisse à chaque balle ne doit pas produire dix
  annonces ; annoncer la valeur finale après 400 ms de stabilité.
- **Nettoyer le texte** : codes couleur (`^1`, octets 0x01–0x04), codes de mise en forme des menus
  (`\y \w \r \R`), HTML des messages de serveur, espaces multiples. Un code « alignement à droite »
  devient une virgule, sinon « Sidearm400 » est lu comme un seul mot.

## 5. Rendre les interfaces accessibles

**Observer l'état plutôt qu'instrumenter chaque contrôle.** À chaque image : quelle fenêtre est
active, quel élément a le focus clavier, quelle est sa description (nom, type, valeur). Annoncer ce
qui a changé. Un seul module couvre toutes les fenêtres, présentes et futures, et les changements
provoqués par la souris ou par le jeu.

Pièges réels, dans l'ordre où ils sont apparus :

| Symptôme | Cause | Solution |
|---|---|---|
| titre annoncé sans élément | pendant l'animation d'ouverture, les boutons ne sont pas encore actifs | attendre (jusqu'à quelques centaines de ms) un élément focalisable |
| une fenêtre se ferme toute seule | le programme déplaçait le focus sur un bouton à l'ouverture ; la touche Entrée qui avait ouvert la fenêtre, encore enfoncée, l'activait au relâchement | ne jamais déplacer le focus à l'ouverture d'une fenêtre |
| annonces qui s'enchaînent sans raison | un pointeur de souris immobile au-dessus d'un bouton reprend le focus quand une fenêtre s'ouvre | option qui neutralise la souris (pointeur hors écran) |
| « bouton » sans nom, ou rien d'annoncé | bannières, images et fonds sont atteignables au clavier | les ignorer ; si les flèches s'y arrêtent, passer au suivant |
| liste déroulante sans nom | le libellé est un texte séparé posé à côté, ou n'existe pas du tout | prendre le texte statique qui précède le contrôle ; sinon lui donner un nom dans le code |
| focus déplacé au démarrage | le menu remet son pointeur au centre de l'écran, sur un bouton | replacer le pointeur hors écran à chaque initialisation |
| menu « bloqué » en fin de liste | en revenant au début, le saut des décorations se trompait de sens | un saut de plus d'une demi-liste est un retour au début |
| titres de fenêtre absents | le titre est une image | table « classe de fenêtre → titre » |
| un contrôle ne marche qu'à la souris | conçu pour la souris | lui ajouter des touches (ici : Entrée fait défiler les onglets) |
| clignotement du focus | animations | n'annoncer qu'après 80 ms de stabilité |
| saisie de texte muette | le champ n'est pas un contrôle Windows | comparer le texte et le curseur d'une image à l'autre : caractère tapé, effacé, caractère sous le curseur |

Pour les menus numérotés en jeu, souvent disponibles en version texte et en version graphique,
**forcer la version texte** (ici `_vgui_menus 0`) : elle se lit d'un bloc et se commande par chiffres.

## 6. Rendre le monde 3D perceptible

### Une grammaire sonore unique

Tous les sons obéissent aux mêmes règles, apprises une fois :
- panoramique gauche/droite = direction par rapport au regard ;
- **étouffé = derrière** (filtre passe-bas), sinon l'avant et l'arrière se confondent au casque ;
- plus aigu = au-dessus ou plus proche ;
- répétition plus rapide = plus proche ou plus urgent ;
- **un sens par timbre**, sans ambiguïté possible avec les sons du jeu.

### Que sonoriser (et comment)

| Besoin | Technique utilisée | Données |
|---|---|---|
| murs proches | sonar : 6 rayons en rotation, un par 45 ms, seulement en mouvement | tracés de collision du moteur |
| vides et marches | rayon vers le bas devant les pieds, dans la direction du déplacement | tracés |
| forme de la pièce | balayage de 24 rayons sur demande + résumé parlé (« ouvertures à 2 heures ») | tracés |
| aller quelque part | chemin A* sur le **maillage de navigation des bots**, balise sur le point le plus lointain encore visible | fichier `.nav`, entités de la carte |
| objectifs | entités de la carte (sites de bombe, otages, zones) | bloc d'entités du `.bsp` |
| ennemis | seulement **en ligne de vue** ; les 3 plus proches ; rythme selon la distance | entités, tracés |
| viser | tonalité dont la hauteur monte quand l'angle diminue, clic quand le viseur est sur la cible | angle vue → torse |
| dangers | grenades (trajectoire), dégâts (direction du tir), santé basse, chargeur vide | messages du serveur, entités |

Les maillages de navigation des bots et les entités des cartes existent dans beaucoup de jeux : ce
sont des sources précieuses pour la navigation, sans rien dessiner.

### Synthèse et moteur audio

- Sons **synthétisés** au démarrage (sinus, bruit filtré, glissandos, enveloppes) : pas de fichiers,
  réglages faciles, timbres contrôlés.
- Moteur audio indépendant du jeu (ici XAudio2) sur **son propre fil d'exécution**.
- Éviter la cacophonie : priorités, limites (3 ennemis), silence pendant la lecture d'un menu.

### Équité

Ne donner que l'information qu'un joueur voyant a à l'écran (ligne de vue), ne jamais viser ni
tirer à la place du joueur, et respecter les règles anti-triche : un client modifié ne doit pas être
utilisé sur des serveurs protégés.

## 7. Langue et formulation

- Traduire **toutes** les sources de texte : menus, messages du jeu, messages du serveur, et les
  annonces de l'accessibilité elles-mêmes.
- Vérifier **quand** le jeu charge sa langue : ici le client la lisait avant la configuration de
  l'utilisateur ; il faut recharger quand la variable change.
- Directions en **heures d'horloge** (12 devant, 3 à droite), distances en **mètres**, points
  cardinaux pour la carte ; accords corrects (« 1 heure », « 3 heures »).
- Laisser plus de temps quand un menu doit être écouté (ici le temps d'achat passe de 15 à 60 s).

## 8. Tester sans voir

- **Journal de parole** : chaque phrase envoyée au lecteur est aussi écrite dans un fichier
  (variable `ACCESS_TTS_LOG`), avec des lignes de diagnostic (fenêtres, sons et leur position).
- **Pilote de clavier** : envoyer les touches **à la fenêtre du jeu** (`PostMessage`), pas au premier
  plan ; attendre que la fenêtre existe ; chemins absolus.
- **Scénarios reproductibles** : bots configurés (figés pour la visée, limités aux grenades…).
- **Tests unitaires hors jeu** pour les analyseurs de fichiers et le moteur audio.
- **Reproduction complète dans un dossier vierge** : c'est elle qui a révélé les chemins trop longs
  et deux bugs de scripts.
- Puis **des joueurs aveugles** : rien ne remplace leurs retours.

## 9. Pièges techniques rencontrés (Windows, C/C++)

| Problème | Solution |
|---|---|
| pas de SDK Windows et pas de droits administrateur | paquets NuGet `Microsoft.Windows.SDK.CPP(.x86)` extraits localement |
| `windows.h` en conflit avec les en-têtes du moteur (`HSPRITE`) | isoler tout le code Windows dans un fichier C séparé |
| XAudio2 : `CO_E_NOTINITIALIZED` | fil d'exécution dédié qui initialise COM (MTA) |
| touches du jeu par position physique | documenter AZERTY / QWERTY |
| chemins trop longs (sous-modules) | dossier court, `git -c core.longpaths=true` |
| PowerShell ne distingue pas les majuscules | une fonction `Git` s'appelle elle-même ; un paramètre `$patches` masque `$Patches` : noms distincts |
| scripts PowerShell avec accents | enregistrer en UTF-8 **avec BOM** pour Windows PowerShell 5 |
| commande qui ne fait rien en silence | toujours annoncer pourquoi |

## 10. Liste de contrôle finale

- [ ] Chaque écran s'ouvre au clavier et annonce son titre et l'élément sélectionné
- [ ] Chaque contrôle annonce son nom, son type, sa valeur, et sa nouvelle valeur quand elle change
- [ ] Les zones de texte répètent la saisie
- [ ] Console et chat utilisables
- [ ] État du joueur disponible sur demande (une touche)
- [ ] Messages du jeu lus, sans codes de mise en forme
- [ ] Murs, vides, obstacles perceptibles
- [ ] Guidage vers chaque objectif
- [ ] Ennemis, visée, dangers perceptibles, avec une règle d'équité claire
- [ ] Aucune touche sans réponse
- [ ] Langue du joueur partout
- [ ] Tests automatisés + reproduction depuis zéro + retours de joueurs aveugles
