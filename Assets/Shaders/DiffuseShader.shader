Shader "Unlit/DiffuseShader"
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
            };

            fixed4 _Color;
            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 漫反射公式 brightness = dot(normal, lightDir)  pixColor = brightness * lightColor * surfaceColor
                float3 normalDirection = normalize(i.worldNormal);
				float4 tex = tex2D(_DiffuseTex, i.uv);
				float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
				float4 diffuseTerm = nl * _Color * tex * _LightColor0;
				return diffuseTerm;
            }
            ENDCG
        }
    }
}
