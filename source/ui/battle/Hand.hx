package ui.battle;

import constants.Constants.Colors;
import constants.Constants.UIMeasurements.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import models.player.CharacterInfo.CharacterType;
import utils.BattleAnimationManager;
import utils.BattleManager;
import utils.GameController;
import utils.ViewUtils;

/** Indicator on the side of the "Hand" telling you how many
	of each skill point you will get from the picked cards. */
class SkillPointDisplay extends FlxSpriteGroup
{
	var pointList:Array<FlxText>;
	var bm:BattleManager;

	// used for the blink() function
	var timer:FlxTimer;

	/** Rerender the display based on the information. **/
	function refresh(skillPoints:SkillPointCombination)
	{
		for (i in 0...pointList.length)
		{
			var type = SkillPointCombination.ARRAY[i];
			pointList[i].text = '${type.getName()}: ${skillPoints.get(type)}';
		}
		// tell the global BattleManager the player's new skill points
		bm.playerSkillPoints = skillPoints;
	}

	// handles a single "blink", ie turning the sprite white to red, or red to white.
	function singleBlink()
	{
		var currColor = pointList[0].color;
		var white:FlxColor = 0x00FFFFFF; // same as FlxColor.WHITE but without the alpha
		var color = currColor == white ? FlxColor.RED : white;
		for (text in pointList)
			text.color = color;
	}

	/** Flash the indicator red using an FlxTimer, if its not blinking already. **/
	function blink()
	{
		if (!timer.finished)
			return;

		var time = .20; // time each loop lasts.
		var loops = 6;
		var onComplete = (_) -> singleBlink();

		timer.start(time, onComplete, loops);
	}

