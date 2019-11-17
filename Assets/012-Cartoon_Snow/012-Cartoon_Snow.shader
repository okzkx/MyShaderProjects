Shader "Unlit/012-Cartoon_Snow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
		_Steps("_Steps",Range(1,30)) = 5
		_ToonEffect("_ToonEffect",Range(0,1)) = 0.5

		_SnowLevel("_SnowLevel",Range(0,1)) = 0.5 
		_SnowDir("_SnowDir",Vector) = (0,1,0)
		_SnowRim("_SnowRim",Range(0,16)) = 8
		
	}
	SubShader
	{
		Tags { "Queue" = "Geometry +1000" "RenderType" = "Opaque"}
		LOD 100
		
		Pass
		{
			Name "Lighting"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile __ SNOW_ON

			fixed4 _Diffuce;
			fixed _Steps;
			fixed _ToonEffect;
			fixed _SnowLevel;
			fixed3 _SnowDir;
			fixed _SnowRim;
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
				fixed toon = floor(diffuse_intencity*_Steps)/_Steps;//光强离散化
				diffuse_intencity = lerp(diffuse_intencity,toon,_ToonEffect);//越大显示的颜色离散越明显

				fixed3 diffuse = _LightColor0 * tex2D(_MainTex,i.uv) * diffuse_intencity;

				fixed3 color = ambient + diffuse;

				//宏定义
				//#if SNOW_ON
				//雪
				if(_SnowLevel>0){
					fixed snowLevel = dot( i.worldNormal, _SnowDir);
					snowLevel -= (1 - _SnowLevel);
					snowLevel = saturate(snowLevel);

					snowLevel /= _SnowLevel;
					snowLevel = 1 - pow(1-snowLevel,_SnowRim);
					color += snowLevel * fixed4(1,1,1,1);
				}
				//#endif
				return fixed4(color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
