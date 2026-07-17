if not Platform then return end
local hasGL4 = false
local hasGL41Core = false
local hasUniformBuffers = false
local hasGLSL420Pack = false
local hasComputeShaders = false
local hasShaderStorageBuffers = false
local hasImageLoadStore = false
local hasAtomicCounterBuffers = false
local hasMultiDrawIndirect = false
local hasGL = false
local hasShaders = false
local hasFBO = false
local isSyncedCode = (SendToUnsynced ~= nil)
local capabilities = {}

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
	hasUniformBuffers = hasShaders and gl.GetVBO and supports('glSupportUniformBuffers') or false
	hasGLSL420Pack = hasShaders and supports('glSupportGLSL420Pack') or false
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

	for i = 1, #allRequires do
		local capability = capabilities[allRequires[i]]
		if capability ~= nil and not capability then
			return false
		end
	end
	return true
end

local function extendPlatform()
	capabilities.gl = hasGL
	capabilities.gl4 = hasGL4
	capabilities.gl41 = hasGL41Core
	capabilities.ubo = hasUniformBuffers
	capabilities.glsl420pack = hasGLSL420Pack
	capabilities.shaders = hasShaders
	capabilities.fbo = hasFBO
	capabilities.compute = hasComputeShaders
	capabilities.ssbo = hasShaderStorageBuffers
	capabilities.imageLoadStore = hasImageLoadStore
	capabilities.atomicCounters = hasAtomicCounterBuffers
	capabilities.multiDrawIndirect = hasMultiDrawIndirect

	Platform.gl = Platform.gl or hasGL
	Platform.gl4 = Platform.gl4 or hasGL4
	Platform.gl41 = Platform.gl41 or hasGL41Core
	Platform.ubo = Platform.ubo or hasUniformBuffers
	Platform.glsl420pack = Platform.glsl420pack or hasGLSL420Pack
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
