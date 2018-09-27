// 
// fx_pre_ped_noMRT.fx
//

//---------------------------------------------------------------------
// Variables
//---------------------------------------------------------------------
float3 sElementOffset = float3(0,0,0);
float3 sWorldOffset = float3(0,0,0);

float3 sCameraPosition = float3(0,0,0);
float3 sCameraForward = float3(0,0,0);
float3 sCameraUp = float3(0,0,0);

float sFov = 1;
float sAspect = 1;
float2 sMoveObject2D = float2(0,0);
float2 sScaleObject2D = float2(1,1);
float sAlphaMult = 1;
float sProjZMult = 2;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
texture gTexture0 < string textureState="0,Texture"; >;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gWorld : WORLD;
float4x4 gWorldView : WORLDVIEW;
texture secondRT < string renderTarget = "yes"; >;
int gLighting < string renderState="LIGHTING"; >;  
float4 gGlobalAmbient < string renderState="AMBIENT"; >;
int gAmbientMaterialSource < string renderState="AMBIENTMATERIALSOURCE"; >;
int gDiffuseMaterialSource < string renderState="DIFFUSEMATERIALSOURCE"; >;
int gEmissiveMaterialSource < string renderState="EMISSIVEMATERIALSOURCE"; >; 
float4 gMaterialAmbient < string materialState="Ambient"; >;
float4 gMaterialDiffuse < string materialState="Diffuse"; >;
float4 gMaterialSpecular < string materialState="Specular"; >;
float4 gMaterialEmissive < string materialState="Emissive"; >;
int CUSTOMFLAGS <string createNormals = "yes"; string skipUnusedParameters = "yes"; >;
float4 gTextureFactor < string renderState="TEXTUREFACTOR"; >;          

//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord0 : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord0 : TEXCOORD0;
  float3 Normal : TEXCOORD1;
};

//--------------------------------------------------------------------------------------
// createViewMatrix
//--------------------------------------------------------------------------------------
float4x4 createViewMatrix( float3 pos, float3 fwVec, float3 upVec )
{
    float3 zaxis = normalize( fwVec);    // The "forward" vector.
    float3 xaxis = normalize( cross( -upVec, zaxis ));// The "right" vector.
    float3 yaxis = cross( xaxis, zaxis );     // The "up" vector.

    // Create a 4x4 view matrix from the right, up, forward and eye position vectors
    float4x4 viewMatrix = {
        float4(      xaxis.x,            yaxis.x,            zaxis.x,       0 ),
        float4(      xaxis.y,            yaxis.y,            zaxis.y,       0 ),
        float4(      xaxis.z,            yaxis.z,            zaxis.z,       0 ),
        float4(-dot( xaxis, pos ), -dot( yaxis, pos ), -dot( zaxis, pos ),  1 )
    };
    return viewMatrix;
}

//------------------------------------------------------------------------------------------
// createProjectionMatrix
//------------------------------------------------------------------------------------------
float4x4 createProjectionMatrix(float near_plane, float far_plane, float fov_horiz, float fov_aspect, float2 ss_mov, float2 ss_scale)
{
    float h, w, Q;

    w = 1/tan(fov_horiz * 0.5);
    h = w/fov_aspect;
    Q = far_plane/(far_plane - near_plane);

    // Create a 4x4 projection matrix from given input

    float4x4 projectionMatrix = {
        float4(w * ss_scale.x, 0,              0,             0),
        float4(0,              h * ss_scale.y, 0,             0),
        float4(ss_mov.x,       ss_mov.y,       Q,             1),
        float4(0,              0,             -Q*near_plane,  0)
    };    
    return projectionMatrix;
}

//------------------------------------------------------------------------------------------
// MTACalcGTABuildingDiffuse
//------------------------------------------------------------------------------------------
float4 MTACalcGTABuildingDiffuse( float4 InDiffuse )
{
    float4 OutDiffuse;

    if ( !gLighting )
    {
        // If lighting render state is off, pass through the vertex color
        OutDiffuse = InDiffuse;
    }
    else
    {
        // If lighting render state is on, calculate diffuse color by doing what D3D usually does
        float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
        float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
        float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
        OutDiffuse = gGlobalAmbient * saturate( ambient + emissive );
        OutDiffuse.a *= diffuse.a;
    }
    return OutDiffuse;
}

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Fix some stuff
    if (VS.Normal.x == 0 && VS.Normal.y == 0 && VS.Normal.z == 0) VS.Normal = float3(0,0,1);
	VS.Position.xyz += normalize(VS.Normal) * 0.000f;
	
    // Vertex in world position
    float4 wPos = mul(float4(VS.Position, 1), gWorld);
    wPos.xyz += sWorldOffset;

    // Create view matrix	
    float4x4 sView = createViewMatrix(sCameraPosition, sCameraForward, sCameraUp);
    float4 vPos = mul(wPos, sView);
    vPos.xzy += sElementOffset;

    // Create projection matrix
    float sFarClip = gProjectionMainScene[3][2] / (1 - gProjectionMainScene[2][2]);
    float sNearClip = gProjectionMainScene[3][2] / - gProjectionMainScene[2][2];
    float4x4 sProjection = createProjectionMatrix(sNearClip, sFarClip, sFov, sAspect, sMoveObject2D, sScaleObject2D);
    PS.Position = mul(vPos, sProjection);
    PS.Position.z *= 0.00625 * sProjZMult;
	
    // Pass through tex coord
    PS.TexCoord0 = VS.TexCoord0;
	
    // Set information to do specular calculation in PS
	float4x4 sWorldView = mul(gWorld, sView);
    PS.Normal =  mul(VS.Normal.xyz, (float3x3)sWorldView);

    // Calculate GTA lighting
    float Diffa = MTACalcGTABuildingDiffuse(VS.Diffuse).a;
    PS.Diffuse = float4(0.35, 0.35, 0.3, Diffa);
	
    return PS;
}

//---------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//---------------------------------------------------------------------
struct Pixel
{
    float4 Color : COLOR0;      // Render target #0
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunction(PSInput PS)
{
    Pixel output;

    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord0);

    // Apply texture and multiply by vertex color
    float4 finalColor = texel * PS.Diffuse;
	
    // Apply specular
    float dotProduct = dot(float3(0,0,-1), PS.Normal);
    finalColor.rgb += saturate(dotProduct) * texel.rgb * 0.45;
	
    // Main render target
    output.Color = saturate(finalColor);
    output.Color.a *= sAlphaMult;
	
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique fx_pre_ped_noMRT
{
    pass P0
    {
        FogEnable = false;
        AlphaBlendEnable = true;
        AlphaRef = 1;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
