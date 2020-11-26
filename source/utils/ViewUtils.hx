package utils;

import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.util.FlxColor;

class ViewUtils
{
	public static function centerNestedSprite(sprite:FlxNestedSprite, x:Int = 0, y:Int = 0)
	{
		sprite.relativeX = x - (sprite.width / 2);
		sprite.relativeY = y - (sprite.height / 2);
	}

	// make sure to center first before add()'ing the sprite!!! Or else it wont work!!
	public static function centerSprite(sprite:FlxSprite, x:Int = 0, y:Int = 0)
	{
		sprite.x = x - (sprite.width / 2);
		sprite.y = y - (sprite.height / 2);
	}

	// quick way to make a tiny white dot, good for marking a spot during debug mode.
	public static function newAnchor()
	{
		return new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
	}
}
