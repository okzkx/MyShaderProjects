Shader "MyShaders/010-Cartoon_Color"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
		_Steps("_Steps",Range(1,30)) = 5
		_ToonEffect("_ToonEffect",Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque"}
		LOD 100

		Pass
		{
			Name "Lighting"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuce;
			fixed _Steps;
			fixed _ToonEffect;
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
				fixed3 lightDir_world = normalize( UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir_world = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//漫反射
				fixed diffuse_intencity = saturate(dot( i.worldNormal,lightDir_world));
				//实现漫反射光照分层
				//光强离散化
				fixed toon = floor(diffuse_intencity*_Steps)/_Steps;
				diffuse_intencity = lerp(diffuse_intencity,toon,_ToonEffect);

				fixed3 diffuse = _LightColor0 * tex2D(_MainTex,i.uv) * diffuse_intencity;

				fixed3 color = ambient + diffuse;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
