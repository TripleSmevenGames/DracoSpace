package utils;

import constants.Colors;
import constants.Fonts;
import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.player.Player;
import models.skills.Skill;
import openfl.geom.Rectangle;
import ui.battle.status.Status.StatusType;

using utils.ViewUtils;

typedef Coords =
{
	x:Float,
	y:Float
}

// utils for handling sprites and views.
class ViewUtils
{
	public static function centerNestedSprite(sprite:FlxNestedSprite, x:Float = 0, y:Float = 0)
	{
		sprite.relativeX = x - (sprite.width / 2);
		sprite.relativeY = y - (sprite.height / 2);
	}

	/**
	 * Best used to center sprites inside sprite groups. Don't center a group in a group, if the child group's sprites are centered already.
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

	/** Center all children sprites in group **/
	public static function centerEverythingX(group:FlxSpriteGroup) {}

	/** move this sprite's bottom center to overlap the other sprite's bottom center. 
	 *
	 * Only works if both sprites are added, or if both sprites are un-added. Or if the parent is at 0, 0.
	 * I think it also only works if both are not centered.
	**/
	public static function matchBottomCenter(sprite:FlxSprite, other:FlxSprite)
	{
		var otherMidpointX = other.x + (other.width / 2);
		centerX(sprite, otherMidpointX);

		sprite.y = other.y + (other.height - sprite.height);
	}

	public static function scaleUp(sprite:FlxSprite, val:Int)
	{
		sprite.scale.set(val, val);
		sprite.updateHitbox();
	}

	public static function scale3x(sprite:FlxSprite)
	{
		scaleUp(sprite, 3);
	}

	public static function scale2x(sprite:FlxSprite)
	{
		scaleUp(sprite, 2);
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

	static final statusColorMap = [
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

	static final typeIconMap = [
		POW => AssetPaths.PowerIcon1__png,
		AGI => AssetPaths.agilityIcon1__png,
		CON => AssetPaths.ConIcon1__png,
		KNO => AssetPaths.knowledgeIcon1__png,
		WIS => AssetPaths.wisdomIcon1__png,
		ANY => AssetPaths.anyIcon1__png,
	];

	public static function getIconForType(type:SkillPointType)
	{
		return new FlxSprite(0, 0, typeIconMap.get(type));
	}

	static final typeBorderMap = [
		POW => AssetPaths.powerBorder__png,
		AGI => AssetPaths.agilityBorder__png,
		CON => AssetPaths.conBorder__png,
		KNO => AssetPaths.knowledgeBorder__png,
		WIS => AssetPaths.wisdomBorder__png,
		ANY => AssetPaths.anyBorder__png,
	];

	public static function getBorderForType(type:SkillPointType)
	{
		return new FlxSprite(0, 0, typeBorderMap.get(type));
	}

	public static function getIconForChar(char:Castle.SkillDataKind)
	{
		switch (char)
		{
			case ryder:
				return new FlxSprite(0, 0, AssetPaths.RyderAvatar__png);
			case kiwi:
				return new FlxSprite(0, 0, AssetPaths.KiwiAvatar__png);
			default:
				return new FlxSprite();
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

	public static function hoverTweenSideWays(sprite:FlxSprite, duration:Float = 2, distance:Int = 10, ?ease:Float->Float)
	{
		if (ease == null)
			ease = FlxEase.quadOut;
		FlxTween.tween(sprite, {x: sprite.x + distance}, duration, {type: PINGPONG, ease: ease});
	}

	public static function addScaledToMouseManager(sprite:FlxSprite, mouseChildren = false)
	{
		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		// Make mouse children true if you want other sprites under this to still get mouse events.
		FlxMouseEventManager.add(sprite, null, null, null, null, mouseChildren, true, false);
	}

	/** Helper function to get CENTERED sprites into a grid formation, where we assume 0 is the top left corner of the grid.
	 * Use inside a loop (hence the i param)
	**/
	public static function getCoordsForPlacingInGrid(sprite:FlxSprite, spritesPerRow:Int, i:Int, paddingX:Int = 0, paddingY:Int = 0):Coords
	{
		var widthWithPadding = sprite.width + paddingX;
		var heightWithPadding = sprite.height + paddingY;
		var xPos = ((i % spritesPerRow) * widthWithPadding) + (widthWithPadding / 2);
		var yPos = heightWithPadding / 2 + (widthWithPadding * Math.floor(i / spritesPerRow));
		return {x: xPos, y: yPos};
	}

	public static function newSlice9(assetPath:FlxGraphicAsset, w:Float, h:Float, slice9Array:Array<Int>)
	{
		return new FlxUI9SliceSprite(0, 0, assetPath, new Rectangle(0, 0, w, h), slice9Array);
	}

	/** This gets the lmbIcon or rmbIcon and the text together. Good for hints. Not centered. **/
	public static function getClickToSomethingText(leftClick:Bool, something:String = '', fontSize = 24, padding = 4)
	{
		var group = new FlxSpriteGroup();

		var iconPath = '';
		if (leftClick)
			iconPath = AssetPaths.LMB__png;
		else
			iconPath = AssetPaths.RMB__png;

		var clickIcon = new FlxSprite(0, 0, iconPath);
		clickIcon.scale2x();
		clickIcon.centerY();
		group.add(clickIcon);

		var somethingText = new FlxText(0, 0, 0, something);
		somethingText.setFormat(Fonts.STANDARD_FONT, fontSize);
		somethingText.setPosition(clickIcon.width + padding, 0);
		somethingText.centerY();
		group.add(somethingText);

		return group;
	}

	public static function getPriceColor(price:Int, sale:Bool = false)
	{
		var color = FlxColor.WHITE;
		var canAfford = Player.exp >= price;
		if (!canAfford)
			color = FlxColor.fromString('#ff3d3d'); // a pink
		else if (sale)
			color = FlxColor.YELLOW;

		return color;
	}
}
