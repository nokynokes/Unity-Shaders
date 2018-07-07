Shader "CgTutorial/c2e2" {
  Properties{
    _MainTexture ("Main Texture", 2D) = "white" {}
  }
  SubShader{
    Pass {
      CGPROGRAM
        #pragma vertex vert
        #pragma fragment fragm

        #include "UnityCG.cginc"

        struct appdata {
          float4 vertex : POSITION;
          float2 uv : TEXCOORD0;
        };

        struct v2f {
          float4 position : SV_POSITION;
          float2 uv : TEXCOORD0;
        };

        struct C2E2f_Output {
          float4 color : COLOR;
        };

        sampler2D _MainTexture;




      ENDCG
    }
  }
}
