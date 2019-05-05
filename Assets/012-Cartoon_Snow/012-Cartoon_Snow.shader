Shader "Unlit/012-Cartoon_Snow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Diffuce("Diffuce",COLOR) = (1,1,1,1)
		_Steps("_Steps",Range(1,30)) = 5
		_ToonEffect("_ToonEffect",Range(0,1)) = 0.5
		_RimColor("RimColor",COLOR) = (0,1,0,1)
		_RimScale("_RimScale",Range(0,3)) = 1
		_XRayColor("XRayColor",COLOR) = (0,0,1,1)
		_XRayScale("_XRayPower",Range(0,3)) = 1

		_OutLineScale("OutLine Scale",Range(0,0.05)) =0.002
		_OutLineColor("OutLine Color",Color) = (0,0,0,1)

		//_Snow("Snow",)
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
			Name "XRay"
			Tags{ "ForceNoShadowCasting" = "true" }
			Blend SrcAlpha One
			ZWrite off
			ZTest Greater
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _XRayColor;
			float _XRayScale;

			struct v2f{
				fixed4 vertex:SV_POSITION;
				fixed3 position_world:TEXCOORD0;
				fixed3 normal_world:TEXCOORD1;
			};
			
			v2f vert(appdata_base v){
				v2f o;
				o.vertex = UnityObjectToClipPos( v.vertex);
				o.position_world = mul(unity_ObjectToWorld,v.vertex);
				o.normal_world = normalize(UnityObjectToWorldNormal(v.normal));
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET{

				fixed3 viewDir_world = normalize(UnityWorldSpaceLightDir(i.position_world));

				fixed xray_intencity = pow(1-abs(dot(viewDir_world,i.normal_world)),1/_XRayScale);
				
				return _XRayColor * xray_intencity;
				 
			}
			ENDCG
		}

		Pass {
			Name "OutLine"
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
				//fixed3 vertex = v.normal * _OutLineScale + v.vertex;
				//o.vertex = UnityObjectToClipPos(vertex);

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
			fixed3 _RimColor;
			fixed _RimScale;
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

				//边缘光
				fixed rim = 1-abs( dot(viewDir_world,i.worldNormal));
				fixed3 rimLight = _RimColor * pow(rim,1/_RimScale);

				fixed3 color = ambient + diffuse + rimLight;

				//宏定义
				//#if SNOW_ON
				//雪
				if(_SnowLevel>0){
					fixed snowLevel = dot( i.worldNormal, _SnowDir);
					snowLevel -= (1 - _SnowLevel);
					//snowLevel = max(snowLevel,0);
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
