Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level"
{
    // 细分程度高的模型，逐顶点光照效果好
    // 细分程度低的模型，会出视觉问题，背光面，向光面 交界处出现锯齿
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
				fixed3 color : COLOR;   //接收顶点着色 计算完成的光照颜色，也可以用TEXTCOORD0
			};
			v2f vert (a2v v)
			{
				// 顶点着色器基本任务：顶点位置从模型空间转换到裁剪空间
				//逐顶点 漫反射光照，都在顶点着色器进行
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                
                // 已知漫反射颜色 _Diffuse 顶点法线 v.normal, 未知：光源颜色，强度信息，光源方向
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	//内置变量，环境光

                // 计算法线和光源方向 点积时，二者要在同一坐标空间下。
                // 我们选择 世界坐标空间，a2v得到的 顶点法线 是 模型空间下的
                // 需要把 法线 转换到 世界空间中
                // 此处交换位置，乘逆矩阵，获得 模型空间 到 世界空间的法线
                // 
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // _WorldSpaceLightPos0 得到光源方向
                // 仅用于 一个光源 and 平行光。 多个光源和 点光源就不能这么获得 光照方向 
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                
                //_LightColor0 内置变量，访问这个Pass 处理的 光源颜色 强度信息
                // 谨记定义正确的 LightMode Tags标签
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight)); 
                // 归一化后，点积结果可能是负，所以要用saturate截取到[0,1]
                // 再和 光源颜色，强度，材质的漫反射颜色 相乘
                
				o.color = ambient + diffuse;    //环境光+环境光得到最终效果

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}
			ENDCG
		}
	}
	// 回调shader设置为内置的Diffuse
	FallBack "Diffuse"
}
