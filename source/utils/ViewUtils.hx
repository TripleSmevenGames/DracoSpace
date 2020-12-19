package utils;

import constants.Constants.Colors;
import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.util.FlxColor;
import models.skills.Skill;

// utils for handling sprites and views.
class ViewUtils
{
	public static function centerNestedSprite(sprite:FlxNestedSprite, x:Float = 0, y:Float = 0)
	{
		sprite.relativeX = x - (sprite.width / 2);
		sprite.relativeY = y - (sprite.height / 2);
	}

	/**
	 * Best used to center sprites inside sprite groups.
	 * Make sure you know if you are using local or global coordinates.
	 *
	 * Best used before you add the sprite to its group. If done like this, the x and y coords should be local coords.
	 * Meaning the coords are of a sprite that's also not added yet, or the group is at 0, 0 at time of calling.
	 */
	public static function centerSprite(sprite:FlxSprite, x:Float = 0, y:Float = 0)
	{
		sprite.x = x - (sprite.width / 2);
		sprite.y = y - (sprite.height / 2);
	}

	// quick way to make a tiny white dot, good for marking a spot during debug mode.
	public static function newAnchor()
	{
		return new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
	}

	public static function getColorForType(type:SkillPointType)
	{
		switch (type)
		{
			case POW:
				return Colors.DARK_RED;
			case AGI:
				return Colors.DARK_YELLOW;
			case CON:
				return Colors.DARK_GREEN;
			case KNO:
				return Colors.DARK_BLUE;
			case WIS:
				return Colors.DARK_PURPLE;
			default:
				return FlxColor.GRAY;
		}
	}
}
