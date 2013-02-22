
-- Vertex

attribute vec4 Position;

void main()
{
    gl_Position = Position;
}

-- Fill

varying lowp vec3 FragColor;
precision mediump float;
void main()
{
    lowp vec3 temp = vec3(1, 0, 0);
    FragColor = temp;
}

-- Advect

precision mediump float;
varying lowp vec4 FragColor;
uniform sampler2D VelocityTexture;
uniform sampler2D SourceTexture;
uniform sampler2D Obstacles;

uniform lowp vec2 InverseSize;
uniform float TimeStep;
uniform float Dissipation;
uniform float solid;
void main()
{
    lowp vec2 fragCoord = gl_FragCoord.xy;

    float solid = texture2D(Obstacles, InverseSize * fragCoord,0.0).x;
    if (solid > 0.0) {
        lowp vec4 temp = vec4(0);
        FragColor = temp;
        return;
    }

    lowp vec2 u = texture2D(VelocityTexture, InverseSize * fragCoord,0.0).xy;
    lowp vec2 coord = InverseSize * (fragCoord - TimeStep * u);
    lowp vec4 temp2 = Dissipation * texture2D(SourceTexture, coord,0.0);
    FragColor = temp2;
}

-- Jacobi

varying lowp vec4 FragColor;
precision mediump float;
uniform sampler2D Pressure;
uniform sampler2D Divergence;
uniform sampler2D Obstacles;

uniform float Alpha;
uniform float InverseBeta;

void main()
{
    ivec2 T = ivec2(gl_FragCoord.xy);

    // Find neighboring pressure:
    lowp vec4 pN = texelFetchOffset(Pressure, T, 0, ivec2(0, 1));
    lowp vec4 pS = texelFetchOffset(Pressure, T, 0, ivec2(0, -1));
    lowp vec4 pE = texelFetchOffset(Pressure, T, 0, ivec2(1, 0));
    lowp vec4 pW = texelFetchOffset(Pressure, T, 0, ivec2(-1, 0));
    lowp vec4 pC = texelFetch(Pressure, T, 0);

    // Find neighboring obstacles:
    lowp vec3 oN = texelFetchOffset(Obstacles, T, 0, ivec2(0, 1)).xyz;
    lowp vec3 oS = texelFetchOffset(Obstacles, T, 0, ivec2(0, -1)).xyz;
    lowp vec3 oE = texelFetchOffset(Obstacles, T, 0, ivec2(1, 0)).xyz;
    lowp vec3 oW = texelFetchOffset(Obstacles, T, 0, ivec2(-1, 0)).xyz;

    // Use center pressure for solid cells:
    if (oN.x > 0) pN = pC;
    if (oS.x > 0) pS = pC;
    if (oE.x > 0) pE = pC;
    if (oW.x > 0) pW = pC;

    lowp vec4 bC = texelFetch(Divergence, T, 0);
    FragColor = (pW + pE + pS + pN + Alpha * bC) * InverseBeta;
}

-- SubtractGradient

varying lowp vec2 FragColor;
precision mediump float;
uniform sampler2D Velocity;
uniform sampler2D Pressure;
uniform sampler2D Obstacles;
uniform float GradientScale;

void main()
{
    ivec2 T = ivec2(gl_FragCoord.xy);

    lowp vec3 oC = texelFetch(Obstacles, T, 0).xyz;
    if (oC.x > 0) {
        FragColor = oC.yz;
        return;
    }

    // Find neighboring pressure:
    float pN = texelFetchOffset(Pressure, T, 0, ivec2(0, 1)).r;
    float pS = texelFetchOffset(Pressure, T, 0, ivec2(0, -1)).r;
    float pE = texelFetchOffset(Pressure, T, 0, ivec2(1, 0)).r;
    float pW = texelFetchOffset(Pressure, T, 0, ivec2(-1, 0)).r;
    float pC = texelFetch(Pressure, T, 0).r;

    // Find neighboring obstacles:
    lowp vec3 oN = texelFetchOffset(Obstacles, T, 0, ivec2(0, 1)).xyz;
    lowp vec3 oS = texelFetchOffset(Obstacles, T, 0, ivec2(0, -1)).xyz;
    lowp vec3 oE = texelFetchOffset(Obstacles, T, 0, ivec2(1, 0)).xyz;
    lowp vec3 oW = texelFetchOffset(Obstacles, T, 0, ivec2(-1, 0)).xyz;

    // Use center pressure for solid cells:
    lowp vec2 obstV = vec2(0);
    lowp vec2 vMask = vec2(1);

    if (oN.x > 0) { pN = pC; obstV.y = oN.z; vMask.y = 0; }
    if (oS.x > 0) { pS = pC; obstV.y = oS.z; vMask.y = 0; }
    if (oE.x > 0) { pE = pC; obstV.x = oE.y; vMask.x = 0; }
    if (oW.x > 0) { pW = pC; obstV.x = oW.y; vMask.x = 0; }

    // Enforce the free-slip boundary condition:
    lowp vec2 oldV = texelFetch(Velocity, T, 0).xy;
    lowp vec2 grad = vec2(pE - pW, pN - pS) * GradientScale;
    lowp vec2 newV = oldV - grad;
    FragColor = (vMask * newV) + obstV;  
}

