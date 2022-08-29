package;

import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUI;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import lime.app.Application;

class MusicBeatState extends FlxUIState
{
	public static var lastState:FlxState;
	
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;
	
	public var preventNoob:Bool = false;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;
	
	public var assets:Array<FlxBasic> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		Paths.clearStoredMemory();
		if ((!Std.isOfType(this, PlayState)) && (!Std.isOfType(this, ChartingState)))
			Paths.clearUnusedMemory();
		/*
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		*/
		
		if (transIn != null)
			trace('reg ' + transIn.region);
		
		super.create();
	}
	
	// Stole from Kade Engine 1.8 lmao
	
	/*
	override function destroy()
	{
		
		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		
		super.destroy();
	}
	*/

	override function update(elapsed:Float)
	{
		if (preventNoob)
			return;
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
