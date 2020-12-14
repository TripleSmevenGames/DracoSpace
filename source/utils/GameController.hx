package utils;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;

class GameController
{
	// global RNG to use throughout a run
	public static var rng:FlxRandom;

	// global save object
	public static var save:FlxSave;

	// global view manager for playState views
	public static var subStateManager:SubStateManager;

	public static function initSave()
	{
		save = new FlxSave();
		save.bind('save');
	}

	public static function initRng()
	{
		var seed:Null<Int> = GameController.save.data.seed;
		if (seed == null)
			rng = new FlxRandom();
		else
			rng = new FlxRandom(seed);
	}
}
