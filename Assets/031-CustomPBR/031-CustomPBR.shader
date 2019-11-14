Shader "Unlit/031-CustomPBR"
{
    Properties
    {
		_Color("Color",color) = (1,1,1,1)//漫发射颜色
		_MainTex("Albedo",2D) = "white"{}//材质纹理
		_Glossiness("Smoothness",Range(0.0,1.0)) = 0.5//材质粗糙程度
		_SpecColor("Specular",Color) = (0.2,0.2,0.2)//高光反射颜色
		_SpecGlossMap("Specular (RGB) Smoothness(A)",2D) = "white"{}
		_BumpScale("Bump Scale",Float) = 1.0//凹凸程度
		_BumpMap("Normal Map",2D) = "bump"{}//法线纹理
		_EmissionColor("Color",COLOR) = (0,0,0)//自发光颜色
		_EmissionMap("Emission",2D) = "white"{}//自发光纹理
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
//			Tags{"LightMode" = "ForwardBase"}
//            CGPROGRAM
//			//相较2.0可包含更多的数学指令数目
//			#pragma target 3.0 

//			#pragma multi_compile_fwdbase
//            #pragma multi_compile_fog

//            #pragma vertex vert
//            #pragma fragment frag
//            #include "UnityCG.cginc"
//			#include "AutoLight.cginc"

//            struct v2f
//            {
//			float4 pos: SV_POSITION;
//			float2 uv:TEXCOORD0;
//			float2 TtoW0:TEXCOORD1;
//			float2 TtoW1:TEXCOORD2;
//			float2 TtoW2:TEXCOORD3;
//			SHADOW_COORDS(4);
//			UNITY_FOG_COORDS(5);
//            };

//            v2f vert (appdata_full v2f)
//            {
//                v2f o;
//				UNITY_INITIALIZE_OUTPUT(v2f,o);
//				o.pos = UnityObjectToClipPos(v.vertex);
//				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

//				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
//				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
//				fixed3 worldTangent = UnityObjectToWorldDir(v.tanget.xyz);
//				fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

//				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
//				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
//				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

//				TRANSFER_SHADOW(o);

//				UNITY_TRANSFER_FOG(o,o.pos);

//                return o;
//            }

//            fixed4 frag (v2f i) : SV_Target
//            {
//				half4 specGloss = tex2D(_SpecGlossMap,i.uv);
//				specGloss.a += _Glossiness;
//				half3 specColor = specGloss.rgb * _SpecColor.rgb;
//				half oneMinusReflectivity = 1-max(max(specColor.r,specColor.g),specColor.b);

//				half diffColor = _Color.rgb*tex2D(_MainTex,i.uv).rgb*oneMinusReflectivity;

//				half3 normalTangent = UnpackNormal(tex2D(_BumMap,i.uv));
//				normalTangent.xy *= _BumpScale;
//				normalTangent.z = sqrt(1.0 - saturate(dot(normalTangent.xy,normalTangent.xy)));
//				half3 normalWorld = normalize(half3(
//					dot(i.TtoW0.xyz,normalTangent),
//					dot(i.TtoW1.xyz,normalTangent),
//					dot(i.TtoW2.xyz,normalTangent)));
//				half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
//				half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
//				half3 refDir = reflect(-viewDir,normalWorld);
//				UNITY_LIGHT_ATTENUATTON(atten,i,worldPos);
//                return col;
//            }
            //ENDCG
        }
    }
}
