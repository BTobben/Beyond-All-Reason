#version 410 core

//__DEFINES__

// InfoLOS uses only its own uniforms; avoid unused engine UBO injection on GL 4.1.

layout (location = 0) in vec4 position; // [-1,1], [0,1] , xyuv

out DataVS {
    vec4 texCoord;
};

void main(void)	{
    texCoord = position.zwzw;
    gl_Position    = vec4(position.xy * 1.0, 0.00, 1);	
}
