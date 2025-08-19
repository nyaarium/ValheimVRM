# Issue

## Description

When a player dies in Valheim, the VRM avatar goes into a T-pose instead of maintaining proper death/ragdoll animation.

## Resolution

Implemented ragdoll pose mirroring so the VRM remains visible and follows the physics-driven ragdoll:

- Parent the VRM to the ragdoll on `Humanoid.OnRagdollCreated` and keep VRM renderers enabled.
- Keep vanilla ragdoll renderers hidden to avoid double visuals.
- In `VRMAnimationSync`, when in ragdoll mode, copy each human bone's position and rotation from the ragdoll animator to the VRM every LateUpdate (with existing model Y-offset).

Result: No T-pose on death; the VRM cleanly mirrors ragdoll physics. Respawn retains the existing VRM setup flow.

## Logs

N/A

## Analysis

1. **VRMAnimationSync** component synchronizes the original Valheim player animator with the VRM model animator
2. In `LateUpdate()`, it copies human pose data from the original animator to the VRM animator using `HumanPoseHandler`
3. The system works by:
   - Getting pose from original animator: `orgPose.GetHumanPose(ref hp)`
   - Setting pose to VRM animator: `vrmPose.SetHumanPose(ref hp)`

### Death/Ragdoll Handling

**OnRagdollCreated patch** (lines 431-460 in ValheimVRM.cs):
- When player dies, a ragdoll is created
- VRM model is reparented to the ragdoll: `vrm.transform.SetParent(ragdoll.transform)`
- VRMAnimationSync is reconfigured with ragdoll animator: `vrm.GetComponent<VRMAnimationSync>().Setup(ragAnim, Settings.GetSettings(VrmManager.PlayerToName[player]), true)`

**OnDeath patch** (lines 498-511 in ValheimVRM.cs):
- Only handles destroying `VRMEyePositionSync` component
- **Missing proper VRM death state handling**
