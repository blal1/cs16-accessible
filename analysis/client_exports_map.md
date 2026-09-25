# client.dll (Valve) exports ↔ cs16-goldsrc-client source

54/88 exports located. Decompiled bodies: `decompiled/client.dll/client.dll.c` (search `===== <name> @`).

| Export | Address in Valve client.dll | Source definition |
|---|---|---|
| `AttemptToMaterialize` | `0190b860` | `dlls/weapons.cpp:555`, `dlls/weapons.h:211` |
| `CorpseFallThink` | `0190b1f0` | `dlls/monsters.cpp:3244`, `dlls/mpstubb.cpp:47` |
| `DefaultTouch` | `0190b9c0` | `dlls/weapons.cpp:614`, `dlls/weapons.cpp:1117`, `dlls/weapons.h:208` |
| `DefaultTouch` | `0190b8a0` | `dlls/weapons.cpp:614`, `dlls/weapons.cpp:1117`, `dlls/weapons.h:208` |
| `DestroyItem` | `0190b8b0` | `dlls/weapons.cpp:740`, `dlls/weapons.h:205` |
| `FallThink` | `0190b840` | `dlls/weapons.cpp:495`, `dlls/weapons.h:209` |
| `Materialize` | `0190b9b0` | `dlls/items.cpp:158`, `dlls/weapons.cpp:533`, `dlls/weapons.cpp:1104` |
| `Materialize` | `0190b850` | `dlls/items.cpp:158`, `dlls/weapons.cpp:533`, `dlls/weapons.cpp:1104` |
| `PlayerDeathThink` | `0190b370` | `dlls/player.cpp:1337` |
| `SUB_CallUseToggle` | `0190ba20` | — |
| `SUB_Remove` | `0190ad50` | `dlls/subs.cpp:114`, `dlls/cbase.h:211` |
| `Smack` | `01916180` | `dlls/crowbar.cpp:154`, `dlls/wpn_shared/wpn_knife.cpp:245` |
| `SwingAgain` | `019161a0` | `dlls/crowbar.cpp:160`, `dlls/wpn_shared/wpn_knife.cpp:250` |
| `CAM_Think` | `01957360` | `cl_dll/in_camera.cpp:152` |
| `CL_CameraOffset` | `01957ef0` | `cl_dll/in_camera.cpp:625` |
| `CL_CreateMove` | `01958cc0` | `cl_dll/input.cpp:679` |
| `CL_IsThirdPerson` | `01957ec0` | `cl_dll/in_camera.cpp:618` |
| `ClientFactory` | `01944bb0` | — |
| `CreateInterface` | `01959b10` | `common/interface.cpp:38`, `public/interface.cpp:56` |
| `Demo_ReadBuffer` | `01945e90` | `cl_dll/demo.cpp:57` |
| `F` | `01944bc0` | — |
| `HUD_AddEntity` | `01945f10` | `cl_dll/entity.cpp:39` |
| `HUD_ChatInputPosition` | `01927fb0` | `cl_dll/vgui_SpectatorPanel.cpp:24` |
| `HUD_ConnectionlessPacket` | `019445f0` | `cl_dll/cdll_int.cpp:316` |
| `HUD_CreateEntities` | `01946350` | `cl_dll/entity.cpp:276` |
| `HUD_DirectorMessage` | `01944b60` | `cl_dll/cdll_int.cpp:587` |
| `HUD_DrawNormalTriangles` | `0196a260` | `cl_dll/tri.cpp:52` |
| `HUD_DrawTransparentTriangles` | `0196a270` | `cl_dll/tri.cpp:74` |
| `HUD_Frame` | `01944ab0` | `cl_dll/cdll_int.cpp:504` |
| `HUD_GetHullBounds` | `019445d0` | `cl_dll/cdll_int.cpp:282` |
| `HUD_GetPlayerTeam` | `01944b80` | — |
| `HUD_GetStudioModelInterface` | `0194a840` | `cl_dll/GameStudioModelRenderer.cpp:1248` |
| `HUD_GetUserEntity` | `01946e40` | `cl_dll/entity.cpp:874` |
| `HUD_Init` | `019449d0` | `cl_dll/cdll_int.cpp:406` |
| `HUD_Key_Event` | `01958330` | `cl_dll/input.cpp:370` |
| `HUD_PlayerMove` | `01944620` | `cl_dll/cdll_int.cpp:341` |
| `HUD_PlayerMoveInit` | `01944600` | `cl_dll/cdll_int.cpp:329` |
| `HUD_PlayerMoveTexture` | `01944610` | `cl_dll/cdll_int.cpp:336` |
| `HUD_PostRunCmd` | `0190ec40` | `cl_dll/cs_wpn/cs_weapons.cpp:1490` |
| `HUD_ProcessPlayerState` | `01946010` | `cl_dll/entity.cpp:134` |
| `HUD_Redraw` | `01944a60` | `cl_dll/cdll_int.cpp:432` |
| `HUD_Reset` | `01944aa0` | `cl_dll/cdll_int.cpp:491` |
| `HUD_Shutdown` | `019449e0` | `cl_dll/input.cpp:1048` |
| `HUD_StudioEvent` | `01946370` | `cl_dll/entity.cpp:400` |
| `HUD_TempEntUpdate` | `019464c0` | `cl_dll/entity.cpp:459` |
| `HUD_TxferLocalOverrides` | `01945fc0` | `cl_dll/entity.cpp:100` |
| `HUD_TxferPredictionData` | `019461d0` | `cl_dll/entity.cpp:215` |
| `HUD_UpdateClientData` | `01944a80` | `cl_dll/cdll_int.cpp:464` |
| `HUD_VidInit` | `019449c0` | `cl_dll/cdll_int.cpp:386` |
| `HUD_VoiceStatus` | `01944ad0` | `cl_dll/cdll_int.cpp:557` |
| `IN_Accumulate` | `0192f1b0` | `cl_dll/inputw32.cpp:695` |
| `IN_ActivateMouse` | `0192e980` | `cl_dll/inputw32.cpp:296` |
| `IN_ClearStates` | `0192f330` | `cl_dll/inputw32.cpp:734` |
| `IN_DeactivateMouse` | `0192e9c0` | `cl_dll/inputw32.cpp:315` |
| `IN_MouseEvent` | `0192ec20` | `cl_dll/inputw32.cpp:481` |
| `Initialize` | `01944710` | `cl_dll/cdll_int.cpp:250`, `cl_dll/vgui_ClassMenu.cpp:408`, `cl_dll/vgui_ScorePanel.cpp:242` |
| `KB_Find` | `01958030` | `cl_dll/input.cpp:211` |
| `V_CalcRefdef` | `0196d900` | `cl_dll/view.cpp:1836` |
| `weapon_ak47` | `0190f670` | `dlls/wpn_shared/wpn_ak47.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_aug` | `0190fd30` | `dlls/wpn_shared/wpn_aug.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_awp` | `01910490` | `dlls/wpn_shared/wpn_awp.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_c4` | `01910be0` | `dlls/wpn_shared/wpn_c4.cpp:28` (LINK_ENTITY_TO_CLASS) |
| `weapon_deagle` | `01911350` | `dlls/wpn_shared/wpn_deagle.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_elite` | `01911a10` | `dlls/wpn_shared/wpn_elite.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_famas` | `01912210` | `dlls/wpn_shared/wpn_famas.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_fiveseven` | `01912a00` | `dlls/wpn_shared/wpn_fiveseven.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_flashbang` | `01913100` | `dlls/wpn_shared/wpn_flashbang.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_g3sg1` | `01913a10` | `dlls/wpn_shared/wpn_g3sg1.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_galil` | `01914160` | `dlls/wpn_shared/wpn_galil.cpp:22` (LINK_ENTITY_TO_CLASS) |
| `weapon_glock18` | `01914840` | `dlls/wpn_shared/wpn_glock18.cpp:25` (LINK_ENTITY_TO_CLASS) |
| `weapon_hegrenade` | `019151b0` | `dlls/wpn_shared/wpn_hegrenade.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_knife` | `01915af0` | `dlls/wpn_shared/wpn_knife.cpp:24` (LINK_ENTITY_TO_CLASS) |
| `weapon_m249` | `01916960` | `dlls/wpn_shared/wpn_m249.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_m3` | `01917020` | `dlls/wpn_shared/wpn_m3.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_m4a1` | `01917730` | `dlls/wpn_shared/wpn_m4a1.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_mac10` | `01918020` | `dlls/wpn_shared/wpn_mac10.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_mp5navy` | `01918660` | `dlls/wpn_shared/wpn_mp5navy.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_p228` | `01918ca0` | `dlls/wpn_shared/wpn_p228.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_p90` | `019193a0` | `dlls/wpn_shared/wpn_p90.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_scout` | `01919a50` | `dlls/wpn_shared/wpn_scout.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_sg550` | `0191a110` | `dlls/wpn_shared/wpn_sg550.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_sg552` | `0191a850` | `dlls/wpn_shared/wpn_sg552.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_smokegrenade` | `0191afd0` | `dlls/wpn_shared/wpn_smokegrenade.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_tmp` | `0191b940` | `dlls/wpn_shared/wpn_tmp.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_ump45` | `0191bf60` | `dlls/wpn_shared/wpn_ump45.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_usp` | `0191c5a0` | `dlls/wpn_shared/wpn_usp.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `weapon_xm1014` | `0191ceb0` | `dlls/wpn_shared/wpn_xm1014.cpp:21` (LINK_ENTITY_TO_CLASS) |
| `entry` | `019ae353` | — |
