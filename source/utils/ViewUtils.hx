package utils;

import constants.Colors;
import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.battle.status.Status.StatusType;

// utils for handling sprites and views.
class ViewUtils
{
	public static function centerNestedSprite(sprite:FlxNestedSprite, x:Float = 0, y:Float = 0)
	{
		sprite.relativeX = x - (sprite.width / 2);
		sprite.relativeY = y - (sprite.height / 2);
	}

	/**
	 * Best used to center sprites inside sprite groups. Don't center a group in a group, if the group's sprites are centered.
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

	public static function centerX(sprite:FlxSprite, x:Float = 0)
	{
		sprite.x = x - (sprite.width / 2);
	}

	public static function centerY(sprite:FlxSprite, y:Float = 0)
	{
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
				return Colors.POWER_RED;
			case AGI:
				return Colors.AGILITY_YELLOW;
			case CON:
				return Colors.CONSTITUTION_GREEN;
			case KNO:
				return Colors.KNOWLEDGE_BLUE;
			case WIS:
				return Colors.WISDOM_PURPLE;
			default:
				return FlxColor.GRAY;
		}
	}

	public static function getColorForStatus(status:StatusType)
	{
		switch (status)
		{
			case BURN:
				return Colors.BURN_ORANGE;
			case COLD:
				return Colors.COLD_BLUE;
			case STATIC:
				return Colors.STATIC_BLUE;
			default:
				return FlxColor.WHITE;
		}
	}

	/* Get the x coord for a sprite in a list of sprites, if you are trying to center them all from left to right at 0, 0**/
	public static function getXCoordForCenteringLR(i:Int, total:Int, width:Float, padding:Int = 0)
	{
		var finalWidth = width + padding;
		return Std.int(finalWidth * (i - ((total - 1) / 2)));
	}

	/** Create a hover effect tween on the sprite. Call this after the sprite has been added.**/
	public static function hoverTween(sprite:FlxSprite, duration:Float = 2, distance:Int = 10, ?ease:Float->Float)
	{
		if (ease == null)
			ease = FlxEase.quadOut;
		FlxTween.tween(sprite, {y: sprite.y + distance}, duration, {type: PINGPONG, ease: ease});
	}
}
