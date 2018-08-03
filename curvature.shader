
//Original: https://www.shadertoy.com/view/ldyfDD
Shader "Custom/Curverature" {
  Properties{
    _MainTex ("Texture Sampler (UV Only)", 2D) = "grey" {}
    _Zoom("Zoom Level",float) = 8000.463325567321

    _FocusX("Focus X",Range(-5,5)) = -0.3160039610412624
    _FocusY("Focus Y",Range(-10,10)) = -0.6428171368132422
  }

  SubShader{
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }
    Cull Off
      CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0
        #define iteration_holder 300
        #define escape_holder 100.0
        #define focusX -0.3160039610412624
        #define focusY -0.6428171368132422

        struct Input {
          float2 uv_MainTex;
          float3 worldPos;
        };
        float _Zoom;
        float _FocusX;
        float _FocusY;
        // float2 focusPoint = float2(-0.3160039610412624, -0.6428171368132422);

        sampler2D _MainTex;

        float3 image1(float v, float l){
          	float3 col;
            col.r =  0.5 + 0.5 * sin(3.0 * _Time.y + l / 3.0) ;
            col.g = 0.5 + 0.5 * sin( 6.0 * sin(_Time.y) + 10.0 * cos(v * 10.0 / log(l)));
            col.b = 0.5 + 0.5 * sin(4.0 * sin(_Time.y) + 10.0 * cos(v * v * 10.0 / log(l)));
            return col;
        }

        void surf (Input IN, inout SurfaceOutput o) {
          float izoom = pow(1.001, _Zoom + 1000.0 * sin(_Time.y/32.0) );
          float2 uv = IN.uv_MainTex; uv.x +=  _FocusX; uv.y += _FocusY;
          float2 z = float2(0.0,0.0);
          float2 focusPoint = float2(focusX,focusY);
          float2 c = focusPoint + (uv * 4.0 - 2.0)  * 1.0 / izoom ;
          c.x *= _ScreenParams.x / _ScreenParams.y;
          float2 p = z;

          float l;
          float sum = 0.0;
          float sum2 = 0.0;

          float sum3 = 0.0;
          float sum4 = 0.0;

          int skip = 0;

          float min_dist = 10000.0;

          for(int i = 0; i<iteration_holder; i++){
            l++;
            if( length(z)>escape_holder) break;
            p = z;
            float2 t = float2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
            z = t + c;
            min_dist = min(min_dist, length(z-float2(-0.8181290, -0.198848)));
            sum2 = sum;
            sum4 = sum3;
            if ((i>skip)&&(i!=-1)){
               float mp=length(t);
               float m = abs(mp  - length(c)  );
               float M = mp + length(c);

               float curve1 = 0.5 + 0.5 * sin(10.0 * sin(_Time.y/20.0) + 4.0  * atan2(z.y,z.x));
               float curve2 = 0.5 + 0.5 * sin(10.0 * sin(_Time.y) * atan2(z.y, z.x));
               sum += 1.0 * curve1;
               sum3 +=  1.0 * curve2;

            }
          }

          sum = sum / (l );
          sum2 = sum2 / (l - 1.0);

          sum3 = sum3 / (l );
          sum4 = sum4 / (l - 1.0);

          l = l + 1.0 + 1.0/log(2.0) * log(log(100.0)/ log(sqrt(dot(z,z))));
          float d = l - floor(l);


          float r = sum * d + sum2 * (1.0 - d);

          float3 finalColor = image1(r,l);

           if(l > (float(iteration_holder) - 1.0)){
              o.Emission = float3(0.0,0.0,0.0);
           }
           else{
              o.Emission = finalColor;
           }
        }


      ENDCG

  }
}
