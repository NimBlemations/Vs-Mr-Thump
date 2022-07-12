package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	
	public var characterTxt:String = 'bf';
	
	public var composition:Int = 0; // Either the defeat icon and the idle icon, or more!

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		// Tbh shout out to Forever Engine
		characterTxt = char;
		switch (characterTxt)
		{
			case 'mom-car':
				characterTxt = 'mom';
			case 'parents-christmas':
				characterTxt = 'parents';
			case 'monster-christmas':
				characterTxt = 'monster';
			case 'bf-christmas' | 'bf-car':
				characterTxt = 'bf';
			case 'gf-christmas':
				characterTxt = 'gf';
			case 'senpai-angry':
				characterTxt = 'senpai';
		}
		super();
		loadGraphic(Paths.image('icons/icon-' + characterTxt), true, 150, 150);
		if (this.frames == null)
			loadGraphic(Paths.image('icons/icon-face'), true, 150, 150);

		antialiasing = true;
		animation.add(characterTxt, [0, 1], 0, false, isPlayer);
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
