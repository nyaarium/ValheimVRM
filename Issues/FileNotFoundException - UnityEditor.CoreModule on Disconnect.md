# Issue

## Description

After disconnecting from a server and returning to the title screen, the avatar (last used character at the campfire) does not appear. Logs show repeated FileNotFoundException referencing 'UnityEditor.CoreModule' during player cleanup, inside `VRM.VRMBlendShapeProxy.OnDestroy` via `VRM.BlendShapeMerger.RestoreMaterialInitialValues`.

## Resolution

Implemented Harmony patch to skip `VRM.VRMBlendShapeProxy.OnDestroy` entirely, avoiding the Editor assembly reference during disconnect.

## Logs

```text
[Info   : Unity Log] 08/17/2025 20:03:02: Skipping backup. World session not long enough.

[Info   : Unity Log] Am I Host? False
[Info   : Unity Log] 08/17/2025 20:03:02: ZNet Shutdown

[Info   : Unity Log] 08/17/2025 20:03:02: Unloading unused assets

[Info   : Unity Log] 08/17/2025 20:03:02: Sending disconnect msg

[Info   : Unity Log] 08/17/2025 20:03:02: Released session ticket

[Info   : Unity Log] ZPlayFabMatchmaking::UnregisterServer - unregistering server now. State: Uninitialized
[Error  : Unity Log] FileNotFoundException: Could not load file or assembly 'UnityEditor.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null' or one of its dependencies.
Stack trace:
VRM.BlendShapeMerger.RestoreMaterialInitialValues (System.Collections.Generic.IEnumerable`1[T] clips) (at <90680c4cfd344736904ce6584b606293>:0)
VRM.VRMBlendShapeProxy.OnDestroy () (at <90680c4cfd344736904ce6584b606293>:0)

[Error  : Unity Log] FileNotFoundException: Could not load file or assembly 'UnityEditor.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null' or one of its dependencies.
Stack trace:
VRM.BlendShapeMerger.RestoreMaterialInitialValues (System.Collections.Generic.IEnumerable`1[T] clips) (at <90680c4cfd344736904ce6584b606293>:0)
VRM.VRMBlendShapeProxy.OnDestroy () (at <90680c4cfd344736904ce6584b606293>:0)

[Warning: Unity Log] 08/17/2025 20:03:03: Local player destroyed

[Error  : Unity Log] FileNotFoundException: Could not load file or assembly 'UnityEditor.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null' or one of its dependencies.
Stack trace:
VRM.BlendShapeMerger.RestoreMaterialInitialValues (System.Collections.Generic.IEnumerable`1[T] clips) (at <90680c4cfd344736904ce6584b606293>:0)
VRM.VRMBlendShapeProxy.OnDestroy () (at <90680c4cfd344736904ce6584b606293>:0)

[Info   : Unity Log] 08/17/2025 20:03:03: Lost connection to server:ErrorDisconnected
```

## Analysis

Exceptions occur in `VRM.VRMBlendShapeProxy.OnDestroy` via `VRM.BlendShapeMerger.RestoreMaterialInitialValues`.

During that call the runtime attempts to resolve `UnityEditor.CoreModule` and throws `FileNotFoundException`.
