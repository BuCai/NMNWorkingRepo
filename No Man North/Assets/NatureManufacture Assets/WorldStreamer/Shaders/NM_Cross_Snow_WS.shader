Shader "NatureManufacture/URP/Foliage/Cross Snow WS"
{
    Properties
    {
        _AlphaCutoff("Alpha Cutoff", Float) = 0.5
        [NoScaleOffset]_BaseColorMap("Base Map", 2D) = "white" {}
        _TilingOffset("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _HealthyColor("Healthy Color", Color) = (1, 1, 1, 0)
        _DryColor("Dry Color", Color) = (0.8196079, 0.8196079, 0.8196079, 0)
        _ColorNoiseSpread("Color Noise Spread", Float) = 2
        [Normal][NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 8)) = 1
        _AORemapMax("AO Remap Max", Range(0, 1)) = 1
        _SmoothnessRemapMax("Smoothness Remap Max", Range(0, 1)) = 1
        _Specular("Specular", Range(0, 1)) = 0.3
        _Snow_Amount("Snow Amount", Range(0, 2)) = 0
        _SnowBaseColor("Snow Base Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_SnowMaskA("Snow Mask(A)", 2D) = "black" {}
        _SnowMaskTreshold("Snow Mask Treshold", Range(0.1, 6)) = 4
        [ToggleUI]_InvertSnowMask("Invert Snow Mask", Float) = 0
        [NoScaleOffset]_SnowBaseColorMap("Snow Base Map", 2D) = "white" {}
        _SnowTilingOffset("Snow Tiling Offset", Vector) = (1, 1, 0, 0)
        _SnowBlendHardness("Snow Blend Hardness", Range(0, 8)) = 1
        _SnowAORemapMax("Snow AO Remap Max", Range(0, 1)) = 1
        _SnowSmoothnessRemapMax("Snow Smoothness Remap Max", Range(0, 1)) = 1
        _SnowSpecular("Snow Specular", Range(0, 1)) = 0.3
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            float _Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0 = _Specular;
            float4 _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, (_Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0.xxxx), _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2);
            float _Property_cda2dc52405412819df8bf027152ca03_Out_0 = _SnowSpecular;
            float4 _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Property_cda2dc52405412819df8bf027152ca03_Out_0.xxxx), _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2);
            float4 _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3;
            Unity_Lerp_float4(_Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2, _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3);
            float _Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0 = _SmoothnessRemapMax;
            float _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0 = _AORemapMax;
            float4 _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4;
            float3 _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5;
            float2 _Combine_d5268fe722e31e8fb563616026809f3c_RG_6;
            Unity_Combine_float(_Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0, _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0, 0, 0, _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4, _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_d5268fe722e31e8fb563616026809f3c_RG_6);
            float _Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0 = _SnowSmoothnessRemapMax;
            float _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0 = _SnowAORemapMax;
            float4 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4;
            float3 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5;
            float2 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6;
            Unity_Combine_float(_Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0, _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0, 0, 0, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6);
            float3 _Lerp_382c19f948614f82b955834c26134f08_Out_3;
            Unity_Lerp_float3(_Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxx), _Lerp_382c19f948614f82b955834c26134f08_Out_3);
            float _Split_c892f60129203a858bd6cb863f3a99bc_R_1 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[0];
            float _Split_c892f60129203a858bd6cb863f3a99bc_G_2 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[1];
            float _Split_c892f60129203a858bd6cb863f3a99bc_B_3 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[2];
            float _Split_c892f60129203a858bd6cb863f3a99bc_A_4 = 0;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Lerp_e576a35987d3bb8dbade05cc44570778_Out_3.xyz);
            surface.Smoothness = _Split_c892f60129203a858bd6cb863f3a99bc_R_1;
            surface.Occlusion = _Split_c892f60129203a858bd6cb863f3a99bc_G_2;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            float _Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0 = _Specular;
            float4 _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, (_Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0.xxxx), _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2);
            float _Property_cda2dc52405412819df8bf027152ca03_Out_0 = _SnowSpecular;
            float4 _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Property_cda2dc52405412819df8bf027152ca03_Out_0.xxxx), _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2);
            float4 _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3;
            Unity_Lerp_float4(_Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2, _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3);
            float _Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0 = _SmoothnessRemapMax;
            float _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0 = _AORemapMax;
            float4 _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4;
            float3 _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5;
            float2 _Combine_d5268fe722e31e8fb563616026809f3c_RG_6;
            Unity_Combine_float(_Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0, _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0, 0, 0, _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4, _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_d5268fe722e31e8fb563616026809f3c_RG_6);
            float _Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0 = _SnowSmoothnessRemapMax;
            float _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0 = _SnowAORemapMax;
            float4 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4;
            float3 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5;
            float2 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6;
            Unity_Combine_float(_Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0, _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0, 0, 0, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6);
            float3 _Lerp_382c19f948614f82b955834c26134f08_Out_3;
            Unity_Lerp_float3(_Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxx), _Lerp_382c19f948614f82b955834c26134f08_Out_3);
            float _Split_c892f60129203a858bd6cb863f3a99bc_R_1 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[0];
            float _Split_c892f60129203a858bd6cb863f3a99bc_G_2 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[1];
            float _Split_c892f60129203a858bd6cb863f3a99bc_B_3 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[2];
            float _Split_c892f60129203a858bd6cb863f3a99bc_A_4 = 0;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Lerp_e576a35987d3bb8dbade05cc44570778_Out_3.xyz);
            surface.Smoothness = _Split_c892f60129203a858bd6cb863f3a99bc_R_1;
            surface.Occlusion = _Split_c892f60129203a858bd6cb863f3a99bc_G_2;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            float _Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0 = _Specular;
            float4 _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, (_Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0.xxxx), _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2);
            float _Property_cda2dc52405412819df8bf027152ca03_Out_0 = _SnowSpecular;
            float4 _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2;
            Unity_Multiply_float4_float4(_Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Property_cda2dc52405412819df8bf027152ca03_Out_0.xxxx), _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2);
            float4 _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3;
            Unity_Lerp_float4(_Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2, _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3);
            float _Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0 = _SmoothnessRemapMax;
            float _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0 = _AORemapMax;
            float4 _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4;
            float3 _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5;
            float2 _Combine_d5268fe722e31e8fb563616026809f3c_RG_6;
            Unity_Combine_float(_Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0, _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0, 0, 0, _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4, _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_d5268fe722e31e8fb563616026809f3c_RG_6);
            float _Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0 = _SnowSmoothnessRemapMax;
            float _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0 = _SnowAORemapMax;
            float4 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4;
            float3 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5;
            float2 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6;
            Unity_Combine_float(_Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0, _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0, 0, 0, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6);
            float3 _Lerp_382c19f948614f82b955834c26134f08_Out_3;
            Unity_Lerp_float3(_Combine_d5268fe722e31e8fb563616026809f3c_RGB_5, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxx), _Lerp_382c19f948614f82b955834c26134f08_Out_3);
            float _Split_c892f60129203a858bd6cb863f3a99bc_R_1 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[0];
            float _Split_c892f60129203a858bd6cb863f3a99bc_G_2 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[1];
            float _Split_c892f60129203a858bd6cb863f3a99bc_B_3 = _Lerp_382c19f948614f82b955834c26134f08_Out_3[2];
            float _Split_c892f60129203a858bd6cb863f3a99bc_A_4 = 0;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Lerp_e576a35987d3bb8dbade05cc44570778_Out_3.xyz);
            surface.Smoothness = _Split_c892f60129203a858bd6cb863f3a99bc_R_1;
            surface.Occlusion = _Split_c892f60129203a858bd6cb863f3a99bc_G_2;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void CrossFade_float(out float fadeValue){
        if(unity_LODFade.x > 0){
        
        fadeValue = unity_LODFade.x;
        
        }
        
        else{
        
        fadeValue = 1;
        
        }
        }
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        struct Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float
        {
        half4 uv0;
        };
        
        void SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(float Vector1_66FEA85D, Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float IN, out float Alpha_1)
        {
        float _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0;
        CrossFade_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0);
        float _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2;
        Unity_GradientNoise_float(IN.uv0.xy, 20, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2);
        float _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2;
        Unity_Multiply_float_float(_CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _GradientNoise_1246446fd2625a87b95984e897fcac7a_Out_2, _Multiply_fe369763dbcb798b80267ef8a958a564_Out_2);
        float _Property_4526ca2485f7758989de559e794a5658_Out_0 = Vector1_66FEA85D;
        float _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        Unity_Lerp_float(_Multiply_fe369763dbcb798b80267ef8a958a564_Out_2, _Property_4526ca2485f7758989de559e794a5658_Out_0, _CrossFadeCustomFunction_bf6485da69ced985a59fea7452ed98c4_fadeValue_0, _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3);
        Alpha_1 = _Lerp_9a39c2db979afc8abe00d01a22689a5e_Out_3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[0];
            float _Split_23e0470490bacd83973312a833450913_G_2 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[1];
            float _Split_23e0470490bacd83973312a833450913_B_3 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[2];
            float _Split_23e0470490bacd83973312a833450913_A_4 = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_R_1, _Split_23e0470490bacd83973312a833450913_G_2);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0 = float2(_Split_23e0470490bacd83973312a833450913_B_3, _Split_23e0470490bacd83973312a833450913_A_4);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7 = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4 = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2;
            Unity_SimpleNoise_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0, _Property_b618307b57ad3380b3914a2093b7f159_Out_0, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0 = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4 = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7 = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0, _Property_6fad1bea7f828d879b30d1995855944c_Out_0, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0 = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3));
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7 = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0 = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0 = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3 = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4 = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0 = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0 = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3));
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7 = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0 = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3, _Property_53155f8b6e17528993532384c69b45cf_Out_0, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2, _Power_a92be574722606868c966ca3ced4bc87_Out_2);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3, _Power_a92be574722606868c966ca3ced4bc87_Out_2, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_6e5767a03be1738b9024339466ce69f5;
            _CrossFade_6e5767a03be1738b9024339466ce69f5.uv0 = IN.uv0;
            float _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7, _CrossFade_6e5767a03be1738b9024339466ce69f5, _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3.xyz);
            surface.Alpha = _CrossFade_6e5767a03be1738b9024339466ce69f5_Alpha_1;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}