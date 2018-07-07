Shader "MessingAround/Tutorial_Shader"{
  Properties{
    _Color ("Color",Color) = (1,1,1,1)
    _MainTexture ("Main Texture", 2D) = "white" {}

  }

  SubShader {
    Pass {
        CGPROGRAM
        // pragma tells unity what our vertex and fragment functions are
          #pragma vertex vertexFunction
          #pragma fragment fragmentFunction

        // helper functions
          #include "UnityCG.cginc"

          // struct to hold object data
          struct appdata {
              float4 vertex : POSITION; //vertices
              float2 uv : TEXCOORD0; // uv coordinates
          };

          struct v2f {
            float4 poistion : SV_POSITION; // SV stands for "system value," represents v2f struct that is final transformed vertex position for rednering
            float2 uv : TEXCOORD0;
          };

          //Get our properties into CG
	        float4 _Color;
          sampler2D _MainTexture;

          v2f vertexFunction(appdata IN){
              v2f OUT;
              //take vertex that is represented in local object space, and tranforms it into the rendering camera's clip space.
              OUT.position = UnityObjectToClipPos(IN.vertex);
              OUT.uv = IN.uv

              return OUT;

          }

           // sv_target tells we're outputting a fixed4 colour to be rendered
          fixed4 fragmentFunction(v2f IN) : SV_TARGET {
            //return fixed4(0, 1, 0, 1); //(R, G, B, A)
          //  return _Color;
            return tex2D(_MainTexture, IN.uv) //tex2d takes in texture we want to sample and uv coordinates to sample with

          }

        ENDCG
    }
  }
}
