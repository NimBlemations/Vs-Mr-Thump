import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import sys.thread.Mutex;
import flixel.FlxG;
import flixel.FlxState;

class LoadingBar extends MusicBeatState
{
	var target:MusicBeatState;
	var loadMutex:Mutex;

	var bar:FlxBar;

	public static var progress:Int = 0;

	public var localProg:Int = 0;

	public function new(_target:MusicBeatState)
	{
		target = _target;
		trace('loadee bar');
		loadMutex = new Mutex();
		super();
	}
	
	var startLoad:Bool = false;
	
	override function create()
	{
		progress = 0;
		
		bar = new FlxBar(24, 684, FlxBarFillDirection.LEFT_TO_RIGHT, 1224, 12, this, "localProg", 0, 100);
		bar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(255, 22, 210));
		bar.scrollFactor.set();
		add(bar);

		trace('Welcome to loading with ' + bar);

		super.create();
	}
	
	override function update(elapsed:Float)
	{
		if (!startLoad)
		{
			startLoad = true;
			sys.thread.Thread.create(() ->
			{
				loadMutex.acquire();
				trace('resetti');
				MasterObjectLoader.resetAssets();
				target.load();
				target.loadedCompletely = true;
				trace('letsa gooo ' + target);
				switchState(target, false, true);
				loadMutex.release();
			});
		}
		localProg = progress;
		super.update(elapsed);
	}
}