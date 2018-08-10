Shader "CgTutorial/C6e1"{
  Properties {
    _MainTexture("Main Texture",2D) = "white" {}
    _Color("Color",Color) = (1,1,1,1)
    _Scale("Scale",Range(0,1)) = 1
    _Frequency("Frequency",Range(0,1)) = 0
  }

  SubShader{
    Pass{
      CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
        };

        struct v2f {
          float4 position : SV_POSITION;
          float2 uv : TEXCOORD0;
        };

        sampler2D _MainTexture;
        float4 _Color;
        float _Scale;
        float _Frequency;

        v2f vert(appdata IN) {
          v2f OUT;
          float displacement = _Scale * 0.5 *
                               sin(IN.vertex.y * _Frequency * _Time.y) + 1;

          float displacementDirection = float4(IN.normal.x,IN.normal.y,IN.normal.z,0);

          float4 newPosition = IN.vertex +
                               displacement * displacementDirection;

          OUT.position = UnityObjectToClipPos(newPosition);
          OUT.uv = IN.uv;

          return OUT;
        }

        fixed4 frag(v2f IN) : SV_TARGET {
          float4 textureColor = tex2D(_MainTexture, IN.uv);
          return textureColor * _Color;
        }
      ENDCG
    }
  }
}
