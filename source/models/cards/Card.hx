package models.cards;

import constants.Constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;
import utils.ViewUtils;

using flixel.util.FlxSpriteUtil;

class Card extends FlxSpriteGroup
{
	public var name(default, null):String;
	// cards give you skill points when played, which are used to activate skills
	public var skillPoints:SkillPointCombination;
	public var effect:Void->Void;

	var body:FlxSprite;
	var anchor:FlxSprite;

	public static function basicPOW()
	{
		return new Card('Power', [POW => 1]);
	}

	public static function basicCON()
	{
		return new Card('Constitution', [CON => 1]);
	}

	public function new(name:String, skillPoints:Map<SkillPointType, Int>)
	{
		super();
		this.name = name;
		this.skillPoints = new SkillPointCombination(skillPoints);
		this.effect = function()
		{
			trace('played a ${name}');
		};

		body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH, CARD_HEIGHT, FlxColor.fromRGB(10, 10, 10));
		ViewUtils.centerSprite(body);
		add(body);

		var outline = new FlxSprite(0, 0).makeGraphic(Std.int(body.width), Std.int(body.height), FlxColor.TRANSPARENT);
		var lineStyle:LineStyle = {thickness: 1, color: FlxColor.WHITE};
		outline.drawRect(0, 0, body.width, body.height, FlxColor.TRANSPARENT, lineStyle);
		ViewUtils.centerSprite(outline);
		// add(outline);

		var titleText = new FlxText(0, 0, CARD_WIDTH, name, 10);
		titleText.setFormat(AssetPaths.DOSWin__ttf, CARD_FONT_SIZE, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(titleText, 0, -50);
		// add(titleText);

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end
	}
}
