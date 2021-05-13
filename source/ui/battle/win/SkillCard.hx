package ui.battle.win;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.FlxTextWithReplacements;
import ui.inventory.SkillShop.SkillShopChoiceCover;

using utils.ViewUtils;

enum HighlightType
{
	NORMAL;
	SHOPCOVER;
}

/** Informational card describing a skill. Centered. Added to MouseManager.**/
class SkillCard extends FlxSpriteGroup
{
	public var skill:Skill;
	public var highlight:FlxSprite;

	public static var bodyWidth = UIMeasurements.SKILL_CARD_WIDTH;
	public static var bodyHeight = UIMeasurements.SKILL_CARD_HEIGHT;

	var body:FlxSprite;

	static final colorMap = [
		Castle.SkillDataKind.ryder => 0xFFc46d16,
		Castle.SkillDataKind.kiwi => 0xFF36294d,
		Castle.SkillDataKind.generic => 0xFF333333,
	];

	public function new(skill:Skill, ?highlightType:HighlightType)
	{
		super();
		this.skill = skill;

		var padding = 8;
		this.addScaledToMouseManager();

		this.body = new FlxSprite();
		var color = colorMap.get(skill.category);
		if (color == null)
			color = colorMap.get(Castle.SkillDataKind.generic);
		body.makeGraphic(bodyWidth, bodyHeight, color);
		body.centerSprite();

		add(body);

		var frame = new FlxUI9SliceSprite(0, 0, AssetPaths.cardFrameGeneric__png, new Rectangle(0, 0, body.width, body.height), [5, 5, 15, 15]);
		frame.centerSprite();
		add(frame);

		// centered, so just place it in the middle
		var skillCardTitle = new SkillCardTitle(skill.name, body.width - 16);
		skillCardTitle.setPosition(0, -body.height / 2 + skillCardTitle.height);
		add(skillCardTitle);

		var parts = new Array<FlxSprite>();

		var icon = new SkillTile(skill, false);
		parts.push(icon);

		var costString = skill.getCostString();
		var costTextOptions = {bodyWidth: body.width, fontSize: UIMeasurements.BATTLE_UI_FONT_SIZE_LG};
		var costTextSprite = new FlxTextWithReplacements(costString, null, null, costTextOptions);
		parts.push(costTextSprite);

		// y cursor starts under the title;
		var cursor:Float = skillCardTitle.y + skillCardTitle.height / 2 + padding;
		for (part in parts)
		{
			part.centerX();
			part.y = cursor;
			add(part);
			cursor += part.height + padding;
		}

		// add the skill description background
		var cbWidth = body.width - 24;
		var cbHeight = body.height / 2 - cursor - 24;
		var contentBackground = new FlxUI9SliceSprite(0, 0, AssetPaths.skillCardTitle__png, new Rectangle(0, 0, cbWidth, cbHeight), [15, 15, 32, 32]);
		contentBackground.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2));
		add(contentBackground);

		// add the skill description
		var descTextFontSize = skill.desc.length < 30 ? 20 : 18;
		var descTextOptions = {bodyWidth: body.width - 8, fontSize: descTextFontSize};
		var descTextSprite = new FlxTextWithReplacements(skill.desc, Std.string(skill.value), Std.string(skill.value2), descTextOptions);
		// put the skill desc in the middle of the remaining space. Then bump it up a bit lol
		descTextSprite.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2) - 16);
		add(descTextSprite);

		var cooldownSprite = new SkillCardCooldown(skill.cooldown);
		// find the approx coords of the bottom right corner to place it on;
		cooldownSprite.centerSprite(body.width / 2 - 8, body.height / 2 - 8);
		add(cooldownSprite);

		// set up the highlight effect, which appears around the card on hover.
		if (highlightType != null)
		{
			if (highlightType == NORMAL)
			{
				this.highlight = new CardHighlight(body);
				highlight.centerSprite();
			}
			else if (highlightType == SHOPCOVER)
			{
				this.highlight = new SkillShopChoiceCover(); // dont need to center, it's already centered.
			}

			if (highlight != null)
			{
				add(highlight);
				highlight.visible = false;

				FlxMouseEventManager.setMouseOverCallback(this, (_) -> highlight.visible = true);
				FlxMouseEventManager.setMouseOutCallback(this, (_) -> highlight.visible = false);
			}
		}
	}
}

/** Centered **/
class SkillCardTitle extends FlxSpriteGroup
{
	public function new(title:String, width:Float)
	{
		super();
		var title = new FlxText(0, 0, 0, title);
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG);
		var background = new FlxUI9SliceSprite(0, 0, AssetPaths.skillCardTitle__png, new Rectangle(0, 0, width, title.height + 4), [15, 15, 32, 32]);
		// the title font is kinda wonky so to match it, we move the background up a teeny bit
		background.centerSprite(0, -2);
		title.centerSprite();
		add(background);
		add(title);
	}
}

/** Centered **/
class SkillCardCooldown extends FlxSpriteGroup
{
	public function new(cooldown:Int)
	{
		super();
		var string = '${cooldown} ' + "$cd";
		var options = {fontSize: 22};
		var textSprite = new FlxTextWithReplacements(string, null, null, options);
		var background = new FlxUI9SliceSprite(0, 0, AssetPaths.greyBlue_dark__png, new Rectangle(0, 0, textSprite.width + 4, textSprite.height + 4),
			[3, 3, 40, 40]);

		background.centerSprite();
		textSprite.centerSprite();
		add(background);
		add(textSprite);
	}
}
