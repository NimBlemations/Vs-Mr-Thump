package;

import flash.filters.BitmapFilter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.system.FlxAssets.FlxShader;

class ShaderMaster
{
	static inline var SIZE_INCREASE:Int = 50;
	
	public static function createFilterFrames(sprite:FlxSprite, filter:BitmapFilter)
	{
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, SIZE_INCREASE, SIZE_INCREASE, [filter]);
		updateFilter(sprite, filterFrames);
		return filterFrames;
	}
	
	public static function updateFilter(spr:FlxSprite, sprFilter:FlxFilterFrames)
	{
		sprFilter.applyToSprite(spr, false, true);
	}
}

class GloomShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		// From Yoshi Engine lol

		uniform float r = 1;
		uniform float g = 1;
		uniform float b = 1;
		uniform bool enabled = true;
		uniform bool cutOut = false;

		void main() {
			if (enabled) {
				vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
				float alpha = color.a;
				if (alpha == 0) {
					gl_FragColor = vec4(0, 0, 0, alpha);
				} else {
					float average = ((color.r + color.g + color.b) / 3) * 255;
					float finalColor = (50 - average) / 50;
					if (finalColor < 0) finalColor = 0;
					if (finalColor > 1) finalColor = 1;
					if (cutOut)
						gl_FragColor = vec4(finalColor * r * alpha, finalColor * g * alpha, finalColor * b * alpha, finalColor * alpha);
					else
						gl_FragColor = vec4(finalColor * r * alpha, finalColor * g * alpha, finalColor * b * alpha, alpha);
				}

			} else {
				gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			}
		}')
	
		public function new(enabled:Bool, ?cutOut:Bool = false, ?r:Float = 1.0, ?g:Float = 1.0, ?b:Float = 1.0)
		{
			super();
			this.enabled.value = [enabled];
			this.cutOut.value = [cutOut];
			this.r.value = [r];
			this.g.value = [g];
			this.b.value = [b];
		}
}

class FranceShader extends FlxShader // le france houhouhouhou!
{
	@:glFragmentSource('
		#pragma header
		
		const float multip = 6.0;
		
		void main() {
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			if (openfl_TextureCoordv.x < 1.0 / 3)
				gl_FragColor = vec4(color.r / multip, color.g / multip, color.b * multip, color.a);
			else if (openfl_TextureCoordv.x < (1.0 / 3) * 2)
				gl_FragColor = vec4(color.r * multip, color.g * multip, color.b * multip, color.a);
			else if (openfl_TextureCoordv.x > (1.0 / 3) * 2)
				gl_FragColor = vec4(color.r * multip, color.g / multip, color.b / multip, color.a);
			else
				gl_FragColor = color;
		}')
		
		public function new()
		{
			super();
		}
}

class AveragedShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		void main() {
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			float average = ((color.r + color.g + color.b) / 3)/* * 255 */;
			gl_FragColor = vec4(average, average, average, color.a);
		}')
}

class NegativeShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		void main() {
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = vec4((1.0 - color.r) * color.a, (1.0 - color.g) * color.a, (1.0 - color.b) * color.a, color.a);
		}')
		
		public function new()
		{
			super();
		}
}

