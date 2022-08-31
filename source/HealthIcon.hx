package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.FileSystem;
#end

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	
	public var characterTxt:String = 'bf';
	
	public var composition:Int = 1; // Either the defeat icon and the idle icon, or more!

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		// Tbh shout out to Forever Engine
		characterTxt = char;
		var splitter:Array<String> = characterTxt.split('-');
		var split = splitter[0];
		super();
		try
		{
			if (FileSystem.exists(Paths.getPath('images/icons/icon-' + characterTxt + '.png', IMAGE, null)))
				loadGraphic(Paths.image('icons/icon-' + characterTxt), true, 150, 150);
			else if (FileSystem.exists(Paths.getPath('images/icons/icon-' + split + '.png', IMAGE, null)))
				loadGraphic(Paths.image('icons/icon-' + split), true, 150, 150);
			else
				loadGraphic(Paths.image('icons/icon-face'), true, 150, 150);
		} catch (e) {
			trace('No actually what the fuck man ($e)');
		}
		
		var tempArray:Array<Int> = [];
		for (i in 0...composition)
		{
			tempArray.push(i);
		}

		antialiasing = true;
		animation.add(characterTxt, tempArray, 0, false, isPlayer);
		animation.play(characterTxt);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
