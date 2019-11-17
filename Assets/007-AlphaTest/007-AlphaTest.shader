Shader "MyShaders/007-AlphaTest"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
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

			//主贴图
			sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			fixed _Cutoff;

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				if (albedo.a<_Cutoff) {
					discard;
				}

				return albedo;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
