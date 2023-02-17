package;

import flash.filters.BitmapFilter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.tile.FlxGraphicsShader;
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

// Use FlxSkewedSprite instead
/*
class ShearShader extends FlxGraphicsShader
{
	@:glVertexSource('
		#pragma header
		
		uniform float shearAmount = 0;
		
		void main() {
			openfl_TextureCoordv = openfl_TextureCoord;
			
			if (openfl_HasColorTransform) {
				openfl_ColorMultiplierv = openfl_ColorMultiplier;
				openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
			}
			
			newMatrix = vec4(openfl_Matrix[0] * sin(shearAmount * openfl_Matrix[0]), openfl_Matrix[1], openfl_Matrix[2], openfl_Matrix[3])
			
			gl_Position = newMatrix * openfl_Position;
		}')
		
			public function new(shearAmount:Float = 0)
			{
				super();
				this.shearAmount.value = [shearAmount];
			}
}
*/

class NoTexNoiseShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float mixPercent;
		uniform float noiseMultiplier;
		
		uniform vec3 h1;
		uniform vec3 h2;
		uniform vec3 h3;
		
		vec3 hash(vec3 p) {
			p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
					 dot(p, vec3(269.5, 183.3, 246.1)),
					 dot(p, vec3(113.5, 271.9, 124.6)));

			return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
		}

		float noise(vec3 p) {
		  vec3 i = floor(p);
		  vec3 f = fract(p);
		  vec3 u = f * f * (3.0 - 2.0 * f);

		  return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
							 dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
						 mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
							 dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
					 mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
							 dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
						 mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
							 dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z );
		}
		
		/*
		// https://www.geeksforgeeks.org/square-root-of-a-number-without-using-sqrt-function/
		float sqrt(float x) {
			// for 0 and 1, the square roots are themselves
			if (x < 2)
				return x;
		 
			// considering the equation values
			float y = x;
			float z = (y + (x / y)) / 2;
		 
			// as we want to get upto 5 decimal digits, the absolute
			// difference should not exceed 0.00001
			while (abs(y - z) >= 0.00001) {
				y = z;
				z = (y + (x / y)) / 2;
			}
			return z;
		}
		
		
		float normalize(vec3 vektor) {
			sqrt(x ^ 2 + y ^ 2 + z ^ 2);
		}
		*/
		
		float lerp(float a, float b, float t) {
			return a + (b - a) * t;
		}
		
		void main() {
			vec4 curColor = vec4(0.0, 0.0, 0.0, 1.0);
			curColor.rgb = vec3(sin(openfl_TextureCoordv.x * 3.14159 * 4.0) * cos(openfl_TextureCoordv.y * 3.14159 * 4.0) * 0.5 + 0.5);
			vec4 imgColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			
			float theta = openfl_TextureCoordv.y * 3.14159;
			float phi = openfl_TextureCoordv.x * 3.14159 * 2.0;
			vec3 unit = vec3(0.0, 0.0, 0.0);

			unit.x = sin(phi) * sin(theta);
			unit.y = cos(theta) * -1.0;
			unit.z = cos(phi) * sin(theta);
			unit = normalize(unit);
			
			float n = noise(unit * noiseMultiplier);
			curColor.rgb = vec3(n * 0.5 + 0.5);
			
			vec4 finalColor = imgColor;
			
			finalColor.r = lerp(finalColor.r, curColor.r, mixPercent);
			finalColor.g = lerp(finalColor.g, curColor.g, mixPercent);
			finalColor.b = lerp(finalColor.b, curColor.b, mixPercent);
			finalColor.a = lerp(finalColor.a, curColor.a, mixPercent);
			
			gl_FragColor = finalColor;
		}')
		
		public var sh_mixPercent(default, set):Float = 0.5;
		public var sh_noiseMultiplier(default, set):Float = 5;
		
		function set_sh_mixPercent(newMixPercent:Float = 0.5)
		{
			var newPercent:Float = Math.max(Math.min(newMixPercent, 1), 0);
			this.mixPercent.value = [newPercent];
			return sh_mixPercent = newPercent;
		}
		
		function set_sh_noiseMultiplier(noiseMult:Float = 5)
		{
			this.noiseMultiplier.value = [noiseMult];
			return sh_noiseMultiplier = noiseMult;
		}
		
		public function randomize()
		{
			var stackMan:Array<Float> = [];
			for (i in 0...9)
			{
				var rand1:Int = Std.random(300);
				var rand2:Int = Std.random(10);
				
				var finalNum:Float = rand1 + (rand2 / 10);
				stackMan.push(finalNum);
			}
			this.h1.value = [stackMan[0], stackMan[1], stackMan[2]];
			this.h2.value = [stackMan[3], stackMan[4], stackMan[5]];
			this.h3.value = [stackMan[6], stackMan[7], stackMan[8]];
		}
		
		public function new(?mixPercent:Float = 0.5, ?noiseMultiplier:Float = 5)
		{
			super();
			this.sh_mixPercent = mixPercent;
			this.sh_noiseMultiplier = noiseMultiplier;
			
			this.h1.value = [127.1, 311.7, 74.7];
			this.h2.value = [269.5, 183.3, 246.1];
			this.h3.value = [113.5, 271.9, 124.6];
		}
}

class BrokenGlassShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		const float cellJitter = 0.65;
		const float angularSegs = 9.;
		
		vec2 hash( vec2 p )
		{
			p = mod(p, angularSegs);
			// return flixel_texture2D( bitmap, (p+0.5)/200.0, -100.0 ).xy;
			return openfl_TextureSize * vec2(p+0.5)/200.0, -100.0 );
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
		vec2 uvCenter = openfl_TextureSize.xy / openfl_TextureSize.x / 2. + vec2(-0.2, 0.1);
		vec2 uv = openfl_TextureCoordv.xy / openfl_TextureSize.x - uvCenter;
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
			 float theta = 3.14 / 20.;
			 vec3 W = vec3(uv, -0.2);
			 W.xz = rot2(theta) * W.xz;
			 vec3 V = normalize(vec3(0.) - W);
			 vec3 normOffset = vec3(noise(cpid.x*7.), noise(cpid.y*13.), noise(27.*(cpid.x-cpid.y))) * 2. - 1.;
			 vec3 N = normalize(vec3(0., 0., 1.) + 0.1*normOffset);
		vec3 env = flixel_texture2D(bitmap, reflect(-V, N)).rgb;
				vec3 F = mix(vec3(1.), vec3(0.5, 0.9, 1.0)*0.4, 1.0-edge);
			 vec3 lit = env * F;
			 return lit;
		}

		void main()
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
			 gl_FragColor = vec4(sum/(Lf*Lf),1.0);
		}')
		
		public function new()
		{
			super();
		}
}

