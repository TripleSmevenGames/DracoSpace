package ui.battle.win;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.FlxTextWithReplacements;

using utils.ViewUtils;

class SkillRewardCard extends FlxSpriteGroup
{
	public var skill:Skill;
	public var highlight:FlxSprite;

	public function new(skill:Skill, withHighlight:Bool = false)
	{
		super();
		this.skill = skill;

		var padding = 8;

		var body = new FlxSprite();
		body.makeGraphic(200, 280, FlxColor.BLACK);
		body.centerSprite();
		add(body);

		// set up the highlight effect, which appears around the card on hover.
		// we want this for the skill rewards screen, but not the hover effect on SkillSprites during battle.
		if (withHighlight)
		{
			this.highlight = new CardHighlight(body);
			highlight.centerSprite();
			add(highlight);
			highlight.visible = false;

			FlxMouseEventManager.add(body);
			FlxMouseEventManager.setMouseOverCallback(body, (_) -> highlight.visible = true);
			FlxMouseEventManager.setMouseOutCallback(body, (_) -> highlight.visible = false);
		}

		var frame = new FlxUI9SliceSprite(0, 0, AssetPaths.cardFrameGeneric__png, new Rectangle(0, 0, body.width, body.height), [5, 5, 15, 15]);
		frame.centerSprite();
		add(frame);

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

		var descTextSprite = new FlxTextWithReplacements(body.width - 16, UIMeasurements.BATTLE_UI_FONT_SIZE_MED, skill.desc, Std.string(skill.value),
			Std.string(skill.value2));
		// put the skill desc in the middle of the remaining space.
		descTextSprite.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2));
		add(descTextSprite);
	}
}
