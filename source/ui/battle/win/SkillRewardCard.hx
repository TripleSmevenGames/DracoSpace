package ui.battle.win;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import models.skills.Skill;
import ui.FlxTextWithReplacements;

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
		body.makeGraphic(200, 280, Colors.BACKGROUND_BLUE);
		body.centerSprite();
		add(body);

		var parts = new Array<FlxSprite>();

		var title = new FlxText(0, 0, 0, skill.name);
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG);
		parts.push(title);

		var icon = new FlxSprite(0, 0, skill.spritePath);
		icon.scale.set(3, 3);
		icon.updateHitbox();
		parts.push(icon);

		var costString = skill.getCostString();
		var costTextSprite = new FlxTextWithReplacements(body.width, UIMeasurements.BATTLE_UI_FONT_SIZE_LG, costString);
		parts.push(costTextSprite);

		// y cursor
		var cursor:Float = -body.height / 2 + 10;
		for (part in parts)
		{
			part.centerX();
			part.y = cursor;
			add(part);
			cursor += part.height + padding;
		}

		var descTextSprite = new FlxTextWithReplacements(body.width, UIMeasurements.BATTLE_UI_FONT_SIZE_MED, skill.desc, Std.string(skill.value),
			Std.string(skill.value2));
		// put the skill desc in the middle of the remaining space.
		descTextSprite.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2));
		add(descTextSprite);
	}
}
