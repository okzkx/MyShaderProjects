Shader "Unlit/007-AlphaTest"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Specular("Specular",COLOR) = (1,1,1,1)
		_Gloss("Gloss",Range(1,256)) = 32
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
		_BumpMap("BumpMap",2D) = "white"{}
		_BumpScale("BumpScale",float) = 1
		_SpecularMask("SpecularMask",2D) = "white"{}
		_SpecularScale("SpecularScale",float) = 1
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.2
	}
	SubShader
	{
		Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" }
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
			fixed _Cutoff;
			//主贴图
			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			//法线贴图
			sampler2D _BumpMap;
			uniform float4 _BumpMap_ST;
			float _BumpScale;
			//高光贴图
			sampler2D _SpecularMask;
			uniform float4 _SpecularMask_ST;
			float _SpecularScale;

			struct v2f {
				//裁剪空间
				float4 vertex : SV_POSITION;
				//纹理
				float2 uv : TEXCOORD0;
				float2 specularMask_uv:TEXCOORD1;
				float2 bump_uv:TEXCOORD3;//
				//切线空间
				float3 lightDir:TEXCOORD4;
				float3 viewDir:TEXCOORDD5;
			};

			v2f vert(appdata_tan v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.bump_uv = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.specularMask_uv = TRANSFORM_TEX(v.texcoord, _SpecularMask);

				TANGENT_SPACE_ROTATION;
				o.lightDir = normalize(mul(rotation,ObjSpaceLightDir(v.vertex))).xyz;
				o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex))).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 packednormal = tex2D(_BumpMap,i.bump_uv);
			    fixed3 tangentNormal = UnpackNormal(packednormal) * _BumpScale;

				fixed4 albedo = tex2D(_MainTex, i.uv);
				if (albedo.a<_Cutoff) {
					discard;
				}

				//漫反射半兰伯特模型
				fixed intensity = saturate(dot(i.lightDir, tangentNormal))*0.5+0.5;
				fixed3 diffuce = albedo * _LightColor0.rgb * _Diffuce.rgb * intensity;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//Blinn-Phone高光反射
				fixed3 halfDir = normalize(i.viewDir + i.lightDir);
				fixed3 SpecularMaskIntensity = tex2D(_SpecularMask, i.specularMask_uv).r * _SpecularScale;
				intensity = pow(saturate(dot(halfDir, tangentNormal)), _Gloss) * SpecularMaskIntensity;
				fixed3 specular = _Specular.rgb * _LightColor0.rgb*intensity;

				fixed3 color = specular + ambient + diffuce ;

				return fixed4(color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
