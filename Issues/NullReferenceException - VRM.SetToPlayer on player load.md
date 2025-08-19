# Issue

## Description

When joining a world and another player finishes loading in, two NullReferenceExceptions are logged from `ValheimVRM.VRM.<SetToPlayer>d__21.MoveNext()`. The avatar still appears to attach and render correctly afterward, but the coroutine hits a null during the attach sequence. This occurs during normal gameplay (not during disconnect/teardown).

## Resolution

Added post-yield null-guards for `player`/`vrmModel` and re-fetched the `Animator` right before the camera-height step in `VRM.SetToPlayer`.

## Logs

```text
[Info   : Unity Log] [ValheimVRM] loaded settings for Kuwuwi:
ModelScale=1.1
ModelOffsetY=0
PlayerHeight=1.85
PlayerRadius=0.5
SittingOnChairOffset=(0.00, 0.00, 0.00)
SittingOnThroneOffset=(0.00, 0.00, 0.00)
SittingOnShipOffset=(0.00, 0.00, 0.00)
HoldingMastOffset=(0.00, 0.00, 0.00)
HoldingDragonOffset=(0.00, 0.00, 0.00)
SittingIdleOffset=(0.00, 0.00, 0.00)
SleepingOffset=(0.00, 0.00, 0.00)
RightHandItemPos=(0.00, 0.00, 0.00)
LeftHandItemPos=(0.00, 0.00, 0.00)
RightHandBackItemPos=(0.00, 0.00, 0.00)
RightHandBackItemToolPos=(0.00, 0.00, 0.00)
LeftHandBackItemPos=(0.00, 0.00, 0.00)
BowBackPos=(0.00, 0.00, 0.00)
KnifeSidePos=(0.00, 0.00, 0.00)
KnifeSideRot=(0.00, 0.00, 0.00)
StaffPos=(0.00, 0.00, 0.00)
StaffSkeletonPos=(0.00, 0.00, 0.00)
StaffRot=(0.00, 0.00, 0.00)
HelmetVisible=False
HelmetScale=(1.00, 1.00, 1.00)
HelmetOffset=(0.00, 0.00, 0.00)
ChestVisible=False
ShouldersVisible=False
UtilityVisible=False
LegsVisible=False
ModelBrightness=0.8
FixCameraHeight=True
UseMToonShader=False
EnablePlayerFade=True
AllowShare=True
SpringBoneStiffness=1
SpringBoneGravityPower=1
EquipmentScale=1
AttackDistanceScale=1
InteractionDistanceScale=1
SwimDepthScale=1
AttemptTextureFix=False
[Info   : Unity Log] [ValheimVRM Async] loading vrm: 32714388 bytes
[Info   : Unity Log] [ValheimVRM Async] loading vrm: 32714388 bytes
...
[Info   : Unity Log] 08/18/2025 14:13:52: Spawned after 8.019994

[Warning: Unity Log] 08/18/2025 14:13:52: Missing stat for guardian power:

[Info   : Unity Log] 08/18/2025 14:13:52: Vis equip model set to 1

[Warning: Unity Log] 08/18/2025 14:13:52: Character ID for player ([Nyaa, 0:0], [Nyaarium, 0:0], Nyaarium) was 0:0. Skipping.

[Info   : Unity Log] 08/18/2025 14:13:52: Skipping unloading unused assets

[Info   : Unity Log] 08/18/2025 14:13:52: Minimap: Adding unique location (-5.60, 80.10, -3.92)

[Info   : Unity Log] 08/18/2025 14:13:52: Minimap: Adding unique location (814.34, 36.23, 1650.67)

[Info   : Unity Log] 08/18/2025 14:13:52: Minimap: Adding unique location (703.41, 35.69, 3455.34)

[Info   : Unity Log] 08/18/2025 14:13:52: Minimap: Adding unique location (1990.75, 31.47, 2245.13)

[Error  : Unity Log] NullReferenceException
Stack trace:
ValheimVRM.VRM+<SetToPlayer>d__21.MoveNext () (at <ecf8fd409ab7412fabadc904a2d8357d>:0)
UnityEngine.SetupCoroutine.InvokeMoveNext (System.Collections.IEnumerator enumerator, System.IntPtr returnValueAddress) (at <be2cce08ca774b9684099a81093ecac0>:0)

[Error  : Unity Log] NullReferenceException
Stack trace:
ValheimVRM.VRM+<SetToPlayer>d__21.MoveNext () (at <ecf8fd409ab7412fabadc904a2d8357d>:0)
UnityEngine.SetupCoroutine.InvokeMoveNext (System.Collections.IEnumerator enumerator, System.IntPtr returnValueAddress) (at <be2cce08ca774b9684099a81093ecac0>:0)

[Info   : Unity Log] [ValheimVRM] Material processing completed.
[Info   : Unity Log] [ValheimVRM] Material processing completed.
```

## Analysis

Likely a race in `VRM.SetToPlayer(Player)` where references obtained before a `yield` become invalid by the time they are used later.

We cache `animator = player.GetComponentInChildren<Animator>()` and later access `animator.GetBoneTransform(...)` in the camera-height block after multiple `yield return null;` calls without re-checking that `animator` is still valid. If the remote player's visual/animator is rebuilt during spawn, `animator` can become null and throw.
