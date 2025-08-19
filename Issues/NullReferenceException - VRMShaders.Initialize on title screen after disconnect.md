# Issue

## Description

Disconnecting from a server and returning to the title screen causes the title-screen avatar to fail to load. The log shows that the `UniVrm.shaders` AssetBundle attempts to load again and Unity reports it's already loaded, followed by a `NullReferenceException` originating from `VRMShaders.Initialize()`.

## Resolution

Made `VRMShaders.Initialize()` idempotent; It's safe to call multiple times by early-returning after the first call.

After caching the shaders, call `assetBundle.Unload(false)` to release the bundle reference.

## Logs

```text
[Info   : Unity Log] 08/18/2025 00:15:40: Render threading mode:MultiThreaded

[Error  : Unity Log] The AssetBundle 'S:\Steam\steamapps\common\Valheim\BepInEx\plugins\ValheimVRM\UniVrm.shaders' can't be loaded because another AssetBundle with the same files is already loaded.
[Error  : Unity Log] NullReferenceException: Object reference not set to an instance of an object
Stack trace:
ValheimVRM.VRMShaders.Initialize () (at <b45c788d918a477383e67afad7142c56>:0)
ValheimVRM.MainPlugin.PatchAll () (at <b45c788d918a477383e67afad7142c56>:0)
ValheimVRM.PatchFejdStartup.Postfix () (at <b45c788d918a477383e67afad7142c56>:0)
(wrapper dynamic-method) FejdStartup.DMD<FejdStartup::Awake>(FejdStartup)

[Info   : Unity Log] 08/18/2025 00:15:40: Checking for installed DLCs

[Info   : Unity Log] 08/18/2025 00:15:40: DLC:beta installed:False
```

## Analysis

- `PatchFejdStartup.Postfix()` invokes `MainPlugin.PatchAll()` whenever the title screen (`FejdStartup.Awake`) runs. Returning to the title screen after disconnect triggers `PatchAll()` again.
- `PatchAll()` calls `VRMShaders.Initialize()` unconditionally.
- `VRMShaders.Initialize()` loads `UniVrm.shaders` via `AssetBundle.LoadFromFile`. On the second run, Unity reports the bundle is already loaded and returns `null`, leading to an NRE when `LoadAllAssets<Shader>()` is invoked on a null bundle.

Hypothesis: The shader bundle load is not idempotent and lacks null checks. Subsequent initializations after disconnect cause a duplicate-load attempt and NRE.