class BrokenGlassShader extends FlxShader
{
	@:glFragmentSource('
		const float cellJitter = 0.65;
		const float angularSegs = 9.;
		
		uniform vec2 resolution = vec2(1280, 720)
		
		vec2 hash( vec2 p )
		{
			p = mod(p, angularSegs);
			return texture( iChannel0, (p+0.5)/200.0, -100.0 ).xy;	
		}

		vec3 voronoi( in vec2 x, out vec2 cpId )
		{
			 vec2 n = floor(x);
			 vec2 f = fract(x);

			 //----------------------------------
			 // first pass: regular voronoi
			 //----------------------------------
			vec2 mg, mr;

			 float md = 8.0;
			 for( int j=-1; j<=1; j++ )
			 for( int i=-1; i<=1; i++ )
			 {
				  vec2 g = vec2(float(i),float(j));
				vec2 o = cellJitter * hash( n + g );
				  vec2 r = g + o - f;
				  float d = dot(r,r);

				  if( d<md )
				  {
						md = d;
						mr = r;
						mg = g;
				  }
			 }

			 //----------------------------------
			 // second pass: distance to borders
			 //----------------------------------
			 md = 8.0;
			 for( int j=-2; j<=2; j++ )
			 for( int i=-2; i<=2; i++ )
			 {
				  vec2 g = mg + vec2(float(i),float(j));
				vec2 o = cellJitter * hash( n + g );
				  vec2 r = g + o - f;

				
				  if( dot(mr-r,mr-r)>0.000001 )
				{
				  // distance to line		
				  float d = dot( 0.5*(mr+r), normalize(r-mr) );

				  md = min( md, d );
				}
			 }
			
			cpId = n+mg;

			 return vec3( md, mr );
		}

		float remap(float x) { return x * 0.5 + 0.5; }

		mat2 rot2(float theta) {
			 return mat2(cos(theta), -sin(theta),
							 sin(theta), cos(theta));
		}

		float atan01(vec2 p) {
			 return atan(p.y, p.x)/6.28318530718 + 0.5;
		}

		// Credit: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
		float rand(float n){return fract(sin(n) * 43758.5453123);}
		float noise(float p){
			 float fl = floor(p);
			 float fc = fract(p);
			 return mix(rand(fl), rand(fl + 1.0), fc);
		}

		float lowfreqnoise(float x) {
			 x = mod(x,1.0);
			 float res = 10.;
			 float ia = floor(x * res);
			 float ib = floor(x * res) + 1.;

			 // texture lookups have artifacts between segments, probably due to mipmapping.
			 //float a = texture(iChannel0, vec2(ia/res, 0.)).r;
			 //float b = texture(iChannel0, vec2(ib/res, 0.)).r;
			 float a = noise(mod(ia, res));
			 float b = noise(mod(ib, res));
			 
			 float t = fract(x * res);
			 return mix(a, b, t) * 2.0 - 1.;
		}

		vec3 image(vec2 fragCoord) {
			vec2 uvCenter = resolution.xy / resolution.x / 2. + vec2(-0.2, 0.1);
			 vec2 uv = openfl_TextureCoordv.xy / iResolution.x - uvCenter;
			 float r = length(uv);
			 
			 vec2 cyl = vec2(max(0.5,pow(r, 0.1)),
								  atan01(uv));
			 
			 // Add some uneveness to lines
			 cyl.x += 0.015 * abs(lowfreqnoise(cyl.y));
			 vec2 freq = vec2(12., angularSegs);
			 
			 vec2 cpid;
			 vec3 c = voronoi( cyl*freq, cpid );
			 cpid = mod(cpid, angularSegs);
			 float centerDist = length( c.yz );
			 float borderDist = c.x;
			 // Make edges more even in screenspace width
			 float e0 = mix(.1, .0, pow(r, .1));
			 float edge = smoothstep(e0, e0+.0001, borderDist);
			 //edge = 1.;

			 // rotate camera/cracked lens
			 float theta = iTime * 3.14 / 20.;
			 vec3 W = vec3(uv, -0.2);
			 W.xz = rot2(theta) * W.xz;
			 vec3 V = normalize(vec3(0.) - W);
			 vec3 normOffset = vec3(noise(cpid.x*7.), noise(cpid.y*13.), noise(27.*(cpid.x-cpid.y))) * 2. - 1.;
			 vec3 N = normalize(vec3(0., 0., 1.) + 0.1*normOffset);
		vec3 env = texture(bitmap, reflect(-V, N)).rgb;
				vec3 F = mix(vec3(1.), vec3(0.5, 0.9, 1.0)*0.4, 1.0-edge);
			 vec3 lit = env * F;
			 return lit;
		}

		void main( out vec4 fragColor, in vec2 fragCoord )
		{
			 // FSAA, box filter
			 const int L = 3;
			 const float Lf = float(L);
			 vec3 sum = vec3(0.);
			 for(int i = 0; i < L; i++) {
			 for(int j = 0; j < L; j++) {
				  vec2 ofs = vec2(float(i), float(j)) / Lf;
				  sum += image(openfl_TextureCoordv + ofs);
			 }
			 }
			fragColor = vec4(sum/(Lf*Lf),1.0);
		}')
		
		public function new()
		{
			super();
		}
}