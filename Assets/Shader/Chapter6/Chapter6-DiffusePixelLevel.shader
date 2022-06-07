Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level"
{
    // 逐像素 光照更加平滑。
    // 问题：光照无法到达的区域，模型外观全黑，没有明暗变化，让背光区域看起来像一个平面。
    // 通过添加环境光，也无法彻底解决 背光明暗一样的缺点
    // 改善：半兰伯特光照模型
	Properties
	{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)   //材质漫反射属性
	}
	SubShader
	{
		Pass
		{
    		Tags { "LightMode"="ForwardBase" }//指明光照模式
    		//谨记定义正确的 LightMode Tags标签
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;// 定义一个Properties中声明的属性 匹配的变量
                            // 由此得到：材质漫反射属性。颜色范围[0,1] 用field精度
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL; //访问法线
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};
			v2f vert (a2v v)
			{
			    v2f o;
			    // 顶点着色器不计算光照模型，只需把世界空间下 法线 传给片元着色器
			    o.pos = UnityObjectToClipPos(v.vertex);
			    // 法线从 模型空间 变换到 世界空间
			    o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			    fixed3 worldNormal = normalize(i.worldNormal);
			    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			    // 计算漫反射
			    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * 
                                    saturate(dot(worldNormal, worldLightDir));
			    fixed3 color = ambient + diffuse;
			    
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
	// 回调shader设置为内置的Diffuse
	FallBack "Diffuse"
}
