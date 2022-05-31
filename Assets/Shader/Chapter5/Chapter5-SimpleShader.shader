// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader"
{
    Properties{
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
        Pass {
            CGPROGRAM
            
            #pragma vertex vert     //声明顶点着色器 函数
            #pragma fragment frag   //声明片元着色器 函数
            
            // CG代码中，需要定义一个 与 属性名称和类型都匹配的 变量
            fixed4 _Color;
            
            struct a2v{
                float4 vertex : POSITION;// POSITION 用模型空间 顶点坐标填充vertex 变量
                float3 normal : NORMAL;// NORMAL 语义 用模型空间 法线方向 填充 normal 变量
                float4 texcoord : TEXCOORD0;// TEXTCOORD0 用模型的第一套纹理坐标 填充 texcoord变量
            };
            struct v2f{
                float4 pos : SV_POSITION;// SV_POSITION 语义：pos里包含了 顶点在 裁剪空间 中的位置
                fixed3 color : COLOR0; //COLOR0语义 可存储颜色信息
            };
            v2f vert(a2v v) {
            	v2f o;
            	o.pos = UnityObjectToClipPos(v.vertex);
            	o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                // 将插值后 i.color 显示到屏幕上
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
}
