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
				float3 normal : NORMAL; //访问法线
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 color : COLOR;   //接收顶点着色 计算完成的光照颜色，也可以用TEXTCOORD0
			};
			
			v2f vert (a2v v)
			{
				//逐顶点 漫反射光照，都在顶点着色器进行
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex)
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
