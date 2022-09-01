package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	
	public function new(noteData:Int) 
	{
		super();
		
		frames = Paths.getSparrowAtlas('noteSplashes');
		
		animation.addByPrefix('splatP1', 'note impact 1 purple0', 24, false);
		animation.addByPrefix('splatB1', 'note impact 1  blue0', 24, false);
		animation.addByPrefix('splatG1', 'note impact 1 green0', 24, false);
		animation.addByPrefix('splatR1', 'note impact 1 red0', 24, false);
		
		animation.addByPrefix('splatP2', 'note impact 2 purple0', 24, false);
		animation.addByPrefix('splatB2', 'note impact 2 blue0', 24, false);
		animation.addByPrefix('splatG2', 'note impact 2 green0', 24, false);
		animation.addByPrefix('splatR2', 'note impact 2 red0', 24, false);
		
		var rand:Int = Std.random(1) + 1;
		switch (noteData)
		{
			case 0:
				animation.play('splatP' + rand, true, false, 0);
			case 1:
				animation.play('splatB' + rand, true, false, 0);
			case 2:
				animation.play('splatG' + rand, true, false, 0);
			case 3:
				animation.play('splatR' + rand, true, false, 0);
		}
	}
}