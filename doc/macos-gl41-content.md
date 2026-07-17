# macOS OpenGL 4.1 content compatibility

BAR consumes the granular OpenGL capabilities published by RecoilEngine's
experimental macOS compatibility path. `common/platformFunctions.lua` exposes
these as capability aliases and dependency names:

| Dependency | `Platform` alias | Engine capability |
| --- | --- | --- |
| `gl41` | `Platform.gl41` | `glSupportGL41Core` |
| `compute` | `Platform.compute` | `glSupportComputeShaders` |
| `ssbo` | `Platform.ssbo` | `glSupportShaderStorageBuffers` |
| `imageLoadStore` | `Platform.imageLoadStore` | `glSupportImageLoadStore` |
| `atomicCounters` | `Platform.atomicCounters` | `glSupportAtomicCounterBuffers` |
| `multiDrawIndirect` | `Platform.multiDrawIndirect` | `glSupportMultiDrawIndirect` |

Widgets and unsynced gadgets can list the smallest required set in their
`GetInfo().depends` table. For example, a compute shader backed by an SSBO uses:

```lua
depends = {'compute', 'ssbo'},
```

The existing `gl4` dependency remains the full enhanced renderer tier. On
older engines that do not expose granular fields, the new requirements fall
back to `Platform.glHaveGL4`; this preserves compatibility without claiming
support on a known OpenGL 4.1 context.

Apple's system OpenGL does not provide compute shaders, SSBOs, image
load/store, atomic counters, or multi-draw indirect. Content declaring those
requirements is therefore disabled before initialization instead of failing
during shader compilation or buffer creation.

This is capability plumbing, not a complete playable macOS port. RecoilEngine
still has compatibility-profile rendering calls that must be migrated before
its graphical client can run in a macOS 4.1 Core context. Vulkan through
MoltenVK/Metal remains a possible long-term renderer direction and is outside
this compatibility change.
