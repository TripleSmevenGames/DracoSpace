package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import managers.GameController;

class FlxGameDebug extends FlxGame
{
	public function new(GameWidth:Int = 0, GameHeight:Int = 0, ?InitialState:Class<FlxState>, Zoom:Float = 1, UpdateFramerate:Int = 60,
			DrawFramerate:Int = 60, SkipSplash:Bool = false, StartFullscreen:Bool = false)
	{
		super(GameWidth, GameHeight, InitialState, Zoom, UpdateFramerate, DrawFramerate, SkipSplash, StartFullscreen);
	}

	override public function update()
	{
		try
		{
			super.update();
		}
		catch (e)
		{
			GameController.latestException = e;
			trace(e.message);
			trace(e.stack);
			if (e.previous != null)
			{
				trace(e.previous.message);
				trace(e.previous.stack);
			}
			else
			{
				trace('no previous');
			}
			FlxG.switchState(new CrashState());
		}
	}
}
