Shader "Unlit/Texture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	_Specular("Specular",COLOR) = (1,1,1,1)
	_Gloss("Gloss",Range(0,256)) = 32
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

			fixed4 _Specular;
	fixed4 _Diffuce;
	float _Gloss;
	sampler2D _MainTex;
	uniform float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;//纹理
				float3 worldNormal : TEXCOORD1;//世界空间下的法线
				float3 vertexWorldPos : TEXCOORD2;//世界空间下的顶点坐标
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertexWorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//顶点Phone模型
				fixed3 worldNormal = normalize(i.worldNormal);
				//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
			    fixed3 worldLight = UnityWorldSpaceLightDir(i.vertexWorldPos);

				//漫反射半兰伯特模型
				fixed intensity = saturate(dot(worldNormal, worldLight));
				fixed3 albedo = tex2D(_MainTex, i.uv);
				fixed3 diffuce = albedo * _LightColor0.rgb * _Diffuce * intensity;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//Blinn-Phone高光反射
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorldPos.xyz);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				intensity = pow(saturate(dot(halfDir, i.worldNormal)), _Gloss);
				fixed3 specular = _Specular * _LightColor0.rgb*intensity;

				fixed3 color = ambient + diffuce + specular;
				//color = float3( intensity, intensity, intensity);

                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
