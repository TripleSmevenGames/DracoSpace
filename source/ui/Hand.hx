package ui;

import constants.Constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import utils.ViewUtils;

class SkillPointsIndicator extends FlxSpriteGroup
{
	var pointList:Array<FlxText>;

	public function refresh(skillPoints:SkillPointCombination)
	{
		for (i in 0...pointList.length)
		{
			var type = SkillPointCombination.ARRAY[i];
			pointList[i].text = '${type.getName()}: ${skillPoints.get(type)}';
		}
	}

	public function new(x:Int = 0, y:Int = 0)
	{
		super(x, y);
		this.pointList = new Array<FlxText>();
		var height = 20;
		for (i in 0...SkillPointCombination.ARRAY.length)
		{
			var type = SkillPointCombination.ARRAY[i];
			var text = '${type.getName()}: 0';
			var flxText = new FlxText(0, i * height, 0, text);
			flxText.setFormat(AssetPaths.DOSWin__ttf, BATTLE_UI_FONT_SIZE_SM);
			pointList.push(flxText);
			add(flxText);
		}
	}
}

class Hand extends FlxSpriteGroup
{
	public var cards(null, null):Cards;

	static inline final PICK_HEIGHT = -80;

	var body:FlxSprite;
	var skillPoints:SkillPointCombination;
	var skillPointsIndicator:SkillPointsIndicator;
	var pickedCards:Cards = new Cards();
	var anchor:FlxSprite;
	var wait:Bool = false;

	function wipeVisual()
	{
		#if debug
		trace('ran wipeVisual with ${cards.length} cards');
		#end
		for (card in cards)
		{
			remove(card);
		}
	}

	// render the cards in hand, placing them nicely depending on how many there are
	// and if they are picked or not
	function renderVisual()
	{
		#if debug
		trace('ran updateVisual with ${cards.length} cards');
		#end
		var width = CARD_WIDTH + 10; // padding
		var maxCardsWithoutOverlap = Math.floor(body.width / width);
		var skillPointsAmongCards = new Array<SkillPointCombination>();
		for (i in 0...cards.length)
		{
			var card = cards[i];
			var xCoord:Int;
			var picked = isPicked(card);

			if (cards.length <= maxCardsWithoutOverlap)
				xCoord = Math.round((width * i) - (width * (cards.length - 1) / 2));
			else
				xCoord = Math.round((body.width / (cards.length + 1)) * (i + 1) - (body.width / 2));

			var yCoord = picked ? PICK_HEIGHT : 0;
			card.setPosition(xCoord, yCoord);
			if (picked)
				skillPointsAmongCards.push(card.skillPoints);
			add(card);
		}

		skillPoints = SkillPointCombination.sum(skillPointsAmongCards);
		skillPointsIndicator.refresh(skillPoints);
	}

	function isPicked(card:Card)
	{
		return pickedCards.contains(card);
	}

	function pick(card:Card)
	{
		wipeVisual();
		var absX = this.getPosition().x + card.x;
		var absY = this.getPosition().y + card.y;

		// remove the listener at the start of animation
		function onStart(_)
		{
			FlxMouseEventManager.setObjectMouseEnabled(card, false);
		}

		if (isPicked(card))
		{
			function onUnPickFinish(_)
			{
				pickedCards.remove(card);
				renderVisual();
				// add the listener back at the end
				FlxMouseEventManager.setObjectMouseEnabled(card, true);
			}

			FlxTween.tween(card, {x: absX, y: absY - PICK_HEIGHT}, .1, {
				onStart: onStart,
				onComplete: onUnPickFinish,
				ease: FlxEase.cubeOut
			});
		}
		else
		{
			function onPickFinish(_)
			{
				pickedCards.push(card);
				renderVisual();
				// add the listener back at the end
				FlxMouseEventManager.setObjectMouseEnabled(card, true);
			}

			FlxTween.tween(card, {x: absX, y: absY + PICK_HEIGHT}, .1, {
				onStart: onStart,
				onComplete: onPickFinish,
				ease: FlxEase.cubeOut
			});
		}
		renderVisual();
	}

	public function getCards()
	{
		return cards.copy();
	}

	public function addCard(card:Card)
	{
		wipeVisual();
		FlxMouseEventManager.add(card);
		FlxMouseEventManager.setMouseClickCallback(card, function(_)
		{
			pick(card);
		});
		cards.push(card);
		renderVisual();
	}

	public function removeCard(card:Card)
	{
		wipeVisual();
		cards.remove(card);
		pickedCards.remove(card);
		renderVisual();
	}

	public function clearHand()
	{
		wipeVisual();
		cards = [];
		pickedCards = [];
		renderVisual();
	}

	public function clearHandAnimate(tweenX:Int, tweenY:Int)
	{
		for (i in 0...cards.length)
		{
			var card = cards[i];
			if (i == cards.length - 1)
				FlxTween.tween(card, {x: tweenX, y: tweenY}, 0.1, {
					onComplete: function(_)
					{
						clearHand();
					}
				});
			else
				FlxTween.tween(card, {x: tweenX, y: tweenY}, 0.1);
		}
	}

	public function new(x:Int = 0, y:Int = 0)
	{
		super(x, y);
		this.cards = [];

		this.body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH * 5, CARD_HEIGHT + 10, FlxColor.BLUE);
		ViewUtils.centerSprite(body);
		add(body);

		this.skillPointsIndicator = new SkillPointsIndicator(Std.int(body.width / 2), Std.int(-body.height / 2));
		add(skillPointsIndicator);

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end
	}
}
