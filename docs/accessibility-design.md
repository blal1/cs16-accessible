# Accessibility design: CS 1.6 for blind players

Goal: a blind player can launch a game, pick a team and weapons, move around a map, find objectives,
detect and fight enemies, and follow the state of the round using NVDA speech and procedurally
generated sounds only.

## Principles

1. **Sounds for continuous space, speech for discrete facts.** Walls, directions, enemies and aim
   change every frame, so they are sounds. Names, numbers and menus are speech.
2. **One sound grammar for everything.** Every cue is placed the same way:
   - left/right = stereo pan (equal power), from the angle relative to where you look;
   - **behind = muffled** (low-pass filter, slightly duller), so front and back are never confused;
   - **higher pitch = above you** (±half an octave straight up/down), or closer for sonar and scan;
   - faster repetition = closer or more urgent.
3. **Each cue has a single meaning and a distinct timbre** (noise tap, bell, buzz, chirp…), so cues
   can overlap without being mistaken for each other or for game sounds.
4. **Directions are spoken as clock hours** (12 = ahead, 3 = right, 6 = behind, 9 = left) and
   distances in metres. Map directions use compass words (nord, est…), with north = +Y as on the
   overview.
5. **Fair play**: enemies are only sonified when there is a clear line of sight from your eyes, the
   information a sighted player has on screen. `access_enemy_fov 120` restricts it to the front.
   Nothing aims or moves for the player.
6. **Nothing is mandatory**: every speech category and cue family has its own cvar, and the whole
   layer degrades silently when NVDA or XAudio2 is missing.

## Sound vocabulary

All sounds are synthesized at startup (`access_audio.cpp`, no files). Samples are exported to
`analysis/sons/*.wav` for learning.

| Cue | Timbre | Meaning | Behaviour |
|---|---|---|---|
| `WALL_FRONT` | tap + ring | wall ahead | sonar, 0° |
| `WALL_TAP` | cane tap | wall at 45°, 90°, 180° | sonar round-robin, louder/higher when closer |
| `LEDGE` | falling chirp | drop ahead in your walking direction | lower pitch = deeper; speech "chute dangereuse" over ~5.5 m |
| `STEP` | rising chirp | knee-high obstacle you can jump | |
| `SCAN` | sine blip | radar sweep: wall in that direction | high = near, low = far |
| `OPENING` | breath of noise | radar sweep: open space (> 12 m) | corridors, doors, open areas |
| `BEACON` | bell | next point of the guidance path | from the farthest path point in line of sight, so it leads around corners; faster when near |
| `ARRIVED` | rising arpeggio | guidance target reached | + speech |
| `ENEMY_SPOTTED` | sharp rising blip | an enemy just came into view | once per sighting |
| `ENEMY` | two-tone buzz | visible enemy | the 3 nearest, 0.3 s (close) to 1 s (far) |
| `TEAMMATE` | soft blip | teammate within ~9 m | every 1.2 s |
| `AIM` | pure tone | crosshair within 30° of a visible enemy | panned toward the enemy; pitch rises and repeats faster as the error shrinks |
| `AIM_LOCK` | bright click | crosshair on the enemy's torso | angle = torso half-width at that range |
| `DAMAGE` | low thud | you were hit | placed at the damage source; louder for heavy hits |
| `GRENADE` | metallic rattle | live grenade within ~23 m | + speech with the grenade type ("Flash, détournez-vous") |
| `HEARTBEAT` | double thump | health ≤ 25 | faster when lower |
| `AMMO_LOW` | dry double click | magazine ≤ 20 % | + speech "Chargeur vide" at 0 |
| `NORTH` | wood tick | your view crosses north | compass by ear |
| `OBJECTIVE` | marimba | guidance beacon when the target is the bomb (dropped or planted) | position follows the radar |

## Speech

| Source | What is spoken |
|---|---|
| HUD | health, armour, money (+/−, merged over 400 ms), weapon + ammo on switch, zone entry (buy zone, bomb site, rescue, VIP, escape, defuse kit) |
| Messages | chat, radio, centre messages (round result, bomb planted…), hint texts (HudText), MOTD (HTML stripped) |
| Aim target | the status bar line ("Ennemi : nom, santé 80 %") when it changes |
| Kills | yours always; others with `access_speech_kills` |
| Round | 1 min / 30 s / 10 s left; end-of-map scoreboard |
| Spectator | camera mode and watched player |
| Menus | every text menu, read whole and interrupting (team, class, buy, radio, votes) |

## Screens and menus coverage

The game runs on Xash3D FWGS, whose engine, menus and client are all open source, so every screen
has a speech path. Nothing is left to Valve's closed `GameUI.dll`.

| Screen | How it is spoken | Layer |
|---|---|---|
| Main menu, in-game Esc menu, options (video, audio, controls, mouse, game), create game, server browser, key bindings, quit / confirmation dialogs, connection progress | window title on open, focused item with type and value ("Volume des effets sonores, curseur, 60 pour cent"), value changes, table rows with column headers, dialog questions | menu (`mainui_cpp/menu_access.cpp`) |
| Text fields in menus (player name, server address, password) | each typed / deleted character, character under the cursor, masked input spoken as "étoile" | menu |
| Console | "Console" on open with the keys to use, typed characters, history recall, completion, every printed line while open, "Console fermée" | engine (`engine/client/accessibility/con_access.c`) |
| Chat input (say / say_team) | "Message à tous" / "Message à votre équipe", typed characters, "Message envoyé" or "Message annulé"; received chat is spoken by the client | engine + client |
| Team, appearance, buy, radio, vote, AMX menus | read in full when shown, choose with number keys (`access_textmenus 1` asks the server for text menus) | client |
| HUD, round, kills, hints, MOTD, scoreboard, timer, spectator | as in the Speech section | client |
| Radar / overview | replaced by guidance, `access_where`, `access_scan`, teammate cues | client |

