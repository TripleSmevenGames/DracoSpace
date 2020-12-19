package models.cards;

import constants.Constants.Colors;
import constants.Constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;
import utils.GameController;
import utils.ViewUtils;

using flixel.util.FlxSpriteUtil;

/** Represents a card sprite during battle. **/
class Card extends FlxSpriteGroup
{
	public var name(default, null):String;
	public var skillPoints:SkillPointCombination;
	public var effect:Void->Void;

	var body:FlxSprite;
	var cover:CardCover;
	var anchor:FlxSprite;

	/** Set this to hide or unhide a card's contents from ther player's view. **/
	public var hidden(default, set):Bool = false;

	public function set_hidden(val:Bool)
	{
		if (val == hidden)
			return hidden;

		if (!val) // unhiding the card
		{
			var tween = FlxTween.tween(this.cover, {alpha: 0}, .5);
			var onComplete = () -> this.cover.visible = false;
			GameController.battleAnimationManager.addAnim(tween, onComplete);
		}
		else // hiding the card
		{
			this.cover.visible = true;
			this.cover.alpha = 1;
		}

		return hidden = val;
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

		var color:FlxColor = ViewUtils.getColorForType(type);

		this.body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH, CARD_HEIGHT, color);
		ViewUtils.centerSprite(body);
		add(body);

		var titleText = new FlxText(0, 0, CARD_WIDTH, name, 10);
		titleText.setFormat(AssetPaths.DOSWin__ttf, CARD_FONT_SIZE, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(titleText, 0, -50);
		add(titleText);

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
