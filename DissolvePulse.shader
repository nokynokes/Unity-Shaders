Shader "MessingAround/Dissolve_Pulse_Shader"{
  Properties{
    _Color ("Color",Color) = (1,1,1,1)
    _MainTexture ("Main Texture", 2D) = "white" {}
    _DissolveTexture ("Dissolve Texture", 2D) = "white" {}
	  //_DissolveCutoff ("Dissolve Cutoff", Range(0, 1)) = 1
    //_Length("Seconds", Float) = 5
    _Amplitude ("Scale",Float) = 1
    _Period ("Frequency",Float) = 1
  }

  SubShader {

    Pass {
        Cull Off
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
            float4 position : SV_POSITION; // SV stands for "system value," represents v2f struct that is final transformed vertex position for rednering
            float2 uv : TEXCOORD0;
          };

          //Get our properties into CG
	        float4 _Color;
          sampler2D _MainTexture;
          sampler2D _DissolveTexture;
          float _Amplitude;
          float _Period;
        //  float _Length;

          v2f vertexFunction(appdata IN){
              v2f OUT;
              //take vertex that is represented in local object space, and tranforms it into the rendering camera's clip space.
              OUT.position = UnityObjectToClipPos(IN.vertex);
              OUT.uv = IN.uv;

              return OUT;

          }

           // sv_target tells we're outputting a fixed4 colour to be rendered
          fixed4 fragmentFunction(v2f IN) : SV_TARGET {
            //adds a pulsing effect
              float displacement = _Amplitude * 0.5 * (sin(_Time.y * _Period) + 1);
              float4 textureColor = tex2D(_MainTexture, IN.uv); // sample the maintexture for color
              float4 dissolveColor = tex2D(_DissolveTexture, IN.uv); //sample the cutout texture for its color
              //clip(dissolveColor.rgb * sin(_Time.y/_Length)/2 - _DissolveCutoff ); //subtract the cutt off value from the "brightness" of our cutoff sample, if its less than 0 draw nothing
              clip( dissolveColor.rgb  - displacement );
              return textureColor * _Color; // else return main texture sample color tinted by the property color
          }

        ENDCG
    }
  }
}
