Shader "NatureManufacture/URP/Foliage/Cross WS"
{
    Properties
    {
        _AlphaCutoff("Alpha Cutoff", Float) = 0.5
        [NoScaleOffset]_BaseColorMap("Base Map", 2D) = "white" {}
        _TilingOffset("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _HealthyColor("Healthy Color", Color) = (1, 1, 1, 0)
        _DryColor("Dry Color", Color) = (0.8196079, 0.8196079, 0.8196079, 0)
        _ColorNoiseSpread("Color Noise Spread", Float) = 2
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "white" {}
        _NormalScale("Normal Scale", Range(0, 8)) = 1
        _AORemapMax("AO Remap Max", Range(0, 1)) = 1
        _SmoothnessRemapMax("Smoothness Remap Max", Range(0, 1)) = 1
        _Specular("Specular", Range(0, 1)) = 0.3
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            UnityTexture2D _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.tex, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.samplerstate, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0);
            float _SampleTexture2D_c905db7c22519684a18b680815243193_R_4 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.r;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_G_5 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.g;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_B_6 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.b;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_A_7 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.a;
            float _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0 = _NormalScale;
            float3 _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.xyz), _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0, _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2);
            float _Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0 = _Specular;
            float4 _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2;
            Unity_Multiply_float4_float4(_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2, (_Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0.xxxx), _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2);
            float _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0 = _SmoothnessRemapMax;
            float _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0 = _AORemapMax;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.NormalTS = _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2.xyz);
            surface.Smoothness = _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0;
            surface.Occlusion = _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            UnityTexture2D _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.tex, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.samplerstate, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0);
            float _SampleTexture2D_c905db7c22519684a18b680815243193_R_4 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.r;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_G_5 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.g;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_B_6 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.b;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_A_7 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.a;
            float _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0 = _NormalScale;
            float3 _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.xyz), _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0, _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2);
            float _Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0 = _Specular;
            float4 _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2;
            Unity_Multiply_float4_float4(_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2, (_Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0.xxxx), _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2);
            float _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0 = _SmoothnessRemapMax;
            float _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0 = _AORemapMax;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.NormalTS = _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2.xyz);
            surface.Smoothness = _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0;
            surface.Occlusion = _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
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
            UnityTexture2D _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.tex, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.samplerstate, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0);
            float _SampleTexture2D_c905db7c22519684a18b680815243193_R_4 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.r;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_G_5 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.g;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_B_6 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.b;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_A_7 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.a;
            float _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0 = _NormalScale;
            float3 _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.xyz), _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0, _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2);
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.NormalTS = _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
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
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
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
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            UnityTexture2D _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.tex, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.samplerstate, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0);
            float _SampleTexture2D_c905db7c22519684a18b680815243193_R_4 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.r;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_G_5 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.g;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_B_6 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.b;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_A_7 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.a;
            float _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0 = _NormalScale;
            float3 _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.xyz), _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0, _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2);
            float _Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0 = _Specular;
            float4 _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2;
            Unity_Multiply_float4_float4(_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2, (_Property_d39d4d4be680c6879fa157bbdcef07ce_Out_0.xxxx), _Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2);
            float _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0 = _SmoothnessRemapMax;
            float _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0 = _AORemapMax;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.NormalTS = _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Multiply_c69313900a4a8781a4ff6361b3dccd1f_Out_2.xyz);
            surface.Smoothness = _Property_10da0e40ca132a89b6cb4dd1a4a11f03_Out_0;
            surface.Occlusion = _Property_6e0a4c80174dd586b0af901b561bdf0c_Out_0;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
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
            UnityTexture2D _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.tex, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.samplerstate, _Property_d7a1d75752358886aa5f0ee56fdfeeac_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0);
            float _SampleTexture2D_c905db7c22519684a18b680815243193_R_4 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.r;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_G_5 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.g;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_B_6 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.b;
            float _SampleTexture2D_c905db7c22519684a18b680815243193_A_7 = _SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.a;
            float _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0 = _NormalScale;
            float3 _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_c905db7c22519684a18b680815243193_RGBA_0.xyz), _Property_4c901e3a88bd428ab303c83a8d256a4a_Out_0, _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2);
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.NormalTS = _NormalStrength_97757db4000a6e8faa4fd7b8e1772a8f_Out_2;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
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
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
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
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        
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
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0 = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_b55a426a571e178a997135107d23d8b8_Out_0 = _TilingOffset;
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[0];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[1];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[2];
            float _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4 = _Property_b55a426a571e178a997135107d23d8b8_Out_0[3];
            float2 _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_R_1, _Split_92c4ca7f3ae8c1859a964cca967cda5b_G_2);
            float2 _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0 = float2(_Split_92c4ca7f3ae8c1859a964cca967cda5b_B_3, _Split_92c4ca7f3ae8c1859a964cca967cda5b_A_4);
            float2 _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e06ace66dda1f6808df4b9465e08de91_Out_0, _Vector2_b4ddf86e9558cb8d961fc0a46d838993_Out_0, _TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3);
            float4 _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.tex, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.samplerstate, _Property_a2a2fbbc06138a8aa22a21f50ea93891_Out_0.GetTransformedUV(_TilingAndOffset_7299ce1c4397fb89ab9c19509c6710b4_Out_3));
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_R_4 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.r;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_G_5 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.g;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_B_6 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.b;
            float _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7 = _SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0.a;
            float4 _Property_c4366c0ab8db8185a124799e52f3f46b_Out_0 = _DryColor;
            float4 _Property_f3f61761f146c08cbae4b8877ea79118_Out_0 = _HealthyColor;
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_af7a1d166baa5c8ea086a08f3f14089c_A_4 = 0;
            float2 _Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0 = float2(_Split_af7a1d166baa5c8ea086a08f3f14089c_R_1, _Split_af7a1d166baa5c8ea086a08f3f14089c_B_3);
            float _Property_a641ac4a3256f5839df0e1955879716b_Out_0 = _ColorNoiseSpread;
            float _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2;
            Unity_SimpleNoise_float(_Vector2_0a59235eeb38e38bba8d1bd67095f16b_Out_0, _Property_a641ac4a3256f5839df0e1955879716b_Out_0, _SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2);
            float4 _Lerp_9dafda8c247ac585bf333045384b652e_Out_3;
            Unity_Lerp_float4(_Property_c4366c0ab8db8185a124799e52f3f46b_Out_0, _Property_f3f61761f146c08cbae4b8877ea79118_Out_0, (_SimpleNoise_157fa7d1563a2f85aef2f6ec64e52471_Out_2.xxxx), _Lerp_9dafda8c247ac585bf333045384b652e_Out_3);
            float4 _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_RGBA_0, _Lerp_9dafda8c247ac585bf333045384b652e_Out_3, _Multiply_08bc0d428783878796fa48443ec54fa6_Out_2);
            Bindings_CrossFade_4d5ca88d849f9064994d979167a5556f_float _CrossFade_88396c4fc937dc88bacea2680c435c42;
            _CrossFade_88396c4fc937dc88bacea2680c435c42.uv0 = IN.uv0;
            float _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            SG_CrossFade_4d5ca88d849f9064994d979167a5556f_float(_SampleTexture2D_51476b09426e1b8a9ba59ad0707eaf3a_A_7, _CrossFade_88396c4fc937dc88bacea2680c435c42, _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1);
            float _Property_eb06f9239ca79d8cb88e48352999147c_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_08bc0d428783878796fa48443ec54fa6_Out_2.xyz);
            surface.Alpha = _CrossFade_88396c4fc937dc88bacea2680c435c42_Alpha_1;
            surface.AlphaClipThreshold = _Property_eb06f9239ca79d8cb88e48352999147c_Out_0;
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