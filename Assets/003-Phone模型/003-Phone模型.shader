Shader "Unlit/Phone"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
	_Color("Color",COLOR) = (1,1,1,1)
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

		    fixed4 _Color;
		
            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 color :COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
				//顶点Phone模型
				//漫反射模型
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//worldLight = UnityWorldSpaceLightDir((0,0,0));
				fixed3 color = _LightColor0.rgb* _Color * saturate(dot(worldNormal, worldLight));
				color += ambient;
				o.color = color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = float4(i.color,1);
                return col;
            }
            ENDCG
        }
    }
}
