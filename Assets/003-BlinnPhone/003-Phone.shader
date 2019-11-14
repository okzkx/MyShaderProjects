Shader "MyShaders/003-Phone"
{
    Properties
    {
		_Specular("Specular",COLOR) = (1,1,1,1)
		_Gloss("Gloss",Range(1,256)) = 32
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
	}
	SubShader
	{
        Pass
        {
			Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

			fixed4 _Specular;
			fixed4 _Diffuce;
			float _Gloss;
		
            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 normal_w : TEXCOORD1;//世界空间下的法线
				float3 vertex_w : TEXCOORD2;//世界空间下的顶点坐标
            };

            v2f vert (a2v v)
            {
                v2f o;
				// object space to projection space
                 o.vertex = UnityObjectToClipPos(v.vertex);
				//底层 o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal_w = UnityObjectToWorldNormal(v.normal);
				//底层 o.normal_w = mul(v.normal, (float3x3)_World2Object);
				o.vertex_w = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//Caculat datas
				fixed3 normal_w = normalize(i.normal_w);
			    fixed3 light_w = UnityWorldSpaceLightDir(i.vertex_w);
				//底层 fixed3 light_w = normalize(_WorldSpaceLightPos0.xyz);

				//Lamber diffuse model
				fixed intensity = saturate(dot(normal_w, light_w));
				fixed3 diffuce = _LightColor0.rgb * _Diffuce * intensity;

				//ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//Phone高光反射
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_w));
				//底层 fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertex_w.xyz);
				viewDir = reflect(-viewDir,normal_w);
				intensity = pow(saturate(dot(viewDir,light_w)), _Gloss);
				fixed3 specular = _Specular * _LightColor0.rgb*intensity;

				fixed3 color = ambient + diffuce + specular;

                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