Menu rules for keyboard-only use:
- Keyboard focus never moves with the mouse while `access_menu_mouse 0` (default): the menu's pointer
  is parked off screen, so a mouse resting on a button cannot steal the focus.
- Focus changes are spoken once stable for 80 ms (no flicker during animations); banners and pictures
  are skipped automatically when the arrows land on them.
- The focus is never moved programmatically when a window opens, because buttons activate on key
  release and the Enter that opened the window is still being released.
- The server browser's tab selector (Internet / Favorites / History) was mouse-only; Enter now cycles it.

Languages: `ui_language french` loads the official French game strings plus two files added for this
project: `cstrike/resource/mainui_french.txt` (394 menu strings, including the help texts) and a
French `cstrike/titles.txt` for the numbered menus and messages (original kept as `titles_english.txt`).

Keyboard layout: Xash binds keys by physical position (QWERTY). On AZERTY, move with Z Q S D; the
default radio keys are W X C. The accessibility keys (F3-F12, H, J, I, O) are at the same place on both.

## Controls

| Key | Command | |
|---|---|---|
| F3 | `access_scores` | scoreboard |
| F4 | `access_time` | round time |
| F6 | `access_status` | health, armour, money, weapon, ammo |
| F7 | `access_repeat` | repeat last announcement |
| F8 | `access_silence` | stop speech |
| F9 / F10 | `access_target_next` / `_prev` | choose a guidance target (bomb, sites, hostages, rescue zones, spawns), spoken with path length and clock direction |
| F11 | `access_where` | heading, current target, two nearest objectives |
| F12 | `access_target_stop` | stop guidance |
| H | `access_scan` | 1.4 s radar sweep clockwise from ahead + spoken summary of openings and nearest wall |
| J | `access_enemies_list` | visible enemies with clock direction and distance |
| I | `access_compass` | heading in words and degrees |
| O | `access_motd` | reread the server message |

`cstrike/access.cfg` holds these binds and every option; the client runs it once at startup, after the
user's own config, so the accessibility binds always apply.

## Architecture

```
CS16_Xash/                 playable game (Xash3D FWGS + CS 1.6 assets from the original installer)
  xash.dll                 engine, built from repos/xash3d-fwgs (branch accessibility-nvda)
    engine/client/accessibility/con_access.c   console and chat input speech
  cstrike/cl_dlls/client.dll   built from repos/cs16-client (branch accessibility-nvda)
    cl_dll/accessibility/
      access_tts.*       NVDA controller client, loaded at runtime (shared by all three layers)
      access_speech.*    HUD / chat / menus / kills speech, access_status, profile + language reload
      access_screens.*   scoreboard, timer, MOTD, hints, aim status bar, spectator, intermission
      access_audio.*     XAudio2 on its own COM thread; 26 synthesized cues; pan / low-pass / pitch
      access_map.*       BSP objectives + .nav mesh + A* with portal waypoints
      access_nav.*       sonar, ledges, scan, guidance, players, aim, grenades, damage, body
  cstrike/cl_dlls/menu.dll     built from repos/cs16-client/3rdparty/mainui_cpp (branch accessibility-nvda)
    menu_access.cpp        per-frame window / focus / value observer
  nvdaControllerClient.dll     NVDA 2026.2 controller client (x86), next to the engine and in cl_dlls
```

`access_tts` writes a transcript of every utterance to the file named by the environment variable
`ACCESS_TTS_LOG` (lines `!` interrupting, `  ` queued, `#` diagnostics such as window structure and the
first use of each sound). The automated tests read it.

Build: `tools/scripts/build_velaron.bat` (client, menu, server) and `tools/scripts/build_xash.bat`
(engine), MSVC x86 with the local NuGet Windows SDK (`tools/winsdk`), no system SDK needed.

## Verification

Automated, on this machine, with NVDA running:
- `tools/scripts/menu_test.ps1` launches the game, posts real key presses to its window and prints the
  speech transcript. Covered: main menu, Options, Audio (slider changes), Video, Load game (table,
  unavailable buttons), quit dialog, Esc back-navigation; in game on de_dust2: team / appearance / buy /
  radio menus in French, HUD, F3 F4 F6 F9 F11 H I J, chat typing and sending, console typing, command
  output and history, walking with sounds (walls, ledge, step, scan, openings, beacon).
- `tools/navtools/test_access_map.exe`: all 25 stock maps parse, 0 unreachable spawn-to-objective paths.
- `tools/audiotest/test_access_audio.exe`: every cue at 4 positions, levels checked.

- Full round against 5 bots on de_dust2: enemy spotted / enemy pulses (panned right, matching "3 heures"),
  damage from the right, health drops, heartbeat, death announcement, round result, spectator, teammate cue,
  new-round money, bot radio in French.

- Aim: 4 bots frozen with `bot_zombie 1` near the player, view turned in ~5° steps: "visée" tone panned
  toward the enemy, then "visée verrouillée" when the crosshair crossed it; `access_enemies_list` followed
  the enemy around the clock (7 h, 4 h, 12 h, 9 h at 22 m).
- Grenades: own HE grenade tracked by a quiet rattle without speech; enemy grenades (bots limited to
  knives and grenades with `bot_allow_*`) announced "Grenade explosive" + rattle from the right direction.
  Test configs are in `tools/tests/`.

Not verified yet: a human playtest.
