Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)// 材质高光反射颜色
		_Gloss ("Gloss", Range(8.0, 256)) = 20      // 高光区域光斑大小
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }  
			// 指明光照模式，正确的LightMode才能得到内置光照变量，例如_LightColor0
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc" // 为了使用内置变量 _LightColor0
			
			fixed4 _Diffuse;    //颜色 0-1，所以可用fixed
			fixed4 _Specular;
			float _Gloss;       //范围大用 float
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Transform the normal from object space to world space
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
				fixed 3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				// Compute diffuse term
				// saturate截取到[0,1]
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				// Get the reflect direction in world space
				// CG的reflect 函数入射方向 要求 光源指向交点处，所以要对 worldLightDir取反
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				// Get the view direction in world space
				// _WorldSpaceCameraPos 世界空间像极坐标
				// 顶点位置从转到世界空间
				// 再被 _WorldSpaceCameraPos减掉，得到世界空间 视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				
				// Compute specular term
				// 得到了四个参数，代入公式计算
				//                入射光线颜色和强度    材质高光反射系数                   反射方向     视角方向    高光点大小
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				o.color = ambient + diffuse + specular;
							 	
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				return fixed4(i.color, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
