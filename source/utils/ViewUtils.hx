package utils;

import flixel.FlxSprite;

class ViewUtils
{
	public static function centerSprite(sprite:FlxSprite, x:Int = 0, y:Int = 0)
	{
		sprite.x = x - (sprite.width / 2);
		sprite.y = y - (sprite.height / 2);
	}
}
