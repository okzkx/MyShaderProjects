Shader "MyShaders/008-AlphaBlend"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1))=1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		LOD 100

		//Pass
		//{
		//	ZWrite On
		//	ColorMask 0
		//}

		Pass
		{

			Tags {  "LightMode" = "ForwardBase"}
			//透明混合需要关闭深度写入,
			ZWrite off
			//正常混合 片段颜色 * 片段因子 + 缓存颜色*(1-片段因子)
			Blend SrcAlpha OneMinusSrcAlpha

			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed _AlphaScale;
			//主贴图
			sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			struct v2f {
				//裁剪空间
				float4 vertex : SV_POSITION;
				//纹理
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_tan v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				albedo.a = _AlphaScale ;

				return fixed4(albedo);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
