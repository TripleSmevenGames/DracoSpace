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

	/** move this sprite's bottom center to overlap the other sprite's bottom center. 
	 *
	 * Only works if both sprites are added, or if both sprites are un-added. Or if the parent is at 0, 0.
	**/
	public static function matchBottomCenter(sprite:FlxSprite, other:FlxSprite)
	{
		var otherMidpointX = other.x + (other.width / 2);
		centerX(sprite, otherMidpointX);

		sprite.y = other.y + (other.height - sprite.height);
	}

	// quick way to make a tiny white dot, good for marking a spot during debug mode.
	public static function newAnchor()
	{
		return new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
	}

	public static final typeColorMap = [
		POW => Colors.POWER_RED,
		AGI => Colors.AGILITY_YELLOW,
		CON => Colors.CONSTITUTION_GREEN,
		KNO => Colors.KNOWLEDGE_BLUE,
		WIS => Colors.WISDOM_PURPLE,
		ANY => FlxColor.GRAY,
	];

	public static function getColorForType(type:SkillPointType)
	{
		return typeColorMap.get(type);
	}

	public static final statusColorMap = [
		BURN => Colors.BURN_ORANGE,
		COLD => Colors.COLD_BLUE,
		STATIC => Colors.STATIC_YELLOW,
		TAUNT => Colors.CONSTITUTION_GREEN,
		COUNTER => Colors.CONSTITUTION_GREEN,
		ATTACK => Colors.POWER_RED,
		DODGE => Colors.AGILITY_YELLOW,
	];

	public static function getColorForStatus(status:StatusType)
	{
		var color = statusColorMap.get(status);
		return color != null ? color : FlxColor.WHITE;
	}

	public static function getIconForType(type:SkillPointType)
	{
		switch (type)
		{
			case POW:
				return new FlxSprite(0, 0, AssetPaths.PowerIcon1__png);
			case AGI:
				return new FlxSprite(0, 0, AssetPaths.agilityIcon1__png);
			case CON:
				return new FlxSprite(0, 0, AssetPaths.ConIcon1__png);
			case KNO:
				return new FlxSprite(0, 0, AssetPaths.knowledgeIcon1__png);
			case WIS:
				return new FlxSprite(0, 0, AssetPaths.wisdomIcon1__png);
			default:
				return new FlxSprite(0, 0, AssetPaths.anyIcon1__png);
		}
	}

	/* Get the x coord for a centered group in a list, if you are trying to center them all from left to right at 0, 0**/
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
