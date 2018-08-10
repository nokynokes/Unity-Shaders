Shader "Custom/SurfaceSpriteSheet - ColorAbb SteroEffect" {
	Properties {
		[Header(General)]
		_Color("Color", Color) = (1,1,1,1)
		_Glossiness("Smoothness", Range(0,1)) = 1
		_Metallic("Metallic", Range(0,1)) = 1

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
		_EmissionValue ("Emission Value", Float ) = 0.5

		_Scale("Scale",Range(0,10)) = 1
   		_Frequency("Frequency",Range(0,1)) = 0
   		_SliceScale("Slice Scale",float) = 0



		_Amount("Amount", Range(0.0, 1)) = 0.0005

	}
	SubShader {
		Tags { "RenderType"="Opaque" "DisableBatching"="True"}
		LOD 200
		Cull Front





			CGPROGRAM
			#pragma surface surf Standard alphatest:_Cutoff addshadow
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _NormalTex;

			struct Input {
				float2 uv_MainTex;
				float4 color : COLOR;
				float2 uv_BumpMap;
				float3 worldPos;
			};

			float4 _Color;
			half _Glossiness;
			half _Metallic;
			int _Columns;
			int _Rows;
			int _FrameNumber;
			int _TotalFrames;
			float _Scale;
			float _Frequency;
			//float _FrameScale;

			float _AnimationSpeed;
			float _EmissionValue;

			float _SliceScale;
			float _Amount;

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

			void surf (Input IN, inout SurfaceOutputStandard o) {
				float displacement = 0.5  * _Scale * sin(_Time.y * _Frequency) + 1;
				clip(frac((IN.worldPos.y + IN.worldPos.x + IN.worldPos.z)*displacement) - _SliceScale);

				_FrameNumber += frac(_Time[0] * _AnimationSpeed) * _TotalFrames;

				float frame = clamp(_FrameNumber, 0, _TotalFrames);

				float2 offPerFrame = float2((1 / (float)_Columns), (1 / (float)_Rows));

				float2 spriteSize = IN.uv_MainTex;
				spriteSize.x = (spriteSize.x / _Columns);
				spriteSize.y = (spriteSize.y / _Rows);

				float2 currentSprite = float2(0,  1 - offPerFrame.y);
				currentSprite.x += frame * offPerFrame.x;

				float rowIndex;
				float mod = modf(frame / (float)_Columns, rowIndex);
				currentSprite.y -= rowIndex * offPerFrame.y;
				currentSprite.x -= rowIndex * _Columns * offPerFrame.x;

				float2 spriteUV = (spriteSize + currentSprite); //* _FrameScale

				float3 col;
				float2 uvn = spriteUV;

				//tape wave
				//uvn.x += ( rand( float2( uvn.y, _Time.y ) ) - 0.5 )* 0.005;
				//uvn.x += ( rand( float2( uvn.y * 100.0, _Time.y * 10.0 ) ) - 0.5 ) * 0.01;

				// tape crease
				float tcPhase = clamp( ( _Scale * sin( (uvn.y * 8.0 - _Time.y * PI * 1.2)/_Frequency ) - 0.92 ) * rand( float2( _Time.y, _Time.y ) ), 0.0, 0.01 ) * 10.0;
				float tcNoise = max( rand( float2( uvn.y * 100.0, _Time.y * 10.0 ) ) - 0.5, 0.0 );
				// uvn.x = uvn.x - tcNoise * tcPhase;

				// switching noise
				float snPhase = smoothstep( 0.03, 0.0, uvn.y );
				// uvn.y += snPhase * 0.3;
				// float node = spriteUV.y * 100.0;
				// float node2 = _Time.y * 10.0;
				// uvn.x += snPhase * ( (rand( float2(node,node2) ) - 0.5 ) * 0.2 );
				// fixed amount;
				// amount = (1.0 + sin(_Time.y*6.0)) * 0.5;
				// amount *= 1.0 + sin(_Time.y*16.0) * 0.5;
				// amount *= 1.0 + sin(_Time.y*19.0) * 0.5;
				// amount *= 1.0 + sin(_Time.y*27.0) * 0.5;
				// amount = pow(amount, 3.0);
				//
				// amount *= 0.05;

				if(unity_StereoEyeIndex  == 0){
					//clip(frac((IN.worldPos.y)*displacement) - _SliceScale);
					//clip(frac((IN.worldPos.x + IN.worldPos.y + IN.worldPos.z)*displacement*-1.0) - _SliceScale);
					//left Eye
				//	uvn.x += ( rand( float2( uvn.y, _Time.y ) ) - 0.5 )* 0.000005;
				//	uvn.x += ( rand( float2( uvn.y * 100.0, _Time.y * 10.0 ) ) - 0.5 ) * 0.00001;
					uvn.x = uvn.x + tcNoise * tcPhase;
					uvn.y += snPhase * 0.3;
					float node = spriteUV.y * 100.0;
					float node2 = _Time.y * 10.0;
					uvn.x -= snPhase * ( (rand( float2(node,node2) ) - 0.5 ) * 0.2 );
					col = tex2D(_MainTex, uvn);
					for( float x = -4.0; x < 2.5; x += 1.0 ){
						col.z +=
							//tex2D( _MainTex, uvn + float2( x - 0.0, 0.0 ) * 7E-3 ).x,
							//tex2D( _MainTex, uvn + float2( x - 2.0, 0.0 ) * 7E-3 ).y,
							tex2D( _MainTex, uvn + float2( x - 4.0, 0.0 ) * 7E-3 ).z
						 * 0.1;
					 }
					// col.r = tex2D(_MainTex, uvn)
					// col.g = tex2D(_MainTex, uvn).g;
					// col.z = tex2D(_MainTex, uvn).z;
					//
					// col.x = tex2D(_MainTex, float2(uvn.x - rgbShift(), uvn.y)).x;;
					// col.y = tex2D(_MainTex, uvn).y;
					// col.b = tex2D(_MainTex, uvn).b;


				} else {
				//	clip(frac((IN.worldPos.x + IN.worldPos.y + IN.worldPos.z)*displacement) - _SliceScale);
				//	col = tex2D(_MainTex, uvn);
					//col.r = tex2D(_MainTex, float2(uvn.x - amount, uvn.y)).r;;
					uvn.x += ( rand( float2( uvn.y, _Time.y ) ) - 0.5 )* 0.0005;
					uvn.x -= ( rand( float2( uvn.y * 100.0, _Time.y * 10.0 ) ) - 0.5 ) * 0.001;
				//	uvn.x = uvn.x - tcNoise * tcPhase;
					//uvn.y -= snPhase * 0.3;
					// float node = spriteUV.y * 100.0;
					// float node2 = _Time.y * 10.0;
					// uvn.x += snPhase * ( (rand( float2(node,node2) ) - 0.5 ) * 0.2 );
					col = tex2D(_MainTex, uvn).rgb;
					// col.x = tex2D(_MainTex, uvn).x;
					// col.y = tex2D(_MainTex, uvn).y;
					// col.z = tex2D(_MainTex, float2(uvn.x + rgbShift(), uvn.y)).z;
					for( float x = -4.0; x < 2.5; x += 1.0 ){
	          col.xy += float2(
	            tex2D( _MainTex, uvn + float2( x - 0.0, 0.0 ) * 7E-3 ).x,
	            tex2D( _MainTex, uvn + float2( x - 2.0, 0.0 ) * 7E-3 ).y
	            //tex2D( _MainTex, uvn + float2( x - 4.0, 0.0 ) * 7E-3 ).z
	             ) * 0.1;
	        }

				}


			//	col *= (1.0 - amount * 0.5);

			//	col = tex2D(_MainTex, uvn).rgb;
        col *= 1.0 - tcPhase;

        		col = lerp(col,col.yzx,snPhase);

        // for( float x = -4.0; x < 2.5; x += 1.0 ){
        //   col.xyz += float3(
        //     tex2D( _MainTex, uvn + float2( x - 0.0, 0.0 ) * 7E-3 ).x,
        //     tex2D( _MainTex, uvn + float2( x - 2.0, 0.0 ) * 7E-3 ).y,
        //     tex2D( _MainTex, uvn + float2( x - 4.0, 0.0 ) * 7E-3 ).z
        //   ) * 0.1;
        // }

        		col *= 0.6;

        // ac beat
      	col *= 1.0 + clamp( rand( float2( 0.0, spriteUV.y + _Time.y * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );

				//fixed4 c = tex2D(_MainTex, spriteUV) * _Color;

				//ChromaticAbb



				o.Normal = UnpackNormal(tex2D(_NormalTex, uvn));
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Albedo = col;
				o.Alpha = 1.0;
				o.Emission = col;
			}
			ENDCG

	}
	FallBack "Transparent/Cutout/Diffuse"
}
