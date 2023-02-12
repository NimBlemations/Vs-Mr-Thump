package;

// With the conditionals, I just want to not leave ANYTHING unnecessary behind on compile, but the flags are getting ridiculous, I know.

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display3D.textures.Texture;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}
	
	public static var dumpExclusions:Array<String> = [
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/music/foreverMenu.$SOUND_EXT',
		'assets/music/breakfast.$SOUND_EXT',
	];
	
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					if (currentTrackedTextures.exists(key)) // If Stage3D texture
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
						#if debug
						trace('ungpu\'d, biatch');
						#end
					}
					else
					{
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
					}
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
			counter++;
		}
		if (counter == 1)
			trace('removed $counter asset'); // detail lmao
		else
			trace('removed $counter assets');
		// run the garbage collector for good measure lmfao
		System.gc();
	}
	
	public static var localTrackedAssets:Array<String> = [];
	
	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}
	
	public static function returnGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		// trace(path);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				if (!currentTrackedAssets.exists(path))
				{
					var newGraphic:FlxGraphic = null;
					if (textureCompression)
					{
						var bitmap:BitmapData = OpenFlAssets.getBitmapData(path);
						var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
						texture.uploadFromBitmapData(bitmap);
						currentTrackedTextures.set(path, texture);
						bitmap.dispose();
						bitmap.disposeImage();
						bitmap = null;
						newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
					}
					else
						newGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					//////////////////////////
					// XML CHECKING!!!
					var xmlPath = getPath('images/$key.xml', TEXT, library);
					if (OpenFlAssets.exists(xmlPath))
					{
						#if debug
						trace(xmlPath);
						#end
						var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(newGraphic, xmlPath);
						if (atlasFrames != null)
						#if debug
						{
							trace('loaded xml woop woop!');
							#end
							newGraphic.addFrameCollection(atlasFrames);
							#if debug
						}
						else
							trace('augh, didn\'t work');
						#end
					}
					// Alright, done xml checking
					//////////////////////////
					currentTrackedAssets.set(path, newGraphic);
				}
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		trace('oh no $key is returning null NOOOO');
		return null;
	}
	
	public static function returnSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if (path == 'songs')
				folder = 'songs:';
			
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}
	
	public static function preloadSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			trace('preloading sound $key');
			var folder:String = '';
			if (path == 'songs')
				folder = 'songs:';
			
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
	}
	
	public static function preloadGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				if (!currentTrackedAssets.exists(path))
				{
					trace('preloading graphic $key');
					var newGraphic:FlxGraphic = null;
					if (textureCompression)
					{
						var bitmap:BitmapData = OpenFlAssets.getBitmapData(path);
						var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
						texture.uploadFromBitmapData(bitmap);
						currentTrackedTextures.set(path, texture);
						bitmap.dispose();
						bitmap.disposeImage();
						bitmap = null;
						newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
					}
					else
						newGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					//////////////////////////
					// XML CHECKING!!!
					var xmlPath = getPath('images/$key.xml', TEXT, library);
					if (OpenFlAssets.exists(xmlPath))
					{
						#if debug
						trace(xmlPath);
						#end
						var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(newGraphic, xmlPath);
						if (atlasFrames != null)
						#if debug
						{
							trace('preloaded xml woop woop!');
							#end
							newGraphic.addFrameCollection(atlasFrames);
							#if debug
						}
						else
							trace('augh, didn\'t work');
						#end
					}
					// Alright, done xml checking
					//////////////////////////
					currentTrackedAssets.set(path, newGraphic);
				}
			}
			localTrackedAssets.push(path);
		}
		else
			trace('oh no $key is null NOOOO');
	}
	
	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}
	
	inline static public function chart(key:String, ?library:String)
	{
		return getPath('data/$key.chart', TEXT, library);
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${song.toLowerCase()}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${song.toLowerCase()}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String, ?textureCompression:Bool = false):FlxGraphic
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library, textureCompression);
		return returnAsset;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('music/$key.mp4', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var graphic:FlxGraphic = returnGraphic(key, library, textureCompression);
		return FlxAtlasFrames.fromSparrow(graphic, file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
