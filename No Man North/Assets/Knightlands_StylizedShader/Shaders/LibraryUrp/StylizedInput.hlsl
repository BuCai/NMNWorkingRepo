#ifndef QUIBLI_STYLIZED_INPUT_INCLUDED
#define QUIBLI_STYLIZED_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)

// --- Compatibility with Simple Lit.
half _Smoothness;

float4 _BaseMap_ST;
half4 _BaseColor;

float4 _FacialMap_ST;
float4 _FacialMouthMap_ST;
// -----------------------------

half _Cutoff;
half _Surface;

half _Emission;
half4 _EmissionColoreo;

half4 _ColorMultiplier;

// --- DR_SPECULAR_ON
half4 _FlatSpecularColor;
float _FlatSpecularSize;
float _FlatSpecularEdgeSmoothness;
// --- DR_SPECULAR_ON

half _Metallic;
int _MetallicSwitch;

// --- DR_RIM_ON
half4 _FlatRimColor;
float _FlatRimSize;
float _FlatRimEdgeSmoothness;
float _FlatRimLightAlign;
// --- DR_RIM_ON

// --- DR_GRADIENT_ON
half4 _ColorGradient;
half _GradientCenterX;
half _GradientCenterY;
half _GradientSize;
half _GradientAngle;
// --- DR_GRADIENT_ON

half _SelfShadingSize;
half _LightContribution;

half _OverrideLightmapDir;
half3 _LightmapDirection;

half4 _LightAttenuation;
half4 _ShadowColor;
half _ShadowSoftness;

float4 _DetailMap_ST;
half _DetailMapImpact;
half4 _DetailMapColor;

half4 _OutlineColor;
half _OutlineWidth;
half _OutlineScale;
half _OutlineDepthOffset;
half _CameraDistanceImpact;

CBUFFER_END

inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData = (SurfaceData)0;

    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
   
    outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
    AlphaDiscard(outSurfaceData.alpha, _Cutoff);
    outSurfaceData.albedo = albedoAlpha.rgb;

    #ifdef _ALPHAPREMULTIPLY_ON
    outSurfaceData.albedo *= outSurfaceData.alpha;
    #endif
    
    outSurfaceData.metallic = _Metallic; // unused
    outSurfaceData.specular = 0.0; // unused
    outSurfaceData.smoothness = _Smoothness; // unused
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
    outSurfaceData.occlusion = 1.0; // unused
    outSurfaceData.emission = SampleEmission(uv, _EmissionColoreo.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); //_EmissionColor.rgb;
    
}

half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
    return specularSmoothness;
}

#endif  // QUIBLI_STYLIZED_INPUT_INCLUDED
