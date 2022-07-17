package;

import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUI;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.system.System;

class MusicBeatState extends FlxUIState
{
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
		/*
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		*/
		
		if (transIn != null)
			trace('reg ' + transIn.region);
		
		super.create();
	}
	
	// Stole from Kade Engine 1.8 lmao
	
	override function destroy()
	{
		/*
		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		*/
		super.destroy();
	}
	
	override function remove(Object:flixel.FlxBasic, Splice:Bool = false):flixel.FlxBasic
	{
		MasterObjectLoader.removeObject(Object);
		var result = super.remove(Object, Splice);
		return result;
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (Std.isOfType(Object, FlxUI))
			return null;

		if (Std.isOfType(Object, FlxSprite))
		{
			var spr:FlxSprite = cast(Object, FlxSprite);
			if (spr.graphic != null)
			{
				if (spr.graphic.bitmap.image == null)
					trace('Oh god a null texture oh shit');
			}
		}
		// Debug.logTrace(Object);
		MasterObjectLoader.addObject(Object);

		var result = super.add(Object);
		return result;
	}
	
	public function switchState(nextState:MusicBeatState, ?trans:Bool = true)
	{
		if (preventNoob)
			return;
		preventNoob = true;
		trace('SWITCHING STATE');
		if (trans)
		{
			transitionOut(function()
			{
				MasterObjectLoader.resetAssets();
				
				@:privateAccess
				FlxG.game._requestedState = nextState;
			});
		}
		else
		{
			MasterObjectLoader.resetAssets();
			
			@:privateAccess
			FlxG.game._requestedState = nextState;
		}
		trace('SWITCHED STATE!');
		System.gc(); // Just in case lol
	}
	
	var loadedCompletely:Bool = false;

	public function load()
	{
		loadedCompletely = true;

		trace('STATE LOADED');
	}

	override function update(elapsed:Float)
	{
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