/*
class HolyFuckShipEffect
{
	public var shader(default, null):HolyFuckShipShader = new HolyFuckShipShader();
}

class HolyFuckShipShader extends FlxShader
{
	@:glFragmentSource('
		// It's time for another episode of your favorite show :
		// -----------------------------------------------------
		// E P I C         S P A C E         A D V E N T U R E S
		//         ...with Rangiroa and the Commander !
		//
		// EPISODE 457 :  "Giant Ventifacts Of Calientis V"
		//
		// -----------------------------------------------------
		//
		// In the last episode, the Commander has finally found the
		// Lost City Of Sandara ! But the place is dead. It's
		// been abandonned for centuries. Crushed by the discovery,
		// with no hope left, our hero repairs a rocket-powered
		// ground-effect vehicle to cross the Great Desert of
		// Calientis V : 5000 miles of scorching hot sand mixed with
		// salts and sulfur. Meanwhile, our favorite robot girl
		// has been captured by the Consortium ! Rangiroa, Queen
		// of the Space Pirates, Lunar Lady of Tycho, is being
		// brought before the evil Dr Zen for interrogation...
		//
		// Will our hero save her ? Time is running out. And
		// the Great Desert is a very old place, full of weird
		// ruins, unspeakable madness, floating temples, giant
		// ventifacts, fractal mandeltraps, ghosts, and
		// blood-thirsty horrors from a billion years ago...
		//
		// [Opening] starts !

		// Technical notes :
		//
		// Wanted to make "mesas". Ended up doing strange looking
		// ventifacts. Then added space art items. It all started
		// coming together.
		// "I like it when no plan comes together..."
		// I honestly don't now what to say except that this is
		// more "painting" than real actual "coding", and that I
		// enjoy this process tremendously.
		// The more time goes, the more I understand why Iq opened
		// that can of worms a long time ago. So thank you for that.
		//
		// Read the real adventures of Rangiroa and the Commander
		// here :

		// https://baselunaire.fr/?page_id=554

		// 18 episodes already. The concept : a fake lunar radio show
		// around 2035 that presents and promotes real Demoscene musics.
		// Why ? Well because the Scene is great, and Scene musicians
		// are the best, and we should talk about it more often,
		// THAT'S WHY !

		// The music for this shader is "A Defender Rises" by Skaven252.
		// You can download or listen to it on Soundcloud here :
		// https://soundcloud.com/skaven252/a-defender-rises
		// This guy rules. Seriously.

		// Feel free to use this shader to illustrate your latest scifi story
		// online, make a video for a music you just composed, or anything.
		// Just give proper credit, and provide a link to this page.
		// Creative Commons 3.0, etc...

		mat2 r2d( float a ){ float c = cos(a), s = sin(a); return mat2( c, s, -s, c ); }
		float noise(vec2 st) { return fract( sin( dot( st.xy, vec2(12.9898,78.9)))*43758.5453123 ); }
		
		uniform float uTime = 0;
		
		#define TimeVar 1.5f*uTime // Let you easily tweak the global speed

		// Basic Geometry Functions.

		float sdCircle(in vec2 p, float radius, vec2 pos, float prec)
		{
			  return smoothstep(0.0,prec,radius - length(pos-p));
		}

		// This belongs to Iq...
		float sdTriangle( in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2 )
		{
			  vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
			  vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
			  vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
			  vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
			  vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
			  float s = sign( e0.x*e2.y - e0.y*e2.x );
			  vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
							   vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
							   vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
			  return -sqrt(d.x)*sign(d.y);
		}

		// This belongs to a nice shadertoy coder whose name I lost.
		// Please tell me if you read this !
		float metaDiamond(vec2 p, vec2 pixel, float r, float s)
		{
			  vec2 d = abs(r2d(s*TimeVar)*(p-pixel));
			  return r / (d.x + d.y);
		}

		// That's it guys, everything else is mine, as you can
		// see by the sudden drop in quality. :D

		vec4 drawAtmoGradient(in vec2 v_p)
		{
			  return mix( vec4(0.0,0.3,0.7,1.0), vec4(1.0,0.8,0.7,1.0), 1.0-v_p.y + 0.7);
		}

		// Ultra-super-simplified 1D noise with smooth please ?
		// We don't need more, really !
		float fbm(in vec2 v_p)
		{
			  float VarX1 = 0.0;
			  float VarX2 = 0.0;
			  float VarD0 = 0.0;
			  float VarS1 = 0.0;
			  float Amplitude = 1.0/2.0;
			  float Periode   = 2.0;
			  VarX1 = Amplitude*floor( Periode*v_p.x);
			  VarX2 = Amplitude*floor( Periode*v_p.x + 1.0);
			  VarD0 = fract( Periode*v_p.x);
			  VarS1 += mix( noise(vec2(VarX1)), noise(vec2(VarX2)), smoothstep( 0.0, 1.0, VarD0));
			  return VarS1;
		}

		float GetMesaMaxHeight(in vec2 v_p)
		{
			  float MH = 0.98
					   + 0.06*fbm(vec2(5.0*v_p.x + 0.25*TimeVar))
					   + 0.02*fbm(vec2(40.0*v_p.x + 2.0*TimeVar));
			  float Offset = 0.0;
			  if( fbm(vec2(10.0*v_p.x + 0.5*TimeVar)) > 0.30 )
				  Offset = -0.75*(fbm(vec2(10.0*v_p.x + 0.5*TimeVar)) - 0.30);
			  MH += Offset;
			  return MH;
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			 vec2 p = vec2( (iResolution.x/iResolution.y)*(fragCoord.x - iResolution.x/2.0) / iResolution.x,
							fragCoord.y / iResolution.y);

			 // Making the mouse interactive for absolutely no reason
			 float TiltX = -0.001*(iMouse.x - iResolution.x/2.0);
			 float AltiY =  0.005*(iMouse.y - iResolution.y/2.0);

			 // Propagating user-induced chaos...
			 p = p * (1.2 - 0.1*AltiY);
			 p *= r2d(TiltX);

			 // This, gentlemen, is our World : a single vector.
			 // Don't tell Elon, he's gonna freak out.
			 vec4 col = vec4(0.0,0.0,0.0,1.0);

			 // Here's an atmosphere so you can choke...
			 col = drawAtmoGradient(p + vec2(0.0,0.75));

			 // For 25 TimeVars, make the screen ondulate
			 // Like it's hot in the desert or something...
			 // Use iTime instead of TimeVar because whatever
			 // the speed of the desert, heat distorsion should stay realtime.
			 if( mod(TimeVar,50.0) < 25.0 ) p += vec2((0.0005 + 0.0005*fbm(vec2(0.2*iTime)))*sin(50.0*p.y - 25.0*iTime),0.0);

			 // Classic French cuisine : how to make croissants.
			 float FD1 = sdCircle(p,0.50,vec2(-0.70,1.0),0.01);
			 float DS1 = sdCircle(p,0.57,vec2(-0.75,1.0),0.07);
			 float Croissant1 = FD1 - DS1;
			 col += clamp(Croissant1,0.0,1.0);

			 // I'm a friendly guy : I offer you another croissant !
			 float FD2 = sdCircle(p,0.20,vec2(-0.75,0.75),0.01);
			 float DS2 = sdCircle(p,0.27,vec2(-0.79,0.74),0.07);
			 float Croissant2 = FD2 - DS2;
			 col += 0.3*FD2*texture(iChannel2,2.0*r2d(3.5)*p + vec2(0.003*TimeVar,0.0));
			 col += clamp(2.0*Croissant2,0.0,1.0);

			 // Okay you get a third one.
			 float FD3 = sdCircle(p,0.10,vec2( 0.80, 0.77),0.01);
			 float DS3 = sdCircle(p,0.16,vec2( 0.83, 0.76),0.07);
			 float Croissant3 = FD3 - DS3;
			 col += 0.3*FD3*texture(iChannel1,1.5*r2d(3.5)*p + vec2(0.001*TimeVar,0.0));
			 col += clamp(2.0*Croissant3,0.0,1.0);

			 // Trinary Star System + Some Modulation
			 float BV1 = 0.7 + 0.3*fbm(vec2(0.3*TimeVar         ));
			 float BV2 = 0.7 + 0.3*fbm(vec2(0.3*TimeVar + 250.0 ));
			 float BV3 = 0.5 + 0.5*fbm(vec2(0.3*TimeVar + 350.0 ));

			 // Star Cross (with gimbal-assist)
			 p += vec2(-0.5,-0.9);
			 p *= r2d(-TiltX);
			 col += metaDiamond( p, vec2( 0.0, 0.0), BV1*0.020, 0.0);
			 col += 0.5*smoothstep(0.08,0.0,abs(p.y))*smoothstep(0.0015,0.0,abs(p.x));
			 col += 0.5*smoothstep(0.08,0.0,abs(p.x))*smoothstep(0.0015,0.0,abs(p.y));
			 p *= r2d(3.14159/4.0);
			 col += 0.5*smoothstep(0.05,0.0,abs(p.y))*smoothstep(0.0015,0.0,abs(p.x));
			 col += 0.5*smoothstep(0.05,0.0,abs(p.x))*smoothstep(0.0015,0.0,abs(p.y));
			 p *= r2d(-3.14159/4.0);
			 p *= r2d( TiltX);
			 p -= vec2(-0.5,-0.9);

			 // Medium Star
			 p += vec2(-0.30,-1.05);
			 p *= r2d(-TiltX);
			 col += metaDiamond( p, vec2( 0.0, 0.0), BV2*0.005, 0.0);
			 p *= r2d( TiltX);
			 p -= vec2(-0.30,-1.05);

			 // Small Star
			 p += vec2(-0.25,-1.08);
			 p *= r2d(-TiltX);
			 col += metaDiamond( p, vec2( 0.0, 0.0), BV3*0.002, 0.0);
			 p *= r2d( TiltX);
			 p -= vec2(-0.25,-1.08);

			 if( p.y < 0.5 )
			 {
				 // Beneath 0.5 : The Salt Flats
				 col  = vec4(0.7,0.7,0.6,1.0);
				 col += 0.5*vec4(texture(iChannel2,vec2( 0.50*(p.x)/((0.50-p.y)) + 4.0*TimeVar, log(0.50-p.y))));
			 }else{
				 // Above 0.5 : The mountains of "New New Mexico" (aka "Calientis V")
				 col = mix(col,
						   vec4(0.74,0.74,0.9,1.0)*(0.5+0.2*texture(iChannel0,2.0*(p + vec2(0.02*TimeVar,0.0)))),
						   smoothstep(0.005,0.0,p.y + 0.05*fbm(vec2(2.5*p.x + 0.05*TimeVar)) - 0.57));
			 };

			 // Moebius-like floating temple right in the middle of the desert.
			 // Because existential horror can strike anytime, anywhere. :p
			 // Dedicated to Arzak fans...
			 // Alternative title : "Easy fake lame DIY 3D in your 2D scene : an introduction"

			 vec4 Color1 = vec4(0.9,0.9,1.0,1.0) - 0.15*texture(iChannel0,vec2(0.01*p.x,p.y - 0.01*sin(0.4*TimeVar))).xxxx;
			 vec4 Color2 = vec4(0.7,0.7,1.0,1.0) - 0.15*texture(iChannel0,vec2(0.01*p.x,p.y - 0.01*sin(0.4*TimeVar))).xxxx;
			 vec4 Face1;
			 vec4 Face2;

			 // BOOM ! You didn't see anything... ... Oh shut up, Gandalf !
			 if( mod(0.005*TimeVar,0.08) < 0.04)
			 {
				 Face1 = Color1;
				 Face2 = Color2;
			 }else{
				 Face1 = Color2;
				 Face2 = Color1;
			 };

			 // The Moebius Rock floats. And sings.
			 // I can hear it. My dog can hear it.
			 // Why can't you ?!
			 float AltitudeMoebius = 0.550 + 0.01*sin(0.4*TimeVar);

			 p += vec2(mod(0.03*TimeVar,4.0) - 2.0,0.0);

			 // Top Pylon
			 col = mix(Face1,col,smoothstep(0.0,0.002,
			 sdTriangle(p,
			 vec2(-0.0200, AltitudeMoebius + 0.04),
			 vec2( 0.0200, AltitudeMoebius + 0.04),
			 vec2( 0.0000, AltitudeMoebius + 0.48) )));
			 col = mix(Face2,col,smoothstep(0.0,0.002,
			 sdTriangle(p,
			 vec2(-0.0200                          , AltitudeMoebius + 0.04),
			 vec2( 0.0200 - mod(0.005*TimeVar,0.04), AltitudeMoebius + 0.04),
			 vec2( 0.0000                          , AltitudeMoebius + 0.48) )));

			 // Bottom Tetrahedron
			 col = mix(0.9*Face1,col,smoothstep(0.0,0.002,
			 sdTriangle(p,
			 vec2(-0.0200, AltitudeMoebius + 0.03),
			 vec2( 0.0200, AltitudeMoebius + 0.03),
			 vec2( 0.0000, AltitudeMoebius - 0.02) )));
			 col = mix(0.9*Face2,col,smoothstep(0.0,0.002,
			 sdTriangle(p,
			 vec2(-0.0200                          , AltitudeMoebius + 0.03),
			 vec2( 0.0200 - mod(0.005*TimeVar,0.04), AltitudeMoebius + 0.03),
			 vec2( 0.0000                          , AltitudeMoebius - 0.02) )));

			 // Ghostly Beacons
			 col += metaDiamond( p, vec2( 0.0,AltitudeMoebius + 0.50), 0.001, 0.0);
			 col += vec4(1.0,0.0,0.0,1.0)*metaDiamond( p, vec2( 0.0,AltitudeMoebius + 0.52), 0.001, 0.0);

			 p -= vec2(mod(0.03*TimeVar,4.0) - 2.0,0.0);

			 if( p.y > 0.5 )
			 {
				 // Very strange method to make 2D "mesas". Not sure it actually makes sense.
				 // The final shapes are a bit pointy, which is fine for an extraterrestrial
				 // desert, I suppose. Less so for martian mesas... Ah, well. Next time, in
				 // another shader (incidentally I just figured out how to do it properly).
				 // Anyway, let's pretend these are "giant ventifacts".
				 float Inc = 1.0*p.x + 0.05*TimeVar; // Unit speed of Ventifacts relative to p.x (20:1 ratio)
				 float MesaMaxHeight = GetMesaMaxHeight(p);
				 float MesaLine = clamp( fbm(vec2(2.0*Inc + 0.005*fbm(vec2(80.0*p.y)))), 0.0, MesaMaxHeight);

				 // Make the Sand follow a curve that is (more or less) realistic
				 // Adding octaves, usual fbm impro stuff, you know the drill...
				 float SandLine = 0.480 + 0.100*fbm(vec2( 2.0*Inc))
										+ 0.008*fbm(vec2(20.0*Inc))
										+ 0.002*fbm(vec2(60.0*Inc));

				 // Basic Color + Vertically-stretched Texture + Horizontally-stretched Texture
				 vec4 MesaColors = vec4(1.0,0.8,0.7,1.0);
				 MesaColors += 0.5*texture(iChannel1,vec2(     Inc, 0.2*p.y));
				 MesaColors += 0.5*texture(iChannel1,vec2( 0.1*Inc,     p.y));

				 // Basic random shadows + slanted highlights...
				 MesaColors -= 0.35*smoothstep( 0.0, 1.0, fbm(vec2(40.0*Inc)) + fbm(vec2(15.0*p.y - 30.0*Inc)));

				 // More Shadows !
				 MesaColors = MesaColors*( 0.2 + 0.8*smoothstep( 0.0, 0.4, (MesaLine - SandLine)));

				 // Additional shadows at mesa's base.
				 float VerticalWeathering = 1.0;
				 VerticalWeathering *= (0.8+0.2*smoothstep(0.0,0.02,(p.y - 0.6 + 0.25*fbm(vec2(80.0*Inc)))));
				 MesaColors *= VerticalWeathering;

				 // Outputing mesas like big giant rotten teeth on a dead dragon's jaw...
				 col = mix( col, MesaColors, smoothstep(0.007,0.0,p.y - MesaLine));

				 // Adding highlights, because "secondary reflections", "ambient occlusion", etc
				 // (haha, yeah right)
				 col *= clamp(smoothstep(-0.15,0.0,p.y - MesaLine + 0.01*fbm(vec2(10.0*Inc))),0.5,1.0);

				 // Mesas shadows on the sand...
				 float SandShadows = 0.0;
				 // If we're in the shadow of a mesa, SandLine altitude should decrease (...feeling of volume)
				 if( SandLine < MesaLine ) SandLine = SandLine - 0.2*(MesaLine - SandLine);
				 // Defining SandColors. Adding some y-stretched texture to simulate local sandslides.
				 vec4 SandColors = 0.80*vec4(0.3,0.2,0.2,1.0)
								 + 0.20*texture(iChannel0,vec2(2.0*Inc,0.1*p.y + 0.0));

				 // If we are in the shadow of a mesa
				 if( SandLine < MesaLine)
				 {
					 // on-the-fly logic, probably false, but
					 // just right enough to be useful.
					 // "Paint-coding", guys...
					 if( p.y > SandLine - (MesaLine - SandLine) )
					 {
						 SandShadows = 0.7;
					 }else{
						 SandShadows = 1.0;
					 };
				 }else{
					 SandShadows = 1.0;
				 };

				 // Outputing shaded sand dune, "MY DUNE !" haha
				 col = mix(col,SandShadows*SandColors,smoothstep(0.0025,0.0,p.y - SandLine));
			};

			 vec2  ConsortiumShipPos = vec2( 2.0-mod(0.01*TimeVar + 1.0,4.0), -1.2);
			 float ConsortiumShipPrec = 0.0035;
			 vec4  HullColorFix = vec4(0.5,0.8,1.0,1.0);
			 vec4  HullColorTop;
			 vec4  HullColorBottom;


			 // Move ship to position !
			 p += ConsortiumShipPos;
			 // Zoom Zoom Zoom !
			 p *= 0.75;

			 // Tweaking Ship Colors to make them just right (i.e. blend into the sky).
			 HullColorTop    = HullColorFix*vec4(0.6,0.6,1.0,1.0) + 0.2*texture(iChannel0,vec2(2.0*p.x,0.1*p.y)).xxxx;
			 HullColorTop *= 1.2;
			 // Tweaking Ship Colors.
			 HullColorBottom = HullColorFix*vec4(0.8,0.8,1.0,1.0) + 0.4*texture(iChannel0,vec2(0.5*p.x,0.1*p.y)).xxxx;
			 HullColorBottom *= 0.6;

			 // Fusion-Drive Tail visible due to reaction mass impurities (grey water from comets).
			 if(p.x < 0.0) col += smoothstep(0.12,0.0,abs(0.2*p.x))*smoothstep(0.01,0.0,abs(p.y));

			 // How to draw a spaceship in six triangles : a tutorial.

			 // Forward part
			 col = mix(HullColorTop,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2( 0.145, 0.00),
			 vec2( 0.200, 0.01),
			 vec2( 0.355, 0.00) )));
			 col = mix(HullColorBottom,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2( 0.145, 0.00),
			 vec2( 0.200,-0.015),
			 vec2( 0.355, 0.00) )));

			 // Middle Part
			 col = mix(HullColorTop,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2( 0.000, 0.00),
			 vec2( 0.005, 0.01),
			 vec2( 0.150, 0.00) )));
			 col = mix(HullColorBottom,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2( 0.000, 0.00),
			 vec2( 0.005,-0.01),
			 vec2( 0.150, 0.00) )));

			 // Back Part
			 col = mix(HullColorTop,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2(-0.005, 0.00),
			 vec2( 0.010, 0.02),
			 vec2( 0.070, 0.00) )));
			 col = mix(HullColorBottom,col,smoothstep(0.0,ConsortiumShipPrec,
			 sdTriangle(p,
			 vec2(-0.005, 0.00),
			 vec2( 0.010,-0.02),
			 vec2( 0.070, 0.00) )));

			 // End tutorial. You're welcome. :D

			 // Fusion-Drive Glow (...keep this end at a distance)
			 p += vec2( 0.005,-0.002);
			 p *= r2d(-TiltX);
			 col += metaDiamond(p,vec2(0.0,0.0), 0.010, 0.0);
			 p *= r2d( TiltX);
			 p -= vec2( 0.005,-0.002);
			 // De-Zoom
			 p *= 1.0/0.75;
			 // Back to normal p.
			 p -= ConsortiumShipPos;

			 // Le Hovercraft

			 vec2  HovercraftPos   = vec2(0.05  - 0.3*fbm(vec2(0.1*TimeVar)),-0.35);
			 float HovercraftTrail = 0.335;
			 float HovercraftBoost = 0.0;

			 // Shadow
			 col = mix(vec4(0.5),col,smoothstep(0.0,0.001,
			 sdTriangle(p + HovercraftPos + vec2( 0.0, 0.01 ),
			 vec2(-0.01+ 0.001*sin(2.0*TimeVar), 0.0050),
			 vec2(-0.01+ 0.001*sin(2.0*TimeVar),-0.0050),
			 vec2( 0.04- 0.001*sin(2.0*TimeVar), 0.000) )));

			 // Lifting Body
			 col = mix(vec4(0.5),col,smoothstep(0.0,0.001,
			 sdTriangle(p + HovercraftPos + vec2( 0.0,- 0.001*sin(2.0*TimeVar) ),
			 vec2(-0.01, 0.0050),
			 vec2(-0.01,-0.0050),
			 vec2( 0.04, 0.000) )));

			 // Vertical Tail
			 col = mix(vec4(0.4),col,smoothstep(0.0,0.001,
			 sdTriangle(p + HovercraftPos + vec2( 0.0,- 0.001*sin(2.0*TimeVar) ),
			 vec2(-0.010, 0.0050),
			 vec2(-0.015, 0.015),
			 vec2( 0.000, 0.0050) )));

			 // Cockpit Canopy
			 col = mix(vec4(0.2),col,smoothstep(0.0,0.001,
			 sdTriangle(p + HovercraftPos + vec2( 0.0,- 0.001*sin(2.0*TimeVar) ),
			 vec2( 0.000, 0.0050),
			 vec2( 0.005, 0.0000),
			 vec2( 0.025, 0.0010) )));

			 // Dust Trail
			 if( p.x < -0.05  + 0.3*fbm(vec2(0.1*TimeVar)) - 0.01 )
				 col += 0.1*smoothstep(0.0,0.01,p.y - HovercraftTrail)
						   *smoothstep(0.035,0.0, p.y -0.015*abs(5.0*(p.x + HovercraftPos.x))
															*fbm(vec2(10.0*(p.x + HovercraftPos.x) + 10.0*TimeVar)) - 0.98*HovercraftTrail);
			 // Very lame yet mostly accurate thruster simulation.
			 // This shader is a disgrace to mathematics, exhibit 41 :
			 if( fbm(vec2(0.1*(TimeVar + 0.1))) - fbm(vec2(0.1*(TimeVar))) > 0.005)
			 {
				// Haha rocket goes BRRRRRR !
				HovercraftBoost = 0.005;
			 }else{
				// Puff Puff Puff Puff Puff
				HovercraftBoost = abs(0.003*sin(20.0*TimeVar));
			 };

			 // Rocket Blast
			 col += vec4(1.0,0.5,0.5,1.0)*metaDiamond(p + HovercraftPos + vec2(  0.015,- 0.0015*sin(2.0*TimeVar)),vec2( 0.0,0.0), HovercraftBoost, 10.0);

			 // A bit of dust in the air...
			 if( p.y > 0.5) col += 0.25*smoothstep(0.25,0.0,p.y - 0.1*fbm(vec2(2.0*p.x + 1.0*TimeVar)) - 0.5);

			 // Make a haze just above the ground in the distance.
			 col += 0.2*smoothstep(0.01,0.0,abs(p.y-0.5));

			 // For the last 25 TimeVars of a 50 TimeVars cycle...
			 if( mod(TimeVar,50.0) > 25.0 )
			 {
				 // Draw some Nasa camera crosses to look cool and realistic (hahahahaha)
				 if(mod(fragCoord.y + 200.0,400.0) > 399.0) if(mod(fragCoord.x + 50.0 + 200.0,400.0) < 100.0) col = vec4(0.2,0.2,0.2,1.0);
				 if(mod(fragCoord.x + 200.0,400.0) > 399.0) if(mod(fragCoord.y + 50.0 + 200.0,400.0) < 100.0) col = vec4(0.2,0.2,0.2,1.0);
			 };

			 // Lensflares ! Lensflares everywhere !
			 
			 // Big Star
			 // Let's compute Mesa's height at the Big Star's x-coordinate.
			 float NewMesaLine = clamp( fbm(vec2(2.0*(0.5 + 0.05*TimeVar)) + 0.005*fbm(vec2(80.0*0.9))),0.0,GetMesaMaxHeight(vec2(0.5,0.0)));

			 p += vec2(-0.5,-0.9);
			 p *= r2d(-TiltX);
			 col += 0.2
					   // If the mesa's top is above the Big Star, remove lensflare.
					   *smoothstep(0.0,0.01,0.9-NewMesaLine)
					   // If the Moebius Rock clips the Big Star, remove lensflare.
					   *smoothstep(0.0,0.01,abs(mod(0.03*TimeVar,4.0) - 2.0 + 0.5))
					   // Basic Hand-Made Linear 2D Lensflare
					   // the best kind, like granma used to...
					   *smoothstep(0.03,0.0,abs(p.y))
					   *smoothstep(2.00,0.0,abs(p.x));
			 // Circle around the Big Star. Not exactly JWST-worthy, I know.
			 // Look, I'm just doing my best, okay ?! :D
			 col += 0.1*smoothstep(0.0125,0.0,abs(sdCircle(p,0.05,vec2(0.0),0.07) - 0.0125))
					   *smoothstep(0.0,0.01,0.9-NewMesaLine)
					   *smoothstep(0.0,0.01,abs(mod(0.03*TimeVar,4.0) - 2.0 + 0.5));
			 p *= r2d( TiltX);
			 p -= vec2(-0.5,-0.9);

			 // Medium Star
			 p += vec2(-0.30,-1.05);
			 p *= r2d(-TiltX);
			 col += 0.1*smoothstep(0.01,0.0,abs(p.y))
					   *smoothstep(0.50,0.0,abs(p.x));
			 p *= r2d( TiltX);
			 p -= vec2(-0.30,-1.05);

			 // Small Star
			 p += vec2(-0.25,-1.08);
			 p *= r2d(-TiltX);
			 col += 0.1*smoothstep(0.01,0.0,abs(p.y))
					   *smoothstep(0.25,0.0,abs(p.x));
			 p *= r2d( TiltX);
			 p -= vec2(-0.25,-1.08);

			 // Every 25 TimeVars, pretend like you're watching through an Active SunShade
			 // that cancels heat distorsion through some kind of adaptative optics magic.
			 // Hey, it's the future after all.
			 if(mod(TimeVar,50.0) > 25.0) col *= vec4(1.0,0.8,0.7,1.0);

			 // HO MY GOD !
			 fragColor = col;
		}')
	
	public function new()
	{
		super();
	}
}
*/