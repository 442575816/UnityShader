Shader "Unlit/SpecularShader"
{
    Properties
    {
        _Color("_Color", Color) = (1, 0, 1, 1)
        _DiffuseTex("Texture", 2D) = "white" {}
        _Ambient("Ambient", Range(0, 1)) = 0.25
        _SpecColor("Specular Material Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Float) = 10
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
            #pragma multi_compile_fwdbase
           
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
                float4 vertexWorld : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;
            float _Ambient;
            float _Shininess;

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 镜面反射 2 * (N.L) * N - L
                float3 normalDirection = normalize(i.worldNormal);
                float3 viewDirecttion = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
                float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

                // 采样纹理
				float4 tex = tex2D(_DiffuseTex, i.uv);

                // 漫反射计算
				float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
				float4 diffuseTerm = nl * _Color * tex * _LightColor0;

                // 镜面反射计算
                float3 reflectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirecttion, reflectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;
				//计算最终颜色
				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;
            }
            ENDCG
        }
    }
}
