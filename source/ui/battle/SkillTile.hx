package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.skills.Skill;
import utils.ViewUtils;

using utils.ViewUtils;

/** Combines the skill art and its border. Centered by default **/
class SkillTile extends FlxSpriteGroup
{
	public var skill:Skill;

	public function new(skill:Null<Skill>, centered:Bool = true)
	{
		super();
		this.skill = skill;

		if (skill != null)
		{
			var art = new FlxSprite(0, 0, skill.spritePath);
			var border = ViewUtils.getBorderForType(skill.type);

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
		else
		{
			var tile = new FlxSprite(0, 0, AssetPaths.unknownSkill__png);
			tile.scale3x();
			tile.centerSprite();
			add(tile);
		}

		// setup tooltip on hover
		// GameController.battleTooltipLayer.createTooltipForSkillTile(this);
	}
}
