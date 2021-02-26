package ui.inventory;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill;

/** A skill tile sprite in the inventory menu.**/
class SkillTile extends FlxSprite
{
	public var skill:Skill;

	public function new(x:Int, y:Int, skill:Skill)
	{
		var asset = skill.spritePath;
		this.skill = skill;
		super(x, y, asset);
	}
}
