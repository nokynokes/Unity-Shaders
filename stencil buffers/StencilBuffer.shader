Shader "Stencil/StencilBuffer" {

	Properties { }

	SubShader {


		Tags { "Queue" = "Geometry-1" }
		Cull Off
		ColorMask 0
		ZWrite Off


		Pass {

			Stencil {
				Ref 1
				Comp always
				Pass replace
			}



		}

	}

	FallBack "Diffuse"
}
