package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import lime.utils.Assets;

using StringTools;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var halloweenBG:FlxSprite;
	
	public var curStage:String;
	
	public function new(curStage) 
	{
		super();
		this.curStage = curStage;
		
		trace("ayo we got a " + curStage + " over here");
		
		switch (curStage)
		{
			case 'spooky':
				var hallowTex = Paths.getSparrowAtlas('halloween_bg');
				
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
		}
	}
	
}