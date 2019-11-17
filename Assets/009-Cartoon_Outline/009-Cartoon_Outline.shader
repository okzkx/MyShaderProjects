Shader "MyShaders/009-Cartoon_Outline"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)

		_OutLineScale("OutLine Scale",Range(0,0.05)) =0.002
		_OutLineColor("OutLine Color",Color) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque"}
		LOD 100

		// 先渲染 边缘
		Pass {
			Name "Outline"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed _OutLineScale;
			fixed3 _OutLineColor;

			struct v2f{
				float4 vertex : SV_POSITION;
			}
			;
			v2f vert(appdata_base v) {
				v2f o;
				//局部空间(世界空间同样的原理)边缘沿法线拓展,:效果不好
				fixed3 vertex = v.normal * _OutLineScale + v.vertex;
				o.vertex = UnityObjectToClipPos(vertex);

				//裁剪空间沿法线拓展
				fixed4 vertex_clip = UnityObjectToClipPos(v.vertex);
				fixed3 normal_view = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
				fixed3 normal_clip = TransformViewToProjection(normal_view);
				o.vertex = vertex_clip;
				o.vertex.xy += normal_clip * _OutLineScale;
				return o;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(_OutLineColor,1);
			}


			ENDCG

		
		}

		//在渲染物体
		Pass
		{
			Name "Lighting"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuce;
			//主贴图
			sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			struct v2f {
				//裁剪空间
				float4 vertex : SV_POSITION;
				//纹理
				float2 uv : TEXCOORD0;
				//世界空间
				float3 worldNormal: TEXCOORD1;
				float3 worldPos: TEXCOORD2;
			};

			v2f vert(appdata_base v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal( v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 lightDir = UnityWorldSpaceLightDir(i.worldPos);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed diffuse_intencity = saturate(dot( i.worldNormal,lightDir));
				fixed3 diffuse = _LightColor0 * tex2D(_MainTex,i.uv) * diffuse_intencity;

				fixed3 color = ambient + diffuse;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
