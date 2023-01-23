Shader "Knightlands/Stylized"
{
    Properties
    {
        _ColorMultiplier("Global Base Color",  Color) = (1,1,1,1)

        [Space(20)]
        [Gradient] _GradientRampHighLight("Highlight Color Gradient", 2D) = "black" {}
        [Gradient] _GradientRamp("Shadow Color Gradient", 2D) = "white" {}

        [Space]
        _SelfShadingSize ("[]Shading Offset", Range(0, 1.0)) = 0.0

        [Space(20)]
        [Toggle(DR_SPECULAR_ON)] _SpecularEnabled("Enable Specular Highlight", Int) = 0
        [HDR] _FlatSpecularColor("[DR_SPECULAR_ON]Specular Color", Color) = (0.85023, 0.85034, 0.85045, 0.85056)
        _FlatSpecularSize("[DR_SPECULAR_ON]Specular Size", Range(0.0, 1.0)) = 0.1
        _FlatSpecularEdgeSmoothness("[DR_SPECULAR_ON]Specular Edge Smoothness", Range(0.0, 1.0)) = 0

        [Space (20)]
        [Toggle] _MetallicSwitch("Enable Metallic PBR workflow", Int) = 0
        _Metallic("Metallic", Range(0.0, 1.0)) = 1
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5    

        [Space]
        [Toggle(DR_OUTLINE_ON)] _OutlineEnabled("Enable Outline", Int) = 1
        _OutlineColor("[DR_OUTLINE_ON]Color", Color) = (0, 0, 0, 1)
        _OutlineWidth("[DR_OUTLINE_ON]Width", Float) = 1.0
        _OutlineScale("[DR_OUTLINE_ON]Scale", Float) = 1.0
        _OutlineDepthOffset("[DR_OUTLINE_ON]Depth Offset", Range(0, 1)) = 0.0
        _CameraDistanceImpact("[DR_OUTLINE_ON]Camera Distance Impact", Range(0, 1)) = 0.5

        [Space(10)]
        [Toggle(DR_RIM_ON)] _RimEnabled("Enable Rim", Int) = 0
        [HDR] _FlatRimColor("[DR_RIM_ON]Rim Color", Color) = (0.85023, 0.85034, 0.85045, 0.85056)
        _FlatRimLightAlign("[DR_RIM_ON]Light Align", Range(0.0, 1.0)) = 0
        _FlatRimSize("[DR_RIM_ON]Rim Size", Range(0, 1)) = 0.5
        _FlatRimEdgeSmoothness("[DR_RIM_ON]Rim Edge Smoothness", Range(0, 1)) = 0.5

        [Space(10)]
        [Toggle(DR_GRADIENT_ON)] _GradientEnabled("Enable Height Gradient", Int) = 1
        [HideInInspector][MainColor] _BaseColor ("Color", Color) = (1,1,1,1)
        _ColorGradient("[DR_GRADIENT_ON]Gradient Color", Color) = (0.85023, 0.85034, 0.85045, 0.85056)
        _GradientCenterX("[DR_GRADIENT_ON]Center X", Float) = 0
        _GradientCenterY("[DR_GRADIENT_ON]Center Y", Float) = 0
        _GradientSize("[DR_GRADIENT_ON]Size", Float) = 10.0
        _GradientAngle("[DR_GRADIENT_ON]Gradient Angle", Range(0, 360)) = 0

        [MainTex]_BaseMap("[FOLDOUT(Texture maps){4}] Albedo", 2D) = "white" {}
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissionColoreo("Emission Color", Color) = (0,0,0)
        _BumpMap (" Normal Map", 2D) = "bump" {}
        
        //_LightContribution("[FOLDOUT(Lighting){11}]Light Color Impact", Range(0, 1)) = 1
        
        [HideInInspector][Toggle] _ReceiveShadows("[FOLDOUT(Lighting){11}]Receive Shadows", Float) = 0
        _ShadowColor("[DR_LIGHT_ATTENUATION]Shadow Color", Color) = (.7, .7, .7, 1)
        _ShadowSoftness ("[]Shadow Softness", Range (0.01, 1)) = 0.05
        [Space][HideInInspector][Toggle(DR_LIGHT_ATTENUATION)]_OverrideLightAttenuation("Override Realtime Shadow", Int) = 1
        [HideInInspector]_LightAttenuation("[DR_LIGHT_ATTENUATION]Shadow Attenuation Remap", Vector) = (0.75, 0.9, 0, 0)

        //[Toggle(_UNITYSHADOW_OCCLUSION)]_UnityShadowOcclusion("Shadow Occlusion", Int) = 0

        //[Space][Toggle(DR_BAKED_GI)]_OverrideBakedGi("Override Baked GI", Int) = 0
        [Gradient]_BakedGIRamp("[DR_BAKED_GI]Baked Light Lookup", 2D) = "transparent" {}

        [Space]
        //[Toggle(DR_ENABLE_LIGHTMAP_DIR)]_OverrideLightmapDir("Override Light Direction", Int) = 0
        _LightmapDirectionPitch("[DR_ENABLE_LIGHTMAP_DIR][]Pitch", Range(0, 360)) = 0
        _LightmapDirectionYaw("[DR_ENABLE_LIGHTMAP_DIR][]Yaw", Range(0, 360)) = 0
        [HideInInspector] _LightmapDirection("Direction", Vector) = (0, 1, 0, 0)

        [HideInInspector]_Cutoff ("Base Alpha cutoff", Range (0, 1)) = .5

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}



        /*
                  [MainTex] _BaseMap ("Base Map", 2D) = "white" { }
        [MainColor][HDR]  _Color ("Color", Color) = (1, 1, 1, 1)
        _BlurStrength("Blur Strength", Range(0, 1)) = 1
        _Gloss("Gloss", Range(0, 1)) = 1
        _Thickness("Thickness", Range(0, 1)) = 0.5

        _Thick("Outline Thickness",  Range(0, 0.1)) = 1 // The amount to extrude the outline mesh
        _OutlineColor ("Color", Color) = (1, 1, 1, 1) // The outline color
        _DepthOffset("Depth offset", Range(0,1)) = 0 // An oofset to the clip space Z, pushing the outline back
        // If enabled, this shader will use "smoothed" normals stored in TEXCOORD1 to extrude along
        [Toggle(USE_PRECALCULATED_OUTLINE_NORMALS)]_PrecalculateNormals("Use UV1 normals", Float) = 0

        */

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"
        }
        LOD 300

      /*   Pass
         {
          Tags
          {
            "LightMode" = "UniversalForward"
          }

             // Cull Off
             Blend SrcAlpha OneMinusSrcAlpha
             ZWrite Off

             CGPROGRAM
                 #pragma vertex vert
                 #pragma fragment frag
                 
                 #include "UnityCG.cginc"
     
                 struct appdata_t
                 {
                     float4 vertex : POSITION;
                     float2 texcoord : TEXCOORD0;
                     fixed4 color : COLOR;
                 };
     
                 struct v2f
                 {
                     float4 vertex : SV_POSITION;
                     half2 texcoord : TEXCOORD0;
                     fixed4 color : COLOR;
                 };
     
                 sampler2D _BaseMap;
                 float4 _BaseMap_ST;
                 fixed4 _ColorMultiplier;

                 v2f vert (appdata_t v)
                 {
                     v2f o;
                     o.vertex = UnityObjectToClipPos(v.vertex);
                     o.texcoord = TRANSFORM_TEX(v.texcoord, _BaseMap);
                     o.color = v.color;
                     return o;
                 }
                 

                 fixed4 frag (v2f i) : COLOR
                 {
                     fixed4 col = tex2D(_BaseMap, i.texcoord) * i.color * _ColorMultiplier;

                     return col;
                 }
             ENDCG
         }*/
        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature_local DR_LIGHT_ATTENUATION
            #pragma shader_feature_local DR_BAKED_GI
            #pragma shader_feature_local DR_GRADIENT_ON
            #pragma shader_feature_local DR_SPECULAR_ON
            #pragma shader_feature_local DR_RIM_ON
            #pragma shader_feature_local DR_VERTEX_COLORS_ON
            #pragma shader_feature_local DR_MASK_RECOLOR_ON
            #pragma shader_feature_local DR_ENABLE_LIGHTMAP_DIR
            #pragma shader_feature_local _TEXTUREBLENDINGMODE_MULTIPLY _TEXTUREBLENDINGMODE_ADD
            #pragma shader_feature_local _UNITYSHADOW_OCCLUSION

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
            // #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"
            #if VERSION_GREATER_EQUAL(11, 0)
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #else
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #endif
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #if VERSION_GREATER_EQUAL(12, 0)
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING
            #endif

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #if VERSION_GREATER_EQUAL(12, 0)
            // #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #endif

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #define BUMP_SCALE_NOT_SUPPORTED 1
            #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR 1
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_GradientRamp);
            SAMPLER(sampler_GradientRamp);

            TEXTURE2D(_GradientRampHighLight);
            SAMPLER(sampler_GradientRampHighLight);

            TEXTURE2D(_BakedGIRamp);
            SAMPLER(sampler_BakedGIRamp);

            // Detail map.
            #pragma shader_feature_local_fragment _DETAILMAPBLENDINGMODE_MULTIPLY _DETAILMAPBLENDINGMODE_ADD _DETAILMAPBLENDINGMODE_INTERPOLATE

            TEXTURE2D(_DetailMap);
            SAMPLER(sampler_DetailMap);

            #pragma vertex LitPassVertex
            #pragma fragment StylizedPassFragment

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "LibraryUrp/LitForwardPass_DR.hlsl"
            #include "LibraryUrp/QuibliVertex.hlsl"
            #include "LibraryUrp/Lighting_DR.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "SRPDefaultUnlit" 
            }

            Cull Front

            HLSLPROGRAM
            //#define sampler_BaseMap
            // #include "UnityCG.cginc"
            #include "LibraryUrp/StylizedInput.hlsl"
            
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #pragma multi_compile _ DR_OUTLINE_ON
            #pragma multi_compile_fog
            
            struct VertexInput
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 vcolor : COLOR;
                float2 uv_BaseMap : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
                float4 vcolor : COLOR;
                float fogCoord : TEXCOORD1;
                float2 uv_BaseMap : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 ObjectToClipPos(float4 pos) {
                return mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(pos.xyz, 1)));
            }


            VertexOutput VertexProgram(VertexInput v) {
                VertexOutput o;

                UNITY_SETUP_INSTANCE_ID(v);

                o = (VertexOutput)0;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                #if defined(DR_OUTLINE_ON)
                float4 clipPosition = ObjectToClipPos(v.position * _OutlineScale);
                const float3 clipNormal = mul((float3x3)UNITY_MATRIX_VP, mul((float3x3)UNITY_MATRIX_M, v.normal));
                const half outlineWidth = _OutlineWidth;
                const half cameraDistanceImpact = lerp(clipPosition.w, 4.0, _CameraDistanceImpact);
                const float2 aspectRatio = float2(_ScreenParams.x / _ScreenParams.y, 1);
                const float2 offset = normalize(clipNormal.xy) / aspectRatio * outlineWidth * cameraDistanceImpact * 0.005;
                clipPosition.xy += offset;
                const half outlineDepthOffset = _OutlineDepthOffset;

                #if UNITY_REVERSED_Z
                clipPosition.z -= outlineDepthOffset * 0.1;
                #else
                clipPosition.z += outlineDepthOffset * 0.1 * (1.0 - UNITY_NEAR_CLIP_VALUE);
                #endif

                o.position = clipPosition;
                o.normal = clipNormal;
                o.vcolor = v.vcolor;
                o.uv_BaseMap = v.uv_BaseMap;

                o.fogCoord = ComputeFogFactor(o.position.z);
                #endif

                return o;
            }


            half4 FragmentProgram(VertexOutput i) : SV_TARGET {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                return _OutlineColor;

            }
            ENDHLSL
        }

 
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"
            #if VERSION_GREATER_EQUAL(11, 0)
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #endif

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            ZWrite[_ZWrite]
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
            // #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"
            #if VERSION_GREATER_EQUAL(11, 0)
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #else
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #endif
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #if VERSION_GREATER_EQUAL(12, 0)
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING
            #endif

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitGBufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            Cull Off

            HLSLPROGRAM
            #define _SpecColor _BaseColor
            #define _SpecGlossMap _BaseMap
            #define sampler_SpecGlossMap sampler_BaseMap
            #define _EmissionMap _BaseColorMap
            #define _EmissionColor _BaseColor

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            // #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "Universal2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
            Tags
            {
                "RenderType" = "Transparent" "Queue" = "Transparent"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            #include "LibraryUrp/StylizedInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }
    }

   
    CustomEditor "Quibli.KnightlandsEditor"
}
