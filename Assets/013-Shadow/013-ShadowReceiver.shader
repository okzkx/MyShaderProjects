Shader "MyShaders/013-ShadowReceiver"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ShadowPower("_ShadowPower",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD0;
                float3 worldNormal :  TEXCOORD1;
				float2 uv:TEXCOORD2;
                //UNITY_FOG_COORDS(1)
				SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _ShadowPower;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				//shadow *= _ShadowPower; 
				//col = fixed4(shadow,shadow,shadow,1);
                return atten;
            }
            ENDCG
        }
    }

}
