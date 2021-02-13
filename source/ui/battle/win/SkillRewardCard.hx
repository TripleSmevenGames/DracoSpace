package ui.battle.win;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import models.skills.Skill;

using utils.ViewUtils;

class SkillRewardCard extends FlxSpriteGroup
{
	var skill:Skill;

	public function new(skill:Skill)
	{
		super();
		this.skill = skill;

		var padding = 8;

		var body = new FlxSprite();
		body.makeGraphic(140, 100, Colors.BACKGROUND_BLUE);
		body.centerSprite();
		add(body);

		// x cursor
		var cursor:Float = 10;

		var title = new FlxText(0, 0, 0, skill.name);
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_MED);
		title.centerSprite(body.width / 2, cursor);
		add(title);
		cursor += title.height + padding;

		var icon = new FlxSprite(0, 0, skill.spritePath);
		icon.scale.set(3, 3);
		icon.updateHitbox();
		icon.centerSprite(body.width / 2, cursor);
		add(icon);
	}
}
