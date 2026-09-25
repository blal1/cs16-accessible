# 07 — Dépannage

## Le jeu ne parle pas

1. **NVDA est-il lancé ?** Il doit tourner avant le jeu.
2. **`nvdaControllerClient.dll`** doit se trouver à côté de `xash3d.exe` **et** dans
   `cstrike\cl_dlls\` (version **x86**, 32 bits).
3. Ouvrez la console (touche au-dessus de Tab) et cherchez `[access]` :
   - « nvdaControllerClient.dll introuvable » : voir le point 2 ;
   - « NVDA ne répond pas » : relancez NVDA.
4. `access_speech 1` dans la console (la parole a peut-être été coupée).
5. Pour savoir ce que le jeu essaie de dire, lancez-le avec un journal :
   `set ACCESS_TTS_LOG=C:\temp\parole.txt` puis `xash3d.exe -game cstrike` depuis la même invite.

## Aucun son de repérage

- `access_cues 1` et `access_cue_volume 0.8` dans la console.
- « XAudio2 indisponible » dans la console : Windows 10 ou plus récent est nécessaire
  (`xaudio2_9.dll`).
- Les sons sont volontairement **coupés** tant que vous n'êtes pas en jeu (choix d'équipe, mort,
  spectateur) et pendant qu'un menu numéroté est ouvert.
- Le sonar des murs ne joue qu'**en mouvement** (`access_sonar 2` pour toujours).

## Les menus sont en anglais

- `ui_language french` dans la console, ou le raccourci avec `+ui_language french`.
- Vérifiez la présence de `cstrike\resource\mainui_french.txt` et du `titles.txt` français
  (l'original est `titles_english.txt`).

## Une touche ne fait rien

- **AZERTY** : les touches du jeu suivent la position QWERTY. Avancer = Z, radio = W X C.
- Vos propres réglages ont peut-être réaffecté la touche : `access.cfg` est rejoué au démarrage,
  mais une association faite pendant la partie reste jusqu'au prochain lancement.
- Les touches d'accessibilité répondent toujours par une phrase ; un silence total indique que la
  parole est coupée (voir plus haut).

## La sélection des menus saute toute seule

La souris la déplace : vérifiez `access_menu_mouse 0` (valeur par défaut).

## Impossible d'acheter

Le temps d'achat est de 60 s après le début de la manche dans une partie que vous hébergez
(`mp_buytime 1` dans `game.cfg`). Sur le serveur de quelqu'un d'autre, c'est son réglage qui compte.

## Pas de guidage sur une carte

La carte n'a pas de fichier `.nav` dans `cstrike\maps`. Voir
[04 — Étendre](04-etendre-et-personnaliser.md#guidage-et-cartes) pour en générer un. Sans lui, la
balise pointe en ligne droite vers la cible.

## Compilation

| Message | Solution |
|---|---|
| « Visual Studio … introuvable » | installer la charge de travail C++ **et** « Outils CMake C++ pour Windows », ou définir `VSINSTALL` |
| `Impossible d'ouvrir le fichier include : 'stdio.h'` | SDK Windows absent : `setup_sources.ps1 -LocalSdk` ou composant SDK de Visual Studio |
| `could not configure a C compiler!` (moteur) | même cause ; relancer `build_xash.bat configure` après avoir installé le SDK |
| `Filename too long` pendant le téléchargement | déplacer le projet dans un dossier court (`C:\CS16`) ; supprimer le dépôt incomplet et relancer |
| « dépôt incomplet » | supprimer le dossier indiqué dans `repos\` et relancer `setup_sources.ps1` |
| un patch ne s'applique pas | les sources ne sont pas à la bonne version (voir les commits dans [02](02-installation-depuis-zero.md)) |
| le script PowerShell affiche des caractères bizarres | enregistrer le `.ps1` en UTF-8 avec BOM |
