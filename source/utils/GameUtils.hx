package utils;

import flixel.math.FlxRandom;
import haxe.Exception;

class GameUtils
{
	public static function weightedPick<T>(items:Array<T>, weights:Array<Int>)
	{
		if (items.length != weights.length || items.length == 0 || weights.length == 0)
		{
			throw new Exception('bad weighted pick');
		}
		if (items.length == 1)
		{
			return items[0];
		}
		var sum = 0;
		for (weight in weights)
		{
			sum += weight;
		}
		var pick = new FlxRandom().int(1, sum);
		for (i in 0...items.length)
		{
			if (pick <= weights[i])
			{
				return items[i];
			}
			else
			{
				pick -= weights[i];
			}
		}
		throw new Exception('weighted pick got to end');
	}
}
