Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level"
{
	Properties
	{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Pass
		{
    		Tags { "LightMode"="ForwardBase" }//指明光照模式
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse // 定义一个Properties中声明的属性 匹配的变量
                            // 由此得到：材质漫反射属性。颜色范围[0,1] 用field精度
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
