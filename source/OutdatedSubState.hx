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
	
	override function load()
	{
		trace('bruh lmao');
		
		super.load();
	}
	
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
			switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			var randomNumeral:Int = Std.random(5);
			var txtInsert:String = '';
			// This is a weird spot lmao
			switch (randomNumeral)
			{
				case 0:
					txtInsert = 'BEES! OH GOD THE BEES!';
				case 1:
					txtInsert = 'Joe';
				case 2:
					txtInsert = "like i'm gonna change engines lmao";
				case 3:
					txtInsert = 'thump thump thump thump';
				case 4:
					txtInsert = 'hoodini';
				case 5:
					txtInsert = 'mcdonlad brugr';
			}
			var txt:FlxText = new FlxText(0, 0, FlxG.width, txtInsert, 32);
			txt.setFormat("VCR OSD Mono", 32, FlxColor.GREEN, CENTER);
			txt.screenCenter();
			add(txt);
			leftState = true;
			switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
