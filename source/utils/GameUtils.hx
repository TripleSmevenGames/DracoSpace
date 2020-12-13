package utils;

import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import haxe.Exception;

// utility functions and globals for game logic.
class GameUtils
{
	// global RNG to use throughout a run
	public static var rng:FlxRandom;

	// global save object
	public static var save:FlxSave;

	public static function weightedPick<T>(items:Array<T>, weights:Array<Float>)
	{
		if (items.length != weights.length)
		{
			throw new Exception('items and weights not same length');
		}
		return items[rng.weightedPick(weights)];
	}
}
