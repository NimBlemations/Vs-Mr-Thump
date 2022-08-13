package;

import flixel.addons.ui.FlxUI;
#if !html5
import sys.thread.Mutex;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.system.System;

// Stole from Hex Engine lmao

class MasterObjectLoader 
{
	#if !html5
	public static var mutex:Mutex;
	#end
	
	public static var Objects:Array<Dynamic> = [];

	public static function addObject(bruh:Dynamic)
	{
		if (Std.isOfType(bruh, FlxSprite))
		{
			var sprite:FlxSprite = cast(bruh, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(bruh, FlxUI))
			return;
		#if !html5
		mutex.acquire();
		#end
		/*
		#if debug
		trace('lmao adding ' + Type.getClassName(Type.getClass(bruh)));
		#end
		*/
		Objects.push(bruh);
		#if !html5
		mutex.release();
		#end
	}

	public static function removeObject(object:Dynamic)
	{
		if (Std.isOfType(object, FlxSprite))
		{
			var sprite:FlxSprite = cast(object, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(object, FlxUI))
			return;
		#if !html5
		mutex.acquire();
		#end
		/*
		#if debug
		trace('lmao removing ' + Type.getClassName(Type.getClass(object)));
		#end
		*/
		Objects.remove(object);
		#if !html5
		mutex.release();
		#end
	}

	public static function resetAssets(?removeLoadingScreen:Bool = false)
	{
		var keep:Array<Dynamic> = [];
		#if !html5
		mutex.acquire();
		#end
		for (object in Objects)
		{
			if (Std.isOfType(object, FlxSprite))
			{
				var sprite:FlxSprite = object;
				if (sprite.ID >= 99999 && !removeLoadingScreen) // loading screen assets
				{
					keep.push(sprite);
					continue;
				}
				#if debug
				trace('lmao clearing sprite ' + Type.getClassName(Type.getClass(sprite)));
				#end
				FlxG.bitmap.remove(sprite.graphic);
				sprite.destroy(); // I may have to do this to prevent crashes
			}
			if (Std.isOfType(object, FlxGraphic))
			{
				var graph:FlxGraphic = object;
				#if debug
				trace('lmao clearing graph ' + Type.getClassName(Type.getClass(graph)));
				#end
				FlxG.bitmap.remove(graph);
				graph.destroy(); // I may have to do this to prevent crashes
			}
		}
		Objects = [];
		for (k in keep)
			Objects.push(k);
		System.gc();
		#if !html5
		mutex.release();
		#end
	}
	
}