package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	
	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Kade Engine is Outdated!(Duh)\n"
			+ MainMenuState.kadeEngineVer
			+ " is your current version\nwhile the most recent version is " + needVer
			+ "!\nPress Space to not go to the github and ignore this or ESCAPE to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			var txt:FlxText = new FlxText(0, 0, FlxG.width, "No, lol.", 32);
			txt.setFormat("VCR OSD Mono", 32, FlxColor.RED, CENTER);
			txt.screenCenter();
			add(txt);
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			// This is a weird spot lmao
			var randomizedSet:Array<String> = [
				'BEES! OH GOD THE BEES!',
				'Joe',
				"like i'm gonna change engines lmao",
				'thump thump thump thump',
				'hoodini',
				'mcdonlad brugr',
				'the are the when of',
				'that kinda flumped',
				'annie are you ok',
				"good engine, but i'll pass",
				'you really know this is using an old engine',
				'who does use 1.1.3 tho?',
				'randomized text',
				'randomzied text',
				'two number 9',
				'the hamburglar is in my closet'
			];
			var randomNumeral:Int = Std.random(randomizedSet.length - 1);
			
			var txt:FlxText = new FlxText(0, 0, FlxG.width, randomizedSet[randomNumeral], 32);
			txt.setFormat("VCR OSD Mono", 32, FlxColor.GREEN, CENTER);
			txt.screenCenter();
			add(txt);
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
