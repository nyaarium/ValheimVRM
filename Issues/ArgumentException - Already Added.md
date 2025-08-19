# Issue

## Description

Upon joining a server, some errors occurs.

## Resolution

In `Patch_Player_Awake.Postfix` we now add `VrmController` only if not already present.

## Logs

```
[Info   :Jotunn.Managers.SynchronizationManager+<AdminRPC_OnClientReceive>d__49] Received admin status from server: No Admin
[Info   :AzuCraftyBoxes] Configuration reload complete.
[Info   : Unity Log] 08/17/2025 20:08:16: Generating new world minimap done [6830ms]

[Info   : Unity Log] 08/17/2025 20:08:16: Minimap: unpacking compressed mapData 13401 => 8390679 bytes

[Info   : Unity Log] 08/17/2025 20:08:16: Starting respawn

[Info   :AzuCraftyBoxes] Configuration reload complete.
[Info   : Unity Log] 08/17/2025 20:08:17: tip:$loadscreen_tip04

[Info   : Unity Log] 08/17/2025 20:08:17: Initializing loading indicator instance

[Info   : Unity Log] Ignored non-blast furnace smelter.
[Info   : Unity Log] Ignored non-blast furnace smelter.
[Info   : Unity Log] Ignored non-blast furnace smelter.
[Info   : Unity Log] Ignored non-blast furnace smelter.
[Info   : Unity Log] 08/17/2025 20:08:24: Spawned after 8.019994

[Error  : Unity Log] ArgumentException: An item with the same key has already been added. Key: -1823969707
Stack trace:
System.Collections.Generic.Dictionary`2[TKey,TValue].TryInsert (TKey key, TValue value, System.Collections.Generic.InsertionBehavior behavior) (at <31687ccd371e4dc6b0c23a1317cf9474>:0)
System.Collections.Generic.Dictionary`2[TKey,TValue].Add (TKey key, TValue value) (at <31687ccd371e4dc6b0c23a1317cf9474>:0)
ZNetView.Register (System.String name, System.Action`1[T] f) (at <c4162928ed6e42468a4d973647f3b73f>:0)
ValheimVRM.VrmController.Awake () (at <13a9cca02d3543c1915f75b77312be26>:0)
UnityEngine.GameObject:AddComponent()
ValheimVRM.Patch_Player_Awake:Postfix(Player, ZNetView)
Player:DMD<Player::Awake>(Player)
UnityEngine.Object:Instantiate(GameObject, Vector3, Quaternion)
Game:DMD<Game::SpawnPlayer>(Game, Vector3, Boolean)
Game:UpdateRespawn(Single)
Game:FixedUpdate()

[Warning: Unity Log] 08/17/2025 20:08:24: Missing stat for guardian power:

[Info   : Unity Log] 08/17/2025 20:08:24: Vis equip model set to 1

[Warning: Unity Log] 08/17/2025 20:08:24: Character ID for player ([Nyaa, 0:0], [Nyaarium, 0:0], Nyaarium) was 0:0. Skipping.

[Info   : Unity Log] 08/17/2025 20:08:24: Skipping unloading unused assets

[Info   : Unity Log] 08/17/2025 20:08:24: Minimap: Adding unique location (-5.60, 80.10, -3.92)

[Info   : Unity Log] 08/17/2025 20:08:24: Minimap: Adding unique location (814.34, 36.23, 1650.67)

[Info   : Unity Log] 08/17/2025 20:08:24: Minimap: Adding unique location (703.41, 35.69, 3455.34)

[Info   : Unity Log] 08/17/2025 20:08:24: Minimap: Adding unique location (1990.75, 31.47, 2245.13)

[Info   : Unity Log] PlatformUserID "" failed to parse!
[Info   : Unity Log] PlatformUserID "" failed to parse!
[Info   : Unity Log] PlatformUserID "" failed to parse!
[Error  : Unity Log] NullReferenceException
Stack trace:
ValheimVRM.VRM+<SetToPlayer>d__21.MoveNext () (at <13a9cca02d3543c1915f75b77312be26>:0)
UnityEngine.SetupCoroutine.InvokeMoveNext (System.Collections.IEnumerator enumerator, System.IntPtr returnValueAddress) (at <be2cce08ca774b9684099a81093ecac0>:0)

[Error  : Unity Log] ArgumentException: An item with the same key has already been added. Key: -1823969707
Stack trace:
System.Collections.Generic.Dictionary`2[TKey,TValue].TryInsert (TKey key, TValue value, System.Collections.Generic.InsertionBehavior behavior) (at <31687ccd371e4dc6b0c23a1317cf9474>:0)
System.Collections.Generic.Dictionary`2[TKey,TValue].Add (TKey key, TValue value) (at <31687ccd371e4dc6b0c23a1317cf9474>:0)
ZNetView.Register (System.String name, System.Action`1[T] f) (at <c4162928ed6e42468a4d973647f3b73f>:0)
ValheimVRM.VrmController.Awake () (at <13a9cca02d3543c1915f75b77312be26>:0)
UnityEngine.GameObject:AddComponent()
ValheimVRM.Patch_Player_Awake:Postfix(Player, ZNetView)
Player:DMD<Player::Awake>(Player)
UnityEngine.Object:Instantiate(GameObject, Vector3, Quaternion)
ZNetScene:CreateObject(ZDO)
ZNetScene:CreateObjectsSorted(List`1, Int32, Int32&)
ZNetScene:CreateObjects(List`1, List`1)
ZNetScene:CreateDestroyObjects()
ZNetScene:Update()

[Error  : Unity Log] NullReferenceException
Stack trace:
ValheimVRM.VRM+<SetToPlayer>d__21.MoveNext () (at <13a9cca02d3543c1915f75b77312be26>:0)
UnityEngine.SetupCoroutine.InvokeMoveNext (System.Collections.IEnumerator enumerator, System.IntPtr returnValueAddress) (at <be2cce08ca774b9684099a81093ecac0>:0)

[Info   : Unity Log] 08/17/2025 20:08:31: Spawned Greydwarf_Shaman x 1

[Info   : Unity Log] 08/17/2025 20:08:31: Spawned Greydwarf x 1

[Info   : Unity Log] 08/17/2025 20:08:31: Starting to grow plant with rotation: (0.00000, 0.98324, 0.00000, -0.18233)

[Info   : Unity Log] 08/17/2025 20:08:31: Starting to grow plan
```

## Analysis

ArgumentException "An item with the same key has already been added" occurs during respawn/object creation, originating from `ZNetView.Register` called in `ValheimVRM.VrmController.Awake`. Stacks show the path via `Game.SpawnPlayer` and `ZNetScene.CreateObject`.

A related NullReferenceException occurs inside `ValheimVRM.VRM.SetToPlayer`.

If `VrmController` is attached more than once to the same player, calling `Register` twice with the same RPC names triggers the duplicate-key error.
