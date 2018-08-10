Shader "Custom/RayMarchDemo" {
  Properties{
    _Size("Size",Range(0,15)) = 5
    _Color1("Shape Color",Color) = (1.0,1.0,1.0,1.0)
    _Color2("BackGround",Color) = (255.0,0.0,0.0,1.0)
  }
  SubShader {
    Cull Front ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
    Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
    Pass{
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "UnityCG.cginc"
      #define LIMIT 1
      #define STEPS 128
      #define MIN_DISTANCE 0.00001

      struct v2f {
        float4 pos : SV_POSITION; // Clip space
        float3 wPos : TEXCOORD1; // World position
      };

      float _Size;
      float4 _Color1;
      float4 _Color2;

      float3 opTwist( float3 p ){
          float c = cos(_Time.y/100.0);
          float s = sin(_Time.y/100.0);
          float2x2  m = float2x2(c,-s,s,c);
          float3 q = float3(mul(p.xy,m),p.z);
          return q;
      }


      float displace(float3 v,float p){
        return p + (  ( sin(v.x*_Time.y/1000.0)) * sin(v.y)*sin(v.z) );

      }
      float sdSphere( float3 p, float s ){
        return length(p)-s;
      }
      float sdBox( float3 p, float3 b ){
        float3 d = abs(p) - b;
        return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
      }

      float3 mod(float3 x, float3 y)
      {
        return x - y * floor(x/y);
      }

      float3 opRep(float3 p , float3 c){
        return mod(p,c) - 0.5 * c;
      }


      float opS( float d1, float d2 ){
        return max(-d1,d2);
      }
      float2x2 rotate(float a) {
        return float2x2( cos(a), sin(a), -sin(a), cos(a) );
      }

      float DistanceFunction( fixed3 p ) {
        p += float3(0,-1,0);
        p.xz = mul(p.xz,rotate(_Time.y/100.0));
      //  opRep(p,fixed3(20.0,20.0,20.0)),fixed3(1.1,1.1,1.1)
        float3 rep = float3(20.0,20.0,20.0);
        float ballOffset = 0.4 + 1.0 + sin( _Time.y/100.0);
        float Sphere =
                        sdSphere(
                            opRep(p,rep),
                          _Size*1.2
                        )
                       ;
        //float sdSphere = displace(p,Sphere);
        float Box = sdBox(opRep(p,rep), float3(_Size,_Size,_Size));
      //  float sdBox = displace(p,Box);
        return opS(Sphere,Box) ;
        //return Box;
      }

      float ambient_occlusion( float3 pos, float3 nor ){
          float occ = 0.0;
          float sca = 1.0;
          for( int i=0; i<5; i++ )
          {
            float hr = 0.01 + 0.12*float(i)/4.0;
            float3 aopos =  nor * hr + pos;
            float dd = DistanceFunction( aopos );
            occ += -(dd-hr)*sca;
            sca *= 0.95;
          }
          return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
      }

      float3 set_normal (float3 p){
				float3 x = float3 (0.001,0.00,0.00);
				float3 y = float3 (0.00,0.001,0.00);
				float3 z = float3 (0.00,0.00,0.001);
				return normalize(float3(DistanceFunction(p+x)-DistanceFunction(p-x),DistanceFunction(p+y)-DistanceFunction(p-y), DistanceFunction(p+z)-DistanceFunction(p-z)));
			}

      float3 lighting (float3 p){
				float3 AmbientLight = float3 (0.1,0.1,0.1);
				float3 LightDirection = normalize(float3 (4.0,10.0,-10.0));
				float3 LightColor = float3 (1.0,1.0,1.0);
				float3 NormalDirection = set_normal(p);
				return (max(dot(LightDirection, NormalDirection),0.0) * LightColor + AmbientLight)*ambient_occlusion(p,NormalDirection);
			}


      float4 colorAbb(){
        // float sinF = 2.0 * sin(_Time.y/5.0) + 1;
        // float cosF = 2.0 * cos(_Time.y/5.0) + 1;
        // return float4(sinF,-cosF,-sinF,cosF);
        float4 col = _Color1;
        fixed amount;

			//	amount = (1.0 + sin(_Time.y/6.0)) * 0.5;
				amount = 1.0 + sin(_Time.y/8.0) * 0.5;
			//	amount *= 0.5 + sin(_Time.y*19.0) ;
			   //amount = 1.0 + sin(_Time.y*27.0) * 0.5;
				amount = pow(amount, 3.0);
			//	return amount;
        col.r += amount; col.b += amount; col.g -= amount;



        return col;

      }

     fixed4 scene(float3 position, float3 direction){
      	// Loop do raymarcher.
      	// for (int i = 0; i < STEPS; i++){
      	// 	float distance = DistanceFunction(position);
      	// 	if (distance < 0.01)
        //     //we have hit our scene objects
      	// 	//	return i / (float) STEPS;
        //     //return 0.0;
        //     return colorAbb();
        //
      	// 	position += distance * direction;
      	// }
      	// return 0.0;

        for (int i=0; i<STEPS; i++){
					float ray = DistanceFunction(position);
					if(LIMIT != 0){
					       if (distance(position,ray*direction)>250) break;
					}
					if (ray < MIN_DISTANCE) return float4(lighting(position),1.0); else position+=ray*direction;
				}
				return 0.0;
      }

        // Vertex function
     v2f vert (appdata_full v){
    			v2f o;
    			o.pos = UnityObjectToClipPos(v.vertex);
    			o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    			return o;
    		}

        // Fragment function
     fixed4 frag (v2f i) : SV_Target{
    			float3 worldPosition = i.wPos;
    			float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
    			return scene(float3(0.5 * sin(_Time.y/10.0 ) - 20.0,2.0 * cos(_Time.y/2.0) + 1 ,_Time.y/10.0), viewDirection);
    	 }
       ENDCG
    }
  }
}
