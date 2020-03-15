Shader "Unlit/BlinnPhongRamp"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _RampTex("RampTex", 2D) = "white"{}
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

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _RampTex;
            float4 _RampTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;  
				float2 uv : TEXCOORD2;  
            };

            v2f vert (appdata v)
            {
                v2f o;

                // Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);

                // get tex
                // o.uv = v.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // Or just call the built-in function
				// o.uv.xz = TRANSFORM_TEX(v.texcoord, _MainTex);
                // o.uv.yw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

               
                // Use the texture to sample the diffuse color
				// fixed3 albedo = tex2D(_RampTex, i.uv).rgb * _Diffuse.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Use the texture to sample the diffuse color
				fixed halfLambert  = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Diffuse.rgb;
				
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
