package ui;

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
import ui.inventory.shopMenu.SkillShop.SkillShopChoiceCover;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** Informational card describing a skill. Extended by other components
 * Centered. Added to MouseManager.
**/
class SkillCard extends FlxSpriteGroup
{
	public var skill:Skill;

	/** A sprite to use as a "hover" effect on this component. Could be anything. **/
	public var highlight:FlxSprite;

	public static var bodyWidth = UIMeasurements.SKILL_CARD_WIDTH;
	public static var bodyHeight = UIMeasurements.SKILL_CARD_HEIGHT;

	var body:FlxSprite;

	static final colorMap = [
		Castle.SkillDataKind.ryder => 0xFFc46d16,
		Castle.SkillDataKind.kiwi => 0xFF36294d,
		Castle.SkillDataKind.generic => 0xFF333333,
	];

	public function new(skill:Skill, ?highlight:FlxSprite)
	{
		super();
		this.skill = skill;

		var padding = 4;
		this.addScaledToMouseManager();

		// make the card bg
		this.body = new FlxSprite();
		var color = colorMap.get(skill.category);
		if (color == null)
			color = colorMap.get(Castle.SkillDataKind.generic);
		body.makeGraphic(bodyWidth, bodyHeight, color);
		body.centerSprite();

		add(body);

		// add the white frame
		var frame = new FlxUI9SliceSprite(0, 0, AssetPaths.cardFrameGeneric__png, new Rectangle(0, 0, body.width, body.height), [5, 5, 15, 15]);
		frame.centerSprite();
		add(frame);

		// add the title. centered, so just place it in the middle near the top of the card
		var skillCardTitle = new SkillCardTitle(skill.name, body.width - 16);
		skillCardTitle.setPosition(0, -body.height / 2 + skillCardTitle.height / 2 + 8);
		add(skillCardTitle);

		var parts = new Array<FlxSprite>();

		var icon = new SkillTile(skill, false);
		parts.push(icon);

		var costString = skill.getCostString();
		var costTextOptions = {bodyWidth: body.width, fontSize: 24, font: Fonts.STANDARD_FONT2};
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

		cursor -= 4; // bump the cursor upwards a bit to give the skill description more space.

		// add the skill description background
		var cbWidth = body.width - 20;
		var cbHeight = body.height / 2 - cursor - 24;
		var contentBackground = ViewUtils.newSlice9(AssetPaths.skillCardTitle__png, cbWidth, cbHeight, [15, 15, 32, 32]);
		contentBackground.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2));
		add(contentBackground);

		// add the skill description
		var descTextFontSize:Int;
		if (skill.desc.length < 40)
			descTextFontSize = 20;
		else if (skill.desc.length < 80)
			descTextFontSize = 18;
		else
			descTextFontSize = 16;

		var descTextLineHeight = skill.desc.length < 40 ? 1.1 : 1;
		var descTextOptions = {
			bodyWidth: body.width - 20,
			fontSize: descTextFontSize,
			lineHeightMultiplier: descTextLineHeight
		};
		var descTextSprite = new FlxTextWithReplacements(skill.desc, Std.string(skill.value), Std.string(skill.value2), descTextOptions);
		// put the skill desc in the middle of the remaining space. Then bump it up a bit lol
		descTextSprite.centerSprite(0, cursor + ((body.height / 2 - cursor) / 2) - 8);
		add(descTextSprite);

		var cooldownSprite = new SkillCardCooldown(skill.cooldown);
		// find the approx coords of the bottom right corner to place it on;
		cooldownSprite.centerSprite(body.width / 2 - 8, body.height / 2 - 8);
		add(cooldownSprite);

		// set up the highlight effect, which appears around the card on hover.
		if (highlight != null)
		{
			this.highlight = highlight;
			add(highlight);
			highlight.visible = false;

			FlxMouseEventManager.setMouseOverCallback(this, (_) -> highlight.visible = true);
			FlxMouseEventManager.setMouseOutCallback(this, (_) -> highlight.visible = false);
		}
	}
}

/** The title part of a skill card. Including the text itself and the background. Centered **/
class SkillCardTitle extends FlxSpriteGroup
{
	public function new(titleString:String, width:Float)
	{
		super();
		var title = new FlxText(0, 0, 0, titleString);
		var fontSize = titleString.length > 16 ? UIMeasurements.BATTLE_UI_FONT_SIZE_LG - 2 : UIMeasurements.BATTLE_UI_FONT_SIZE_LG;
		title.setFormat(Fonts.STANDARD_FONT, fontSize);
		var background = ViewUtils.newSlice9(AssetPaths.skillCardTitle__png, width, title.height + 4, [15, 15, 32, 32]);
		background.centerSprite();
		// the title is slightly off center, so just bump it upwards a teeny bit.
		title.centerSprite(0, -2);
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
		var string:String;
		var fontSize:Int;
		if (cooldown >= 99)
		{
			string = '1 USE';
			fontSize = 18;
		}
		else
		{
			string = '${cooldown} ' + "$cd";
			fontSize = 22;
		}

		var options = {fontSize: fontSize, font: Fonts.STANDARD_FONT2};
		var textSprite = new FlxTextWithReplacements(string, null, null, options);
		var background = new FlxUI9SliceSprite(0, 0, AssetPaths.greyBlue_dark__png, new Rectangle(0, 0, textSprite.width + 4, textSprite.height + 4),
			[3, 3, 40, 40]);

		background.centerSprite();
		textSprite.centerSprite();
		add(background);
		add(textSprite);
	}
}
