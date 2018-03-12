// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Water" {
	Properties {
		_Color ("Tint Color", Color) = (0,0,1,1)
		_Transparency("Transparency", Range(0.0,0.5)) = 0.25
		_Speed("Speed", Range(0,10)) = 0.1
		_Amp("Amplitude",float) = 1
		_Distance("Distance", Float) = 1
		_Amount("Amount", Range(0.0,1.0)) = 1
	}
	SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }

        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
		Pass {
		    Tags { "LightMode"="Always"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			struct appdata {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float4 col : COLOR;
				float3 norm : NORMAL;
				uint vid : SV_VertexID;
			};
			struct v2f {
				float4 vertex : POSITION;
				float3 normalDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float4 col : COLOR;
				float4 worldPos : POSITION1;
			};
			float4 _Color;
			float _Transparency;
			float _Noise;
			float _Speed;
			float _Distance;
			float _Amount;
			float _Amp;
			half4 _Tex_HDR;
			float rand(float2 co)
			{
				return frac(sin(dot(co.xy ,float2(12.9898,78.233) )) * 43758.5453);
			}
			float4 MorphVertex(float4 v, float f, float4 wp){
				v.y += sin(_Time.y * _Speed + f * wp * _Amp ) * _Distance * _Amount;
				return v;
			}
			float4 MorphColor(float4 c, float f, float4 wp){
		
			}
			v2f vert(appdata v){
				v2f o;
				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 reverseMatrix = unity_WorldToObject;
				float f = (float)v.vid;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.viewDir = mul(modelMatrix,v.vertex).xyz - _WorldSpaceCameraPos;
				o.normalDir = normalize(mul(float4(v.norm,0.0), reverseMatrix).xyz);
				o.col = _Color;
				v.vertex = MorphVertex(v.vertex,f,o.worldPos);
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			fixed4 frag(v2f i)  : SV_Target{
				float3 reflectedDir = reflect(i.viewDir,normalize(i.normalDir));
				i.col.a = _Transparency;
				half4 c = 1.0;
				half4 tex = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflectedDir);
				c.xyz = DecodeHDR(tex,unity_SpecCube0_HDR);
				c.w = _Transparency;
				return c;
			}
			ENDCG
		}
	}
}
