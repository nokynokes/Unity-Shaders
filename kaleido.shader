Shader "Custom/Kaleidoscope" {
  Properties {
    //_MainTex("Main Texture", 2D) = "white" {}
      _Sides("Sides",float) = 6.0
      _Angle("Angle",float) = 0.0
  }
  SubShader {
    Tags {
      "Queue"="Transparent+10"
      "RenderType"="Transparent"
    }
    LOD 200
    Cull Off ZTest Always
    GrabPass{"_SceneBefore"}



    Pass {
      CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 3.0
        #include "UnityCG.cginc"

        struct appdata {
          float4 vertex : POSITION;
          //float2 uv : TEXCOORD0;
        };


        struct v2f {
          float4 grabPos : TEXCOORD0;
          float4 pos : SV_POSITION;
        };

        //sampler2D _MainTex;
        sampler2D _SceneBefore;
        //sampler2D _WorldSpaceNormal;
        float _Sides;
        float _Angle;


        float mod(float x, float y) {
          return x - y * floor(x/y);
        }

        v2f vert(appdata v) {
          v2f o;
        //  o.pos = UnityObjectToClipPos(v.vertex);
          o.pos = float4(v.vertex.x * 1, -v.vertex.y * 1, UNITY_NEAR_CLIP_VALUE, 1);
          #if UNITY_SINGLE_PASS_STEREO
            o.vertex = float4(v.vertex.x * 1 + 0.2 * lerp(1,-1,unity_StereoEyeIndex), -v.vertex.y * 1, UNITY_NEAR_CLIP_VALUE, 1);
          #endif
          o.grabPos = ComputeGrabScreenPos(o.pos);
          return o;
        }

        fixed4 frag(v2f IN) : SV_Target {
            float2 p = (IN.grabPos.xy/IN.grabPos.w);
            float r = length(p);
            float a = atan2(p.x,p.y) + (_Angle * ( 0.5 * sin(_Time.y/100.0) + 1 ));
            float tau = 2.0 * 3.12416;
            a = mod(a, tau/_Sides);
            a = abs(a - tau/_Sides);
            p = r * float2(cos(a),sin(a));
            fixed4 col = tex2D(_SceneBefore, p);
            col.r = col.a - col.r;
            col.b = col.a - col.b;
            //col.g = col.a  - col.g;
            return lerp(tex2D(_SceneBefore,IN.grabPos.xy/IN.grabPos.w), col, -1.0);
        }




      ENDCG
    }
  }
}
