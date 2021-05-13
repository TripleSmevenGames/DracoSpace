package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.skills.Skill;
import ui.TooltipLayer.Tooltip;
import ui.battle.BattleIndicatorIcon.TooltipPlace;
import utils.GameController;
import utils.ViewUtils;

using utils.ViewUtils;

/** Combines the skill art and its border. Centered by default.
 * After add()'ing it, you may call setupHover() to setup the hover sprite. But dont do this for SkillSprites!!
**/
class SkillTile extends FlxSpriteGroup
{
	public var skill:Skill;

	public function setupHover(?place:TooltipPlace)
	{
		this.addScaledToMouseManager();
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
			art.setPosition(6, 6); // shift 2 pixels times the 3x scaleing

		add(art);

		border.scale3x();
		if (centered)
			border.centerSprite();
		add(border);
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
			GameController.battleTooltipLayer.registerTooltip(tooltip, this);
		else if (place == INV)
			GameController.invTooltipLayer.registerTooltip(tooltip, this);
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
