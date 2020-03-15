﻿Shader "Unlit/HalfLambert"
{
    Properties
    {
        _Color("DiffuseColor", Color) = (1, 1, 1, 1)
        _DiffuseTex("Texture", 2D) = "white" {}
        _Ambient("Ambient", Range(0, 1)) = 0.25
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD0;
                fixed3 color : COLOR;
            };

            fixed4 _Color;
            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);

				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 漫反射公式 brightness = dot(normal, lightDir)  pixColor = brightness * lightColor * surfaceColor
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
				fixed3 color = _LightColor0.rgb * _Color.rgb * halfLambert + ambient;
				float4 tex = tex2D(_DiffuseTex, i.uv);

				return fixed4(color * tex, 1);
            }
            ENDCG
        }
    }
}
