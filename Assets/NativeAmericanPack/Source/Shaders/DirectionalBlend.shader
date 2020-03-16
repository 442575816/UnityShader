// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GabroMedia/DirectionalBlend"
{
	Properties
	{
		[HideInInspector]_SandGrunge("SandGrunge", 2D) = "white" {}
		_Grunge_Offset("Grunge_Offset", Range( 0 , 1)) = 0
		_Sand1_Basecolor("Sand1_Basecolor", 2D) = "white" {}
		_Sand2_Basecolor("Sand2_Basecolor", 2D) = "white" {}
		_BlendPower("BlendPower", Range( 0.2 , 1)) = 0.5
		_Sand1_Normal("Sand1_Normal", 2D) = "bump" {}
		_Sand2_Normal("Sand2_Normal", 2D) = "bump" {}
		_Sand1_SmoothnessA("Sand1_Smoothness(A)", 2D) = "white" {}
		_Sand2_Smoothness("Sand2_Smoothness", 2D) = "white" {}
		[IntRange]_Sand2_Tiling("Sand2_Tiling", Range( 0 , 8)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Sand1_Normal;
		uniform float4 _Sand1_Normal_ST;
		uniform sampler2D _Sand2_Normal;
		uniform float _Sand2_Tiling;
		uniform sampler2D _SandGrunge;
		uniform float _Grunge_Offset;
		uniform float _BlendPower;
		uniform sampler2D _Sand1_Basecolor;
		uniform float4 _Sand1_Basecolor_ST;
		uniform sampler2D _Sand2_Basecolor;
		uniform sampler2D _Sand1_SmoothnessA;
		uniform float4 _Sand1_SmoothnessA_ST;
		uniform sampler2D _Sand2_Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Sand1_Normal = i.uv_texcoord * _Sand1_Normal_ST.xy + _Sand1_Normal_ST.zw;
			float2 temp_cast_0 = (_Sand2_Tiling).xx;
			float2 uv_TexCoord48 = i.uv_texcoord * temp_cast_0;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 objToWorldDir8 = mul( unity_ObjectToWorld, float4( ase_vertexNormal, 0 ) ).xyz;
			float2 temp_cast_1 = (_Grunge_Offset).xx;
			float2 uv_TexCoord22 = i.uv_texcoord + temp_cast_1;
			float temp_output_36_0 = pow( ( saturate( objToWorldDir8.y ) * tex2D( _SandGrunge, uv_TexCoord22 ).r ) , _BlendPower );
			float3 lerpResult43 = lerp( UnpackNormal( tex2D( _Sand1_Normal, uv_Sand1_Normal ) ) , UnpackNormal( tex2D( _Sand2_Normal, uv_TexCoord48 ) ) , temp_output_36_0);
			float3 normalizeResult56 = normalize( lerpResult43 );
			o.Normal = normalizeResult56;
			float2 uv_Sand1_Basecolor = i.uv_texcoord * _Sand1_Basecolor_ST.xy + _Sand1_Basecolor_ST.zw;
			float4 lerpResult31 = lerp( tex2D( _Sand1_Basecolor, uv_Sand1_Basecolor ) , tex2D( _Sand2_Basecolor, uv_TexCoord48 ) , temp_output_36_0);
			o.Albedo = lerpResult31.rgb;
			float2 uv_Sand1_SmoothnessA = i.uv_texcoord * _Sand1_SmoothnessA_ST.xy + _Sand1_SmoothnessA_ST.zw;
			float lerpResult46 = lerp( tex2D( _Sand1_SmoothnessA, uv_Sand1_SmoothnessA ).a , tex2D( _Sand2_Smoothness, uv_TexCoord48 ).a , temp_output_36_0);
			o.Smoothness = lerpResult46;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17400
1927;7;1906;1005;4063.284;1731.039;3.562875;True;True
Node;AmplifyShaderEditor.RangedFloatNode;29;-3220.528,1245.331;Float;True;Property;_Grunge_Offset;Grunge_Offset;1;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;7;-3014,906.8572;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2885.729,1189.279;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;8;-2757.001,910.8572;Inherit;True;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;49;-2518.131,-287.6526;Inherit;True;Property;_Sand2_Tiling;Sand2_Tiling;9;1;[IntRange];Create;True;0;0;False;0;1;0;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;6;-2394,914.8572;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-2511.604,1147.239;Inherit;True;Property;_SandGrunge;SandGrunge;0;1;[HideInInspector];Create;True;0;0;False;0;-1;85a9d3890305fd1469e97b9bf61f6973;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-2173.649,-324.6491;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-2295.718,775.2866;Inherit;False;Property;_BlendPower;BlendPower;4;0;Create;True;0;0;False;0;0.5;0.3;0.2;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2018.763,1017.544;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;-1595.998,-69.14377;Inherit;True;Property;_Sand2_Normal;Sand2_Normal;6;0;Create;True;0;0;False;0;-1;d4f91167f15bef3449aace411d2ddeb7;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;36;-1749.059,960.3461;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-1601.998,-273.1439;Inherit;True;Property;_Sand1_Normal;Sand1_Normal;5;0;Create;True;0;0;False;0;-1;d4f91167f15bef3449aace411d2ddeb7;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-1585.279,-519.0204;Inherit;True;Property;_Sand2_Basecolor;Sand2_Basecolor;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-1597.137,387.6525;Inherit;True;Property;_Sand2_Smoothness;Sand2_Smoothness;8;0;Create;True;0;0;False;0;-1;3a3694da791ab9e40ba52aef3122b8bb;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-1591.379,199.3253;Inherit;True;Property;_Sand1_SmoothnessA;Sand1_Smoothness(A);7;0;Create;True;0;0;False;0;-1;3a3694da791ab9e40ba52aef3122b8bb;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;43;-485.7354,79.51184;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;30;-1596.279,-755.0206;Inherit;True;Property;_Sand1_Basecolor;Sand1_Basecolor;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;31;-785.8844,-491.356;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;46;-573.9084,532.2644;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;56;-247.3425,63.63617;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;113,-9;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;GabroMedia/DirectionalBlend;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;1;29;0
WireConnection;8;0;7;0
WireConnection;6;0;8;2
WireConnection;20;1;22;0
WireConnection;48;0;49;0
WireConnection;39;0;6;0
WireConnection;39;1;20;1
WireConnection;42;1;48;0
WireConnection;36;0;39;0
WireConnection;36;1;35;0
WireConnection;32;1;48;0
WireConnection;45;1;48;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;43;2;36;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;36;0
WireConnection;46;0;44;4
WireConnection;46;1;45;4
WireConnection;46;2;36;0
WireConnection;56;0;43;0
WireConnection;0;0;31;0
WireConnection;0;1;56;0
WireConnection;0;4;46;0
ASEEND*/
//CHKSM=68DAF12BB27D190E723E622A9CBC1AC8E6EB740C