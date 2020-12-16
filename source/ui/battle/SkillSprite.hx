package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.skills.Skill;

// represents a skill "tile" during battle.
class SkillSprite extends FlxSpriteGroup
{
	var skill:Skill;

	var tile:FlxSprite;

	public function new(skill:Skill)
	{
		super(0, 0);
		this.skill = skill;
		tile = new FlxSprite(0, 0, skill.spritePath);
		tile.setGraphicSize(0, Std.int(tile.height * 2));
		tile.updateHitbox();
		add(tile);
	}
}
