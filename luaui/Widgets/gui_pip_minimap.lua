-- This widget replaces the standard minimap with a PIP-style minimap
-- It uses pipNumber = 0 to trigger minimap replacement mode in gui_pip.lua
-- Features:
--   - Positioned at top-left like standard minimap
--   - No screen margin restrictions (edge-to-edge)
--   - No minimize button (always visible)
--   - Calls DrawInMiniMap overlays from other widgets during R2T rendering

-- The PIP implementation depends on the engine's full GL4 feature route.  A
-- macOS OpenGL 4.1 Core context deliberately reports glHaveGL4=false because
-- compute/SSBO/image-load-store are unavailable.  Do not let this widget hide
-- the native minimap and then fail to render its replacement on that route.
if not Platform.glHaveGL4 then
	widget.GetInfo = function()
		return {
			name      = "Picture-in-Picture Minimap",
			desc      = "Replaces minimap with an interactive PIP-style map view.",
			author    = "Floris",
			version   = "1.0",
			date      = "January 2026",
			license   = "GNU GPL, v2 or later",
			layer     = -99000,
			enabled   = false,
			handler   = true,
		}
	end

	return widget
end

pipNumber = 0  -- Triggers minimap mode in gui_pip.lua

VFS.Include("LuaUI/Widgets/gui_pip.lua")


-- Override GetInfo to change the name and layer
widget.GetInfo = function()
	return {
		name      = "Picture-in-Picture Minimap",
		desc      = "Replaces minimap with an interactive PIP-style map view. Supports panning, zooming, and unit tracking.",
		author    = "Floris",
		version   = "1.0",
		date      = "January 2026",
		license   = "GNU GPL, v2 or later",
		layer     = -99000,
		enabled   = true,
		handler   = true,
	}
end

return widget