-- ComputeDivergence
precision mediump float;
varying float FragColor;

uniform sampler2D Velocity;
uniform sampler2D Obstacles;
uniform float HalfInverseCellSize;

void main()
{
    ivec2 T = ivec2(gl_FragCoord.xy);

    // Find neighboring velocities:
    lowp vec2 vN = texelFetchOffset(Velocity, T, 0, ivec2(0, 1)).xy;
    lowp vec2 vS = texelFetchOffset(Velocity, T, 0, ivec2(0, -1)).xy;
    lowp vec2 vE = texelFetchOffset(Velocity, T, 0, ivec2(1, 0)).xy;
    lowp vec2 vW = texelFetchOffset(Velocity, T, 0, ivec2(-1, 0)).xy;

    // Find neighboring obstacles:
    lowp vec3 oN = texelFetchOffset(Obstacles, T, 0, ivec2(0, 1)).xyz;
    lowp vec3 oS = texelFetchOffset(Obstacles, T, 0, ivec2(0, -1)).xyz;
    lowp vec3 oE = texelFetchOffset(Obstacles, T, 0, ivec2(1, 0)).xyz;
    lowp vec3 oW = texelFetchOffset(Obstacles, T, 0, ivec2(-1, 0)).xyz;

    // Use obstacle velocities for solid cells:
    if (oN.x > 0) vN = oN.yz;
    if (oS.x > 0) vS = oS.yz;
    if (oE.x > 0) vE = oE.yz;
    if (oW.x > 0) vW = oW.yz;

    FragColor = HalfInverseCellSize * (vE.x - vW.x + vN.y - vS.y);
}

-- Splat

varying lowp vec4 FragColor;
precision mediump float;
precision mediump vec4;
uniform lowp vec2 Point;
uniform float Radius;
uniform lowp vec3 FillColor;

void main()
{
    float d = distance(Point, gl_FragCoord.xy);
    if (d < Radius) {
        float a = (Radius - d) * 0.5;
        a = min(a, 1.0);
        FragColor = vec4(FillColor, a);
    } else {
        FragColor = vec4(0);
    }
}

-- Buoyancy

varying lowp vec2 FragColor;
precision mediump float;
uniform sampler2D Velocity;
uniform sampler2D Temperature;
uniform sampler2D Density;
uniform float AmbientTemperature;
uniform float TimeStep;
uniform float Sigma;
uniform float Kappa;

void main()
{
    ivec2 TC = ivec2(gl_FragCoord.xy);
    float T = texelFetch(Temperature, TC, 0).r;
    lowp vec2 V = texelFetch(Velocity, TC, 0).xy;

    FragColor = V;

    if (T > AmbientTemperature) {
        float D = texelFetch(Density, TC, 0).x;
        FragColor += (TimeStep * (T - AmbientTemperature) * Sigma - D * Kappa ) * vec2(0, 1);
    }
}

-- Visualize

varying lowp vec4 FragColor;
uniform sampler2D Sampler;
uniform lowp vec3 FillColor;
uniform lowp vec2 Scale;
precision mediump float;
void main()
{
    float L = texture(Sampler, gl_FragCoord.xy * Scale).r;
    FragColor = vec4(FillColor, L);
}
