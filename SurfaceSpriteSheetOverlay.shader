//https://www.shadertoy.com/view/ldffRs
﻿Shader "Custom/SurfaceSpriteSheetOverlay" {
	Properties {
		[Header(General)]
		_Color("Color", Color) = (1,1,1,1)
	//	_Glossiness("Smoothness", Range(0,1)) = 1
	//	_Metallic("Metallic", Range(0,1)) = 1

		[Header(Textures)]
		_MainTex ("Color Spritesheet", 2D) = "white" {}
		_NormalTex ("Normals Spritesheet", 2D) = "white" {}

		[Header(Spritesheet)]
		_Columns("Columns (int)", int) = 3
		_Rows("Rows (int)", int) = 3
		_FrameNumber ("Frame Number (int)", int) = 0
		_TotalFrames ("Total Number of Frames (int)", int) = 9
		//_FrameScale ("Frame Scale (for testing)", float) = 1
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 1
		_AnimationSpeed ("Animation Speed", float) = 0
	//	_EmissionValue ("Emission Value", Float ) = 0.5

		[Header(Background)]
		_BackGroundTex("Texture", 2D) = "white" {}
	}
	SubShader {
		Pass {

			Tags { "RenderType"="Opaque" "DisableBatching"="True"}
			LOD 200

			Cull Off

			CGPROGRAM
			//#pragma surface surf Standard fullforwardshadows alphatest:_Cutoff addshadow
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _NormalTex;
			sampler2D _BackGroundTex;

			struct appdata {
					float4 vertex : POSITION; //vertices
					float2 uv : TEXCOORD0; // uv coordinates
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			float4 _Color;
			half _Glossiness;
			half _Metallic;
			int _Columns;
			int _Rows;
			int _FrameNumber;
			int _TotalFrames;
			//float _FrameScale;

			float _AnimationSpeed;
			//float _EmissionValue;

			uniform float PI = 3.14159265;

			float rand(float2 co){
				return frac(sin(dot(co.xy , float2(12.9898,78.233))) * 43758.5453);
			}
			fixed rgbShift(){
				fixed amount;
				amount = (1.0 + sin(_Time.y*6.0)) * 0.5;
				amount *= 1.0 + sin(_Time.y*16.0) * 0.5;
				amount *= 1.0 + sin(_Time.y*19.0) * 0.5;
				amount *= 1.0 + sin(_Time.y*27.0) * 0.5;
				amount = pow(amount, 3.0);
				return amount;
			}

			v2f vert(appdata IN){
				v2f OUT;
				OUT.uv = IN.uv;
				OUT.pos = UnityObjectToClipPos(IN.vertex);
				return OUT;
			}

			fixed4 frag (v2f IN) : SV_TARGET{

				_FrameNumber += frac(_Time[0] * _AnimationSpeed) * _TotalFrames;

				float frame = clamp(_FrameNumber, 0, _TotalFrames);

				float2 offPerFrame = float2((1 / (float)_Columns), (1 / (float)_Rows));

				float2 spriteSize = IN.uv;
				spriteSize.x = (spriteSize.x / _Columns);
				spriteSize.y = (spriteSize.y / _Rows);

				float2 currentSprite = float2(0,  1 - offPerFrame.y);
				currentSprite.x += frame * offPerFrame.x;

				float rowIndex;
				float mod = modf(frame / (float)_Columns, rowIndex);
				currentSprite.y -= rowIndex * offPerFrame.y;
				currentSprite.x -= rowIndex * _Columns * offPerFrame.x;

				float2 spriteUV = (spriteSize + currentSprite); //* _FrameScale
				float2 uv_main = IN.uv;
				fixed4 c2;
				if(unity_StereoEyeIndex == 0){
					uv_main.x += ( rand( float2( uv_main.y, _Time.y ) ) - 0.5 )* 0.0007;
				 	uv_main.x += ( rand( float2( uv_main.y * 100.0, _Time.y * 10.0 ) ) - 0.5 ) * 0.003;

					c2.r = tex2D(_BackGroundTex, float2(uv_main.x + rgbShift(), uv_main.y));

					c2.b = tex2D(_BackGroundTex, uv_main).b;
				}else{
					uv_main.x -= ( rand( float2( uv_main.y, _Time.y ) ) - 0.5 )* 0.0007;
				 	uv_main.x -= ( rand( float2( uv_main.y * 100.0, _Time.y * 10.0 ) ) - 0.5 ) * 0.003;

					c2.r = tex2D(_BackGroundTex, uv_main).r;
					c2.b = tex2D(_BackGroundTex, float2(uv_main.x,uv_main.y + rgbShift())).b;
				}
				c2.g = tex2D(_BackGroundTex, uv_main).g;

				 fixed4 c = tex2D(_MainTex, spriteUV) ;
				 //fixed4 c2 = tex2D(_BackGroundTex, uv_main) ;


				 float3 lum = float3(0.2125, 0.7154, 0.0721);

				 c2.a = dot(lum,c2.rgb);
					return c + c2;
				}
			ENDCG
		}
	}

	FallBack "Transparent/Cutout/Diffuse"
}
