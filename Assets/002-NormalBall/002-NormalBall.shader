Shader "MyShaders/002-NormalBall"
{
    Properties
    {
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
				o.color = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = float4(i.color,1);
                return col*=_Color;
            }
            ENDCG
        }
    }
}
