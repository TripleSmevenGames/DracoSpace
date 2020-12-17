package ui.battle;

import constants.Constants.UIMeasurements.*;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import utils.BattleAnimationManager;
import utils.GameController;
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

/**
	A SpriteGroup representing the player's cards in hand.
	Remember that funky stuff can happen during tweens because of
	global vs local positioning. Tweens always want global positioning!!!
 */
@:access(flixel.tweens)
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

	var bam:BattleAnimationManager;

	// to keep the sprites consistent with the current state of the actual cards in hand,
	// we pretty much have to wipe and rerender the sprites every time we change it.
	// so we call wipe visual before modifying the cards
	// and updateVisual after.
	function wipeVisual()
	{
		for (card in cards)
		{
			remove(card);
		}
	}

	// render the cards in hand, placing them nicely depending on how many there are
	// and if they are picked or not
	function renderVisual()
	{
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

	// handles picking or unpicking the card.
	function pick(card:Card)
	{
		wipeVisual();
		// get the absolute position of the card, since card.x/y
		// will give you the local position in this group.
		// But this.x/y gives you this group's global position.
		var absX = this.x + card.x;
		var absY = this.y + card.y;

		// remove the listener at the start of animation
		function onStart(_)
		{
			FlxMouseEventManager.setObjectMouseEnabled(card, false);
		}

		// unpick the card if its picked
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
		// pick the card if its unpicked
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

	/** Get a shallow copy of the cards in your hand */
	public function getCards()
	{
		return cards.copy();
	}

	function addCard(card:Card)
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

	/**Animate a card moving from the draw pile to your hand. Then adds the card and updates the hand.**/
	public function addCardAnimate(card:Card, drawX:Int, drawY:Int)
	{
		// card starts on the draw pile.
		// adding the card sets it locally, but the coord of the draw pile are global.
		// so get the position of the draw pile relative to the hand first.
		card.setPosition(drawX - this.x, drawY - this.y);
		add(card);
		card.visible = false;

		var onStart = (_) -> card.visible = true;
		var onComplete = () -> addCard(card);

		bam.addAnim(FlxTween.tween(card, {x: this.x, y: this.y}, 0.1, {onStart: onStart}), onComplete);
	}

	public function removeCard(card:Card)
	{
		wipeVisual();
		cards.remove(card);
		pickedCards.remove(card);
		renderVisual();
	}

	/** Clear the cards in your hand, but doesn't animate it. */
	public function clearHand()
	{
		wipeVisual();
		cards = [];
		pickedCards = [];
		renderVisual();
	}

	/** Animate and clear the cards in your hand. **/
	public function clearHandAnimate(discardX:Int, discardY:Int)
	{
		for (i in 0...cards.length)
		{
			var card = cards[i];
			var onComplete = () -> removeCard(card);
			if (i == cards.length - 1)
				bam.addAnim(FlxTween.tween(card, {x: discardX, y: discardY}, 0.1), onComplete);
			else
				bam.addAnim(FlxTween.tween(card, {x: discardX, y: discardY}, 0.1), onComplete);
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

		bam = GameController.battleAnimationManager;

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end
	}
}
