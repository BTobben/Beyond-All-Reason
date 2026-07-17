if not Platform then return end
local hasGL4 = false
local hasGL41Core = false
local hasComputeShaders = false
local hasShaderStorageBuffers = false
local hasImageLoadStore = false
local hasAtomicCounterBuffers = false
local hasMultiDrawIndirect = false
local hasGL = false
local hasShaders = false
local hasFBO = false
local isSyncedCode = (SendToUnsynced ~= nil)

local function determineCapabilities()
	if not gl then
		return
	end
	if Platform.glVendor ~= "" then
		hasGL = true
	end
	if gl.CreateShader and Platform.glHaveGLSL then
		hasShaders = true
	end
	if gl.CreateFBO then
		hasFBO = true
	end

	if hasFBO and hasShaders and Platform.glHaveGL4 then
		hasGL4 = true
	end

	-- Older GL4 engines do not publish the granular fields. Falling back to
	-- glHaveGL4 keeps existing installations compatible while newer engines
	-- can report each feature accurately.
	local function supports(featureName)
		local supported = Platform[featureName]
		if supported == nil then
			return hasGL4
		end
		return supported
	end

	hasGL41Core = hasShaders and Platform.glSupportGL41Core == true
	hasComputeShaders = hasShaders and gl.DispatchCompute and supports('glSupportComputeShaders') or false
	hasShaderStorageBuffers = gl.GetVBO and supports('glSupportShaderStorageBuffers') or false
	hasImageLoadStore = gl.BindImageTexture and supports('glSupportImageLoadStore') or false
	hasAtomicCounterBuffers = supports('glSupportAtomicCounterBuffers')
	hasMultiDrawIndirect = gl.GetVAO and supports('glSupportMultiDrawIndirect') or false
end

local function checkRequires(allRequires)
	if not allRequires or isSyncedCode then
		return true
	end

	local capabilities = {
		gl = hasGL,
		gl4 = hasGL4,
		gl41 = hasGL41Core,
		shaders = hasShaders,
		fbo = hasFBO,
		compute = hasComputeShaders,
		ssbo = hasShaderStorageBuffers,
		imageLoadStore = hasImageLoadStore,
		atomicCounters = hasAtomicCounterBuffers,
		multiDrawIndirect = hasMultiDrawIndirect,
	}

	for i = 1, #allRequires do
		local capability = capabilities[allRequires[i]]
		if capability ~= nil and not capability then
			return false
		end
	end
	return true
end

local function extendPlatform()
	Platform.gl = Platform.gl or hasGL
	Platform.gl4 = Platform.gl4 or hasGL4
	Platform.gl41 = Platform.gl41 or hasGL41Core
	Platform.compute = Platform.compute or hasComputeShaders
	Platform.ssbo = Platform.ssbo or hasShaderStorageBuffers
	Platform.imageLoadStore = Platform.imageLoadStore or hasImageLoadStore
	Platform.atomicCounters = Platform.atomicCounters or hasAtomicCounterBuffers
	Platform.multiDrawIndirect = Platform.multiDrawIndirect or hasMultiDrawIndirect
	Platform.glHaveFBO = Platform.glHaveFBO or hasFBO
	Platform.check = checkRequires
end

determineCapabilities()
extendPlatform()
