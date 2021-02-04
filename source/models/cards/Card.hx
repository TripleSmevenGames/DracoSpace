package models.cards;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;
import ui.battle.character.CharacterSprite;
import utils.GameController;
import utils.ViewUtils;

using flixel.util.FlxSpriteUtil;

/** Represents a card sprite during battle. **/
class Card extends FlxSpriteGroup
{
	public var name(default, null):String;
	public var skillPoints:SkillPointCombination;
	public var effect:Void->Void;
	public var only(default, set):Null<CharacterSprite>;
	public var carryOver(default, set):Bool = false;

	var body:FlxSprite;
	var cover:CardCover;
	var bodyText:FlxText;
	var anchor:FlxSprite;

	/** Set this to hide or unhide a card's contents from ther player's view. **/
	public var hidden(default, set):Bool = false;

	public function set_only(val:Null<CharacterSprite>)
	{
		only = val;
		refreshBodyText();
		return only;
	}

	public function set_carryOver(val:Bool)
	{
		carryOver = val;
		refreshBodyText();
		return carryOver;
	}

	public function set_hidden(val:Bool)
	{
		if (val == hidden)
			return hidden;

		if (!val) // unhiding the card
		{
			var onComplete = (_) -> this.cover.visible = false;
			var tween = FlxTween.tween(this.cover, {alpha: 0}, .5, {onComplete: onComplete});
			GameController.battleAnimationManager.addTweens([tween]);
		}
		else // hiding the card
		{
			this.cover.visible = true;
			this.cover.alpha = 1;
		}

		return hidden = val;
	}

	function refreshBodyText()
	{
		if (only == null)
			bodyText.text = ''
		else
			bodyText.text = '${only.info.name} only';

		if (carryOver)
			bodyText.text += '\nCarry Over';
	}

	/** Reset look after getting modified by tween. */
	public function resetLook()
	{
		this.scale.set(1, 1);
		this.alpha = 1;
		this.color = FlxColor.WHITE;
		// because of weirdness with sprite groups, their children, and alpha values, we do this check here to ensure the "hidden-ness" of the card.
		// TLDR alpha values don't work as you'd expect in terms of parent -> children relationship, so do this check.
		// https://github.com/HaxeFlixel/flixel/pull/2157
		if (hidden)
			this.cover.visible = true;
		else
			this.cover.visible = false;
	}

	/** Reset some things when a card is drawn. **/
	public function onDraw()
	{
		this.only = null;
		this.carryOver = false;
	}

	public static function newBasic(type:SkillPointType)
	{
		switch (type)
		{
			case POW:
				return new Card('Power', [POW => 1], POW);
			case AGI:
				return new Card('Agility', [AGI => 1], AGI);
			case CON:
				return new Card('Constitution', [CON => 1], CON);
			case KNO:
				return new Card('Knowledge', [KNO => 1], KNO);
			case WIS:
				return new Card('Wisdom', [WIS => 1], WIS);
			default:
				return new Card('Unspecified', [ANY => 1], ANY);
		}
	}

	public function new(name:String, skillPoints:Map<SkillPointType, Int>, ?type:SkillPointType)
	{
		super();

		this.name = name;
		this.skillPoints = new SkillPointCombination(skillPoints);
		this.effect = function()
		{
			trace('played a ${name}');
		};

		if (type == null)
			type = ANY;

		this.body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH, CARD_HEIGHT, FlxColor.BLACK);
		ViewUtils.centerSprite(body);
		add(body);

		var color:FlxColor = ViewUtils.getColorForType(type);
		var icon = new FlxSprite(0, 0);
		icon.makeGraphic(50, 50, color);
		ViewUtils.centerSprite(icon, 0, -30);
		add(icon);

		var titleText = new FlxText(0, 0, CARD_WIDTH, name, 10);
		titleText.setFormat(Fonts.STANDARD_FONT, CARD_FONT_SIZE, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(titleText, 0, 5);
		add(titleText);

		bodyText = new FlxText(0, 0, CARD_WIDTH, '', 10);
		bodyText.setFormat(Fonts.STANDARD_FONT, CARD_FONT_SIZE, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(bodyText, 0, 20);
		add(bodyText);

		this.cover = new CardCover();
		ViewUtils.centerSprite(cover);
		add(cover);

		cover.alpha = 0;
		this.hidden = false;

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end
	}
}
