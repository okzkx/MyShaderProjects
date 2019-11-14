Shader "MyShaders/006-SpecularMask"
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

			//默认颜色
			fixed4 _Diffuce;
			fixed4 _Specular;
			//程度调整
			float _Gloss;
			//纹理贴图
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;

				float3 light_t:TEXCOORD4;
				float3 view_t:TEXCOORDD5;
			};

			v2f vert(appdata_tan v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				TANGENT_SPACE_ROTATION;
				o.light_t = normalize(mul(rotation,ObjSpaceLightDir(v.vertex))).xyz;
				o.view_t = normalize(mul(rotation, ObjSpaceViewDir(v.vertex))).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 normal_packed = tex2D(_BumpMap,i.uv);
				fixed3 normal_t = UnpackNormal(normal_packed) * _BumpScale;

				fixed3 albedo = tex2D(_MainTex, i.uv);
				fixed intensity = saturate(dot(i.light_t, normal_t))*0.5+0.5;
				fixed3 diffuce = albedo * _LightColor0.rgb * _Diffuce.rgb * intensity;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed3 halfDir = normalize(i.view_t + i.light_t);
				fixed3 SpecularMaskIntensity = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				intensity = pow(saturate(dot(halfDir, normal_t)), _Gloss) * SpecularMaskIntensity;
				fixed3 specular = _Specular.rgb * _LightColor0.rgb*intensity;

				fixed3 color = specular + ambient + diffuce ;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
