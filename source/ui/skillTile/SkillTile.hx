package ui.skillTile;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.skills.Skill;
import ui.TooltipLayer.Tooltip;
import ui.battle.IndicatorIcon.TooltipPlace;
import utils.ViewUtils;

using utils.ViewUtils;

/** Combines the skill art and its border. Centered by default.
 * After add()'ing it, you may call setupHover() to setup the skillCard hover.
**/
class SkillTile extends FlxSpriteGroup
{
	public var skill:Skill;

	// because of a bug with get_width and spriteGroups, we'll just "hardcode" it to be correct.
	// https://github.com/HaxeFlixel/flixel/issues/2305
	var realWidth:Float;
	var realHeight:Float;

	/** Art width and height (the icon inside the border)**/
	public var artWAndH = 16 * 3;

	override public function get_width()
	{
		return realWidth;
	}

	override public function get_height()
	{
		return realHeight;
	}

	public function setupHover(?place:TooltipPlace)
	{
		// set mouseChildren to true so that we can trigger other mouse effects on sprites
		// that may be overlapping with this one.
		this.addScaledToMouseManager(true);
		if (place == BATTLE || place == null)
			GameController.battleTooltipLayer.createTooltipForSkillTile(this);
		else if (place == INV)
			GameController.invTooltipLayer.createTooltipForSkillTile(this);
	}

	public function new(skill:Null<Skill>, centered:Bool = true)
	{
		super();
		this.skill = skill;

		var spritePath = skill != null ? skill.spritePath : AssetPaths.unknownSkill__png;
		var type = skill != null ? skill.type : ANY;

		var art = new FlxSprite(0, 0, spritePath);
		var border = ViewUtils.getBorderForType(type);

		art.scale3x();
		if (centered)
			art.centerSprite();
		else
			art.setPosition(3, 3); // shift 1 pixels times the 3x scaling
		add(art);

		border.scale3x();
		if (centered)
			border.centerSprite();
		add(border);

		realWidth = border.width;
		realHeight = border.height;
	}
}

class SkillTileBlank extends FlxSpriteGroup
{
	public function new(centered:Bool = true)
	{
		super();

		var sprite = new FlxSprite(0, 0, AssetPaths.blankSkill__png);
		sprite.scale3x();

		if (centered)
			sprite.centerSprite();

		add(sprite);
	}
}

class SkillTileLocked extends FlxSpriteGroup
{
	public function setupHover(?place:TooltipPlace)
	{
		this.addScaledToMouseManager();
		var tooltip = Tooltip.genericTooltip('Locked', null, {width: 0});
		if (place == BATTLE || place == null)
			GameController.battleTooltipLayer.registerTooltip(tooltip, this, true);
		else if (place == INV)
			GameController.invTooltipLayer.registerTooltip(tooltip, this, true);
	}

	public function new(centered:Bool = true)
	{
		super();

		var sprite = new FlxSprite(0, 0, AssetPaths.lockedSkill__png);
		sprite.scale3x();

		if (centered)
			sprite.centerSprite();

		add(sprite);
	}
}
