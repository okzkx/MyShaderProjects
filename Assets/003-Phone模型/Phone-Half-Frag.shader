Shader "Unlit/Half_Lanboter"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
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
		
            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal :NORMAL;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//顶点Phone模型
				fixed3 worldLight = UnityWorldSpaceLightDir(i.vertex.xyz);

				//漫反射半兰伯特模型
				fixed intensity = saturate(dot(i.worldNormal, worldLight));
				fixed3 diffuce = _LightColor0.rgb* _Diffuce * intensity;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//高光反射
				fixed3 reflectDir = normalize(reflect(worldLight,i.worldNormal));
				fixed3 viewDir = normalize(WorldSpaceViewDir(i.vertex));
				fixed3 specular = _Specular * _LightColor0.rgb*pow(max(0,dot(reflectDir, viewDir)), _Gloss);

				fixed3 color = ambient + diffuce + specular;
				//color = viewDir;

                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
