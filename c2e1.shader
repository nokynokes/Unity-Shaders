Shader "CgTutorial/C2E1v"{
    Properties{
      _MainTexture ("Main Texture", 2D) = "white" {}
    }
    SubShader{
      Pass{

          CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
              float4 vertex : POSITION;
              float2 uv : TEXCOORD0;
            };

            struct v2f{
              float4 position : SV_POSITION;
              float2 uv : TEXCOORD0;
              float4 color : COLOR;
            };

            struct C2E1v_Output{
              float4 position : POSITION;
              float4 color : COLOR;
            };

            sampler2D _MainTexture;

            C2E1v_Output green(float2 position : POSITION){
              C2E1v_Output OUT;
              OUT.position = float4(position,0,1);
              OUT.color = float4(0, 1, 0, 1);
              return OUT;
            }

            v2f vert(appdata IN){
              v2f OUT1; C2E1v_Output OUT2;
              OUT2 = green(float2(IN.position.x,IN.position.y));
              OUT1.position = OUT2.position;
              OUT1.uv = IN.uv;
              OUT1.color = OUT2.color;
              return OUT1;
            }

            fixed4 frag(v2f IN) : SV_TARGET{
              float4 textureColor = tex2D(_MainTexture, IN.uv);
              return textureColor * IN.color;
            }

          ENDCG
      }
    }
}
