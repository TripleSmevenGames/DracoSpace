package utils;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class DebugUtils
{
	/** quick way to make a tiny dot, good for marking a spot during debug mode. 
	 * To ensure it is visible, try to make it the LAST thing you add() it the group its inside.
	**/
	public static function newAnchor(color = FlxColor.WHITE)
	{
		return new FlxSprite(0, 0).makeGraphic(4, 4, color);
	}
}