	public function new(x:Int = 0, y:Int = 0)
	{
		super(x, y);
		this.pointList = new Array<FlxText>();
		this.timer = new FlxTimer();
		timer.cancel();
		this.bm = GameController.battleManager;

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
 */ @:access(ui.battle.SkillPointDisplay)
class Hand extends FlxSpriteGroup
{
	public var cards(null, null):Cards;

	static inline final PICK_HEIGHT = -80;

	// which kind of hand this is. The player's or the enemy's.
	var type:CharacterType;

	var body:FlxSprite;
	var skillPoints:SkillPointCombination;
	var skillPointDisplay:SkillPointDisplay;

	// for player only
	public var pickedCards:Cards = new Cards();

	var anchor:FlxSprite;
	var wait:Bool = false;

	var bam:BattleAnimationManager;
	var bm:BattleManager;

	var pickSound:FlxSound;
	var playSounds:Array<FlxSound> = [];

	var random:FlxRandom;

	// to keep the sprites consistent with the current state of the actual cards in hand (the array),
	// we pretty much have to wipe and rerender the sprites every time we change it.
	// so we call wipe visual before modifying the cards array, and updateVisual after.
	function wipeVisual()
	{
		for (card in cards)
		{
			remove(card);
		}
	}

	/** Get the would-be LOCAL xCoord of the card when placed in hand. Needed for the card's animation when its drawn. **/
	function getCardXCoordInHand(i, numCards)
	{
		var width = CARD_WIDTH + 10; // padding
		var maxCardsWithoutOverlap = Math.floor(body.width / width);
		var xCoord;
		if (numCards <= maxCardsWithoutOverlap)
			xCoord = Math.round((width * i) - (width * (numCards - 1) / 2));
		else
			xCoord = Math.round((body.width / (numCards + 1)) * (i + 1) - (body.width / 2));

		return xCoord;
	}

	// render the cards in hand, placing them nicely depending on how many there are
	// and if they are picked or not
	function renderVisual()
	{
		var skillPointsAmongCards = new Array<SkillPointCombination>();
		for (i in 0...cards.length)
		{
			var card = cards[i];
			var picked = isPicked(card);

			var xCoord:Int = getCardXCoordInHand(i, cards.length);
			var yCoord = picked ? PICK_HEIGHT : 0;
			card.setPosition(xCoord, yCoord);

			if (picked)
				skillPointsAmongCards.push(card.skillPoints);

			card.resetLook();
			add(card);
		}

		skillPoints = SkillPointCombination.sum(skillPointsAmongCards);
		if (skillPointDisplay != null) // this will be null for enemy Hands.
			skillPointDisplay.refresh(skillPoints);
	}

	function isPicked(card:Card)
	{
		return pickedCards.contains(card);
	}

	/** on click handler for picking or unpicking the card. **/
	function pick(card:Card)
	{
		wipeVisual();

		// https://github.com/HaxeFlixel/flixel/pull/1465 can handle pitch?
		pickSound.play(true);

		// get the absolute position of the card, since card.x/y
		// will give you the local position in this group. (not sure why tbh)
		// But this.x/y gives you this group's global position.
		// We need global coords for tween.
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

		// if this is a player's hand, add the click handler to the card to pick it.
		if (type == PLAYER)
		{
			FlxMouseEventManager.add(card);
			FlxMouseEventManager.setMouseClickCallback(card, (_) ->
			{
				if (bm.getTurn() == PLAYER)
					pick(card);
			});
		}
		cards.push(card);
		renderVisual();
	}

	/** Animate a card moving from the draw pile to your hand. Then adds the card and updates the hand.
		*
		* Enter in global coords of the draw pile, whether the card is hidden (enemy cards only). We also need the
		ordinal number of this card among cards we are drawing in a row, for placing at the end of the animation.
	**/
	public function addCardAnimate(card:Card, drawX:Int, drawY:Int, hidden = false, i:Int)
	{
		add(card); // add the card to the sprite group
		card.visible = false;
		card.hidden = hidden;
		card.setPosition(drawX, drawY);

		var destinationX = getCardXCoordInHand(i, i) + this.x; // this is the ith card drawn among cards we are drawing in a row.
		var destinationY = this.y;

		var onComplete = () ->
		{
			addCard(card);
		};
		var onStart = (_) ->
		{
			card.visible = true;
			card.setPosition(drawX, drawY);
		}

		return bam.addAnim(FlxTween.tween(card, {x: destinationX, y: destinationY}, .1, {onStart: onStart}), onComplete);
	}

	public function removeCard(card:Card)
	{
		wipeVisual();
		cards.remove(card);
		pickedCards.remove(card);
		renderVisual();
	}

	/** The animation moves and shrinks the cards onto those coords.
	 *
	 * Enter in global coords of the skill tile.
	**/
	public function playCardsAnimate(cards:Array<Card>, skillX:Float, skillY:Float)
	{
		var anims = new Array<BattleAnimation>();
		var playSound = playSounds[random.int(0, 1)];
		var onStartAll = () -> playSound.play();
		for (i in 0...cards.length)
		{
			var card = cards[i];
			var onComplete = () ->
			{
				removeCard(card);
				// reset tween modifications
				card.resetLook();
			}
			var anim:BattleAnimation = {
				tween: FlxTween.tween(card, {
					x: skillX,
					y: skillY,
					"scale.x": .5,
					"scale.y": .5,
					alpha: .5
				}, .2),
				onComplete: onComplete,
			}
			anims.push(anim);
		}
		return bam.addAnims(anims, onStartAll);
	}

	/** Flash the indicator red, indicating the skill can't be played because you dont have the right points for it. **/
	public function blinkSkillPointDisplay()
	{
		if (this.skillPointDisplay != null)
			this.skillPointDisplay.blink();
	}

	/** Clear the cards in your hand, but doesn't animate it. */
	public function clearHand()
	{
		wipeVisual();
		cards = [];
		pickedCards = [];
		renderVisual();
	}

	/** Animate and clear (ie discard all) the cards in your hand. 
	 *
	 * Enter in global coords of the discard pile.
	**/
	public function clearHandAnimate(discardX:Int, discardY:Int)
	{
		for (i in 0...cards.length)
		{
			var card = cards[i];
			var onComplete = () -> removeCard(card);
			bam.addAnim(FlxTween.tween(card, {x: discardX, y: discardY}, 0.1), onComplete);
		}
	}

	/** Called by BM to reveal all hidden cards in the enemy's hand. **/
	public function revealAll()
	{
		for (card in cards)
		{
			card.hidden = false;
		}
	}

	/** Reveals 1 card from the enemy's hand**/
	public function revealCard()
	{
		for (card in cards)
		{
			if (card.hidden)
			{
				card.hidden = false;
				return;
			}
		}
	}

	/** Holds the cards in the player's hand and handles animations of cards. It's centered. **/
	public function new(x:Int = 0, y:Int = 0, type:CharacterType)
	{
		super(x, y);
		this.cards = [];
		this.type = type;

		this.body = new FlxSprite(0, 0).makeGraphic(CARD_WIDTH * 5, CARD_HEIGHT + 10, Colors.BACKGROUND_BLUE);
		ViewUtils.centerSprite(body);
		add(body);

		this.skillPointDisplay = null;
		if (type == PLAYER) // if you're the player, give a display showing how many points your picked cards have.
		{
			this.skillPointDisplay = new SkillPointDisplay(Std.int(body.width / 2), Std.int(-body.height / 2));
			add(skillPointDisplay);
		}

		bam = GameController.battleAnimationManager;
		bm = GameController.battleManager;

		this.pickSound = FlxG.sound.load(AssetPaths.pickCard1__wav);
		pickSound.volume = .7;
		this.playSounds = [];
		this.playSounds.push(FlxG.sound.load(AssetPaths.playCard1__wav));
		this.playSounds.push(FlxG.sound.load(AssetPaths.playCard2__wav));

		this.random = GameController.rng;

		#if debug
		this.anchor = new FlxSprite(0, 0).makeGraphic(4, 4, FlxColor.WHITE);
		add(anchor);
		#end
	}
}
