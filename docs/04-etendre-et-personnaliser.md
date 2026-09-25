# 04 — Étendre et personnaliser

Recettes pour modifier le comportement. Après chaque modification de code : recompiler
(`tools\scripts\build_velaron.bat` pour le client et les menus, `build_xash.bat` pour le moteur),
copier la DLL dans le jeu, puis vérifier avec [les tests](05-tests.md).

Chemins : `CL` = `repos\cs16-client\cl_dll\accessibility`, `MENU` = `repos\cs16-client\3rdparty\mainui_cpp`.

## Sans toucher au code

### Changer une touche ou un réglage

Éditez `cstrike\access.cfg` dans le dossier du jeu (ou `distribution\cstrike\access.cfg` pour les
prochains assemblages). Exemple : balayage radar sur la touche R au lieu de H :

```
bind "r" "access_scan"
```

Le client exécute ce fichier au démarrage, **après** la configuration de l'utilisateur : ses
touches ont toujours le dernier mot. Toutes les commandes et variables sont listées dans le
[guide du joueur](01-guide-du-joueur.md#réglages).

### Traduire ou corriger un texte

| Texte | Fichier |
|---|---|
| menus principaux (boutons, aides) | `cstrike\resource\mainui_french.txt` : `"texte anglais"  "traduction"` |
| menus numérotés et messages du jeu | `cstrike\titles.txt` (garder les codes `\y \w \r \d \R`, `%s`, les numéros `1.`) |
| messages officiels (fin de manche, conseils) | `cstrike\resource\cstrike_french.txt` (fichier UTF-16 de Valve) |
| annonces de l'accessibilité (« Santé », « à 3 heures »…) | code source, voir plus bas |

Pour une autre langue, créez `mainui_<langue>.txt` à partir de
`MENU\translations\mainui_skeleton_everything.txt` et réglez `ui_language <langue>`.

## Ajouter ou modifier une annonce

Les annonces passent par une seule fonction :

```cpp
Access_Speak( "Texte à dire", true );   // true = coupe l'annonce en cours
```

Exemple : annoncer le rechargement. Le serveur envoie `CurWeapon` à chaque tir et rechargement ;
le client appelle `Access_OnWeaponSelected( nom, balles, réserve )`, qui transmet à
`AccessNav_OnClip( armeChangée, balles )` dans `CL\access_nav.cpp`. Il suffit d'y ajouter, juste
avant la dernière ligne `prevClip = clip;` :

```cpp
if( clip > prevClip && prevClip >= 0 && !weaponChanged )
    Access_Speak( "Rechargé" );
```

Pour réagir à un **nouveau message du serveur**, repérez sa fonction `MsgFunc_<Nom>` dans
`repos\cs16-client\cl_dll` (par exemple `MsgFunc_BombDrop` dans `hud\radar.cpp`) et ajoutez-y un
appel vers une fonction de `CL\access_speech.cpp`.

Une catégorie d'annonces se désactive avec une variable : créez-la dans `Access_Init()`
(`CVAR_CREATE( "access_speech_xxx", "1", FCVAR_ARCHIVE )`) et testez-la avant de parler.

## Ajouter un son

1. Dans `CL\access_audio.h`, ajoutez une valeur à l'énumération `AccessCue`, **avant** `CUE_COUNT`.
2. Dans `BuildCues()` de `CL\access_audio.cpp`, fabriquez le son avec les briques existantes :

   ```cpp
   // AddTone( tampon, début, durée s, fréquence début, fréquence fin, harmoniques, nb, attaque s, décroissance, gain )
   AddTone( s_Cues[CUE_MON_SON], 0, 0.120f, 500.0f, 900.0f, warm, 2, 0.005f, 3.0f, 1.0f );
   // AddNoise( tampon, début, durée s, passe-haut Hz, passe-bas Hz, attaque s, décroissance, gain )
   AddNoise( s_Cues[CUE_MON_SON], 0, 0.020f, 1500.0f, 5500.0f, 0.001f, 7.0f, 0.5f );
   ```

   Chaque son est normalisé automatiquement. Donnez-lui **un timbre distinct** des autres.
3. Ajoutez son nom français au tableau `names[]` de `Play()` dans `CL\access_nav.cpp` (pour le
   journal de test) et au tableau `kNames` de `tools\audiotest\test_access_audio.cpp`.
4. Jouez-le à une position :

   ```cpp
   Play( CUE_MON_SON, Spatial( position, 1500.0f, 0.8f ) );   // position monde, distance max, volume
   Play( CUE_MON_SON, Centered( 0.6f ) );                       // au centre, sans direction
   ```

5. Écoutez-le : `tools\audiotest\build.bat` puis `test_access_audio.exe` (joue chaque son à gauche,
   au centre, à droite, derrière, et exporte des WAV).

Respectez la grammaire sonore : gauche/droite = direction, étouffé = derrière, aigu = au-dessus ou
proche, répétition rapide = urgent.

## Ajouter une commande (touche)

Dans `AccessNav_Init()` (`CL\access_nav.cpp`) ou `AccessScreens_Init()` :

```cpp
static void Cmd_MaCommande( void )
{
    Access_Speak( "Bonjour", true );
}
...
gEngfuncs.pfnAddCommand( "access_ma_commande", Cmd_MaCommande );
```

Puis `bind "k" "access_ma_commande"` dans `access.cfg`. Une commande ne doit **jamais rester
silencieuse** : si elle ne peut rien faire, elle le dit (voir `Cmd_Scan`).

## Menus

- **Titre d'une nouvelle fenêtre** : ajoutez `{ "NomDeClasse", "Titre français" }` à la table de
  `KnownTitle()` dans `MENU\menu_access.cpp`. Le nom de classe est celui passé au constructeur
  (`CMenuFramework( "CMenuVideo" )`) ; le journal de test l'affiche (`# fenêtre CMenuVideo…`).
- **Nouveau type de contrôle** : ajoutez un cas `dynamic_cast` dans `DescribeItem()`, qui remplit le
  type (`kind`) et la valeur (`value`).
- **Un contrôle utilisable seulement à la souris** : modifiez sa méthode `KeyDown` pour qu'Entrée ou
  les flèches changent sa valeur, comme cela a été fait pour `CMenuSwitch`.

## Guidage et cartes

- Les cibles de guidage viennent des entités de la carte (`ClassToType()` dans `CL\access_map.cpp`) :
  ajoutez une classe d'entité pour en guider d'autres.
- Une carte sans fichier `.nav` n'a pas de guidage par chemin (la balise pointe en ligne droite).
  Pour en créer un : lancer la carte avec des bots, puis `bot_nav_analyze` dans la console
  (commandes des bots de ReGameDLL), et copier le `.nav` produit dans `cstrike\maps`.

## Produire un patch à partager

Depuis chaque dépôt modifié :

```bat
git -C repos\cs16-client add -N cl_dll\accessibility
git -C repos\cs16-client diff --binary -- . ":(exclude)3rdparty" > patches\cs16-client.patch
git -C repos\cs16-client\3rdparty\mainui_cpp diff --binary > patches\mainui_cpp.patch
git -C repos\xash3d-fwgs diff --binary > patches\xash3d-fwgs.patch
```

(`add -N` fait apparaître les fichiers nouveaux dans le diff sans les valider.)
