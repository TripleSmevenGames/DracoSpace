package utils;

import haxe.Exception;

// utility functions and globals for game logic.
class GameUtils
{
	public static function weightedPick<T>(items:Array<T>, weights:Array<Float>)
	{
		if (items.length != weights.length)
		{
			throw new Exception('items and weights not same length');
		}
		return items[GameController.rng.weightedPick(weights)];
	}
}
