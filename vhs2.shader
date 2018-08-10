//Chrom abb found from : https://www.shadertoy.com/view/llyXRh

Shader "Custom/VHS 2"{
  Properties {
    [Header(Textures)]
		_MainTex ("Main Texture", 2D) = "white" {}
    _NoiseTex ("Noise Texture", 2D) = "white" {}
  }
  SubShader{
    CGPROGRAM
      #pragma surface surf Lambert
      #pragma target 3.0

      #define AMPLITUDE 0.2
      #define SPEED 0.05

      struct Input {
        float2 uv_MainTex;
        float2 uv_NoiseTex;
        float3 worldPos;
      };

      sampler2D _MainTex;
      sampler2D _NoiseTex;

      float4 rgbShift( in float2 p , in float4 shift) {
          shift *= 2.0*shift.w - 1.0;
          float2 rs = float2(shift.x,-shift.y);
          float2 gs = float2(shift.y,-shift.z);
          float2 bs = float2(shift.z,-shift.x);

          float r = tex2D(_MainTex, p+rs).x;
          float g = tex2D(_MainTex, p+gs).y;
          float b = tex2D(_MainTex, p+bs).z;

          return float4(r,g,b,1.0);
      }

      float4 noise( in float2 p ) {
        return tex2D(_MainTex, p);
      }

      float4 float4pow( in float4 v, in float p ) {
          // Don't touch alpha (w), we use it to choose the direction of the shift
          // and we don't want it to go in one direction more often than the other
          return float4(pow(v.x,p),pow(v.y,p),pow(v.z,p),v.w);
      }

      void surf(Input IN, inout SurfaceOutput o){
        float2 p = IN.uv_MainTex;
        float4 c = float4(0.0,0.0,0.0,1.0);
        float4 shift = float4pow(noise(float2(SPEED*_Time.y,2.0*SPEED*_Time.y/25.0 )),8.0)
        		*float4(AMPLITUDE,AMPLITUDE,AMPLITUDE,1.0);

        c += rgbShift(p,shift);
        o.Emission = c.rgb;
      }


    ENDCG
  }
}
