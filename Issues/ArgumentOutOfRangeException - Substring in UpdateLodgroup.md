# Issue

## Description

ArgumentOutOfRangeException thrown during player equipment visual updates. The exception occurs inside our Harmony postfix `Patch_VisEquipment_UpdateLodgroup.Postfix` when checking item names for back equipment positioning. It points to `System.String.Substring(Int32, Int32)`, indicating we are slicing strings without confirming sufficient length.

New observation (08/17/2025): Happened when approaching an area with dungeons/players. Sequence showed teleport trigger, multiple dungeon loads/spawns, then the exception during `VisEquipment.UpdateLodgroup`. Suggests equipment visuals were being refreshed for nearby players/NPCs during area streaming.

Reproduction:
1. Have poison arrows inside a natural spawning chest (not player-made).
2. Press the quick loot button.
3. The arrows permanently disappear and the error is logged.

Related/installed mods that may touch equipment or storage/loot systems:
- ExtraSlots (adds equipment/food/ammo/misc slots)
- Quick Stack (inventory management, hotkeys/UI, equipment compatibility)
- ValheimVRM (hides equipment in favor of VRM avatar)

Please add repro steps and paste the exact `Player.log` excerpt if available.

## Resolution

Fixed by replacing unsafe `Substring` prefix checks with null-safe `StartsWith` in `Patch_VisEquipment_UpdateLodgroup.Postfix`.

## Logs

```
[Error : Unity Log] ArgumentOutOfRangeException: Index and length must refer to a location within the string.
Parameter name: length
Stack trace:
System.String.Substring(System.Int32 startIndex, System.Int32 length)
ValheimVRM.Patch_VisEquipment_UpdateLodgroup.Postfix(VisEquipment __instance)
(wrapper dynamic-method) VisEquipment.DMD<VisEquipment::UpdateLodgroup>(VisEquipment)
VisEquipment.UpdateEquipmentVisuals()
VisEquipment.CustomUpdate(System.Single deltaTime, System.Single time)
```

New logs (08/17/2025):

```
[Info   : Unity Log] 08/17/2025 22:32:03: Teleportation TRIGGER

[Info   : Unity Log] 08/17/2025 22:32:03: Teleporting Nyaa

[Info   : Unity Log] 08/17/2025 22:32:08: Loading dungeon

[Info   : Unity Log] 08/17/2025 22:32:08: Dungeon loaded with 12 rooms in 1.5108 ms.

[Info   : Unity Log] 08/17/2025 22:32:08: Loading room prefabs asynchronously

[Info   : Unity Log] 08/17/2025 22:32:09: Spawning dungeon

[Info   : Unity Log] 08/17/2025 22:32:26: Loading dungeon

[Info   : Unity Log] 08/17/2025 22:32:26: Dungeon loaded with 26 rooms in 2.0263 ms.

[Info   : Unity Log] 08/17/2025 22:32:26: Loading room prefabs asynchronously

[Info   : Unity Log] 08/17/2025 22:32:26: Loading dungeon

[Info   : Unity Log] 08/17/2025 22:32:26: Dungeon loaded with 9 rooms in 1.0053 ms.

[Info   : Unity Log] 08/17/2025 22:32:26: Loading room prefabs asynchronously

[Info   : Unity Log] 08/17/2025 22:32:26: Spawning dungeon

[Error  : Unity Log] ArgumentOutOfRangeException: Index and length must refer to a location within the string.
Parameter name: length
Stack trace:
System.String.Substring (System.Int32 startIndex, System.Int32 length) (at <31687ccd371e4dc6b0c23a1317cf9474>:0)
ValheimVRM.Patch_VisEquipment_UpdateLodgroup.Postfix (VisEquipment __instance) (at <6d63bdc8a9054af19bf86e5b56910da0>:0)
(wrapper dynamic-method) VisEquipment.DMD<VisEquipment::UpdateLodgroup>(VisEquipment)
VisEquipment.UpdateEquipmentVisuals () (at <c4162928ed6e42468a4d973647f3b73f>:0)
VisEquipment.UpdateVisuals () (at <c4162928ed6e42468a4d973647f3b73f>:0)
VisEquipment.CustomUpdate (System.Single deltaTime, System.Single time) (at <c4162928ed6e42468a4d973647f3b73f>:0)
MonoUpdatersExtra.CustomUpdate (System.Collections.Generic.List`1[T] container, System.Collections.Generic.List`1[T] source, System.String profileScope, System.Single deltaTime, System.Single time) (at <c4162928ed6e42468a4d973647f3b73f>:0)
MonoUpdaters.Update () (at <c4162928ed6e42468a4d973647f3b73f>:0)

[Info   : Unity Log] 08/17/2025 22:32:26: Spawning dungeon
```

## Analysis

Exception originates in our Harmony postfix `Patch_VisEquipment_UpdateLodgroup.Postfix` during equipment visual updates.

Prefix checks used `ToString().Substring(0, N)` on equipment names from `m_leftBackItem`/`m_rightBackItem` without guarding for null or length, leading to `ArgumentOutOfRangeException` when the string was shorter than N or empty. In case you don't know, `.Substring(0, 5)` for instance, will throw an error if the string is shorter than 5 characters.
