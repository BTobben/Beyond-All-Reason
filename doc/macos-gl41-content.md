# macOS OpenGL 4.1 content compatibility

BAR consumes the granular OpenGL capabilities published by RecoilEngine's
experimental macOS compatibility path. `common/platformFunctions.lua` exposes
these as capability aliases and dependency names:

| Dependency | `Platform` alias | Engine capability |
| --- | --- | --- |
| `gl41` | `Platform.gl41` | `glSupportGL41Core` |
| `ubo` | `Platform.ubo` | `glSupportUniformBuffers` |
| `glsl420pack` | `Platform.glsl420pack` | `glSupportGLSL420Pack` |
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

Shaders using `gl.GetEngineUniformBufferDef` should depend on `ubo`, not on
`glsl420pack`: the paired RecoilEngine branch binds the engine blocks
programmatically on GLSL 4.10. `glsl420pack` is only required by content that
writes `layout(binding=...)` itself and has no 4.10 variant.

The existing `gl4` dependency remains the full enhanced renderer tier. On
older engines that do not expose granular fields, the new requirements fall
back to `Platform.glHaveGL4`; this preserves compatibility without claiming
support on a known OpenGL 4.1 context.

Apple's system OpenGL 4.1 provides UBOs, but does not provide compute shaders, SSBOs, image
load/store, atomic counters, or multi-draw indirect. Content declaring those
requirements is therefore disabled before initialization instead of failing
during shader compilation or buffer creation.

This is capability plumbing and an experimental startup configuration, not a
claim that a full match is playable on macOS. Remaining content render paths
still require runtime verification. Vulkan through MoltenVK/Metal remains a
possible long-term renderer direction and is outside this compatibility
change.

## Development tools in unpacked builds

The experimental app runs BAR from an unpacked `.sdd` directory, which makes
`Spring.Utilities.IsDevMode()` true. On the reduced GL 4.1 route, polling
widget, gadget, and engine-shader reloaders plus the per-frame test harness are
therefore disabled by default. Set `GL41EnableDevTools=1` when those development
tools are deliberately needed; normal full-renderer development checkouts keep
their existing behavior.

## One-command native build

The paired RecoilEngine branch contains `macos-build-bar.sh`. On the Mac it
can fetch this BAR branch (including Git LFS content), install missing Apple
Command Line Tools/Homebrew dependencies, build the engine, assemble an
ad-hoc-signed `Beyond All Reason GL41.app`, and run the GL 4.1 smoke test:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/BTobben/RecoilEngine/agent/macos-gl41-ubo-content/macos-build-bar.sh)"
```

The default output is under `~/BAR-macOS-GL41`. Building directly on the
target Mac is preferred over Linux cross-compilation because the build and
smoke test use Apple's macOS SDK, frameworks, code-signing tools, and native
OpenGL 4.1 driver.
