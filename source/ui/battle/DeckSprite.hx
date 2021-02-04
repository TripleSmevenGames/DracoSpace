package ui.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.CharacterInfo.CharacterType;
import models.player.Deck;
import ui.battle.character.CharacterSprite;
import ui.buttons.BasicWhiteButton;
import utils.BattleManager;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

/** DeckSprite builds the UI for a draw pile, hand and discard pile during battle.
 * Handles all interactions between hand, draw, and discard.
 *
 * This does NOT handle the rerendering or animating of the sprites. The sprite itself should handle that.
 * You should never interact with Hand or CardPile's internal card array.
 */
@:access(ui.battle.Hand)
class DeckSprite extends FlxSpriteGroup implements ITurnTriggerable
{
	var drawPile:CardPile;
	var discardPile:CardPile;
	var body:FlxSprite;
	var hand:Hand;
	var endTurnBtn:BasicWhiteButton;

	var type:CharacterType;
	var chars:Array<CharacterSprite>;

	// for enemy only
	public var hiddenCards:Int = 0;

	var bm:BattleManager;

	public var deck:Deck;

	public static inline final DECK_HEIGHT:Int = 200;
	public static inline final ENEMY_DECK_WIDTH:Int = 600;

	public function blinkSkillPointDisplay()
	{
		if (hand != null)
			hand.blinkSkillPointDisplay();
	}

	public function shuffle()
	{
		drawPile.set(drawPile.getCards().concat(discardPile.getCards()));
		discardPile.clearPile();
		if (drawPile.length <= 0)
		{
			trace('something went wrong shuffling, no cards to shuffle');
		}
		drawPile.shuffle();
	}

	/** For animation purposes, pass in the ordinal number of this card among cards we are drawing in a row.**/
	function drawCard(hidden:Bool = false, ?only:CharacterSprite, i:Int)
	{
		if (drawPile.getCards().length == 0)
		{
			shuffle();
		}
		var card = drawPile.drawCard();
		if (type != ENEMY)
			hidden = false;

		if (card != null)
		{
			card.onDraw();
			hand.addCardAnimate(card, Std.int(drawPile.x), Std.int(drawPile.y), hidden, i);
		}
		else
			return;
	}

	public function drawCards(num:Int, ?only:CharacterSprite)
	{
		var hiddenCount = hiddenCards;
		for (i in 0...num)
		{
			if (hiddenCount > 0)
			{
				drawCard(true, only, i);
				hiddenCount -= 1;
			}
			else
			{
				drawCard(false, only, i);
			}
		}
	}

	/** Apply "carry over" to all cards in hand, meaning they don't get discarded at EOT. **/
	public function carryOverAll()
	{
		this.hand.carryOverAll();
	}

	public function discardRandomCards(num:Int)
	{
		var discardedCards = hand.discardRandomCardsAnimate(num, Std.int(discardPile.x), Std.int(discardPile.y));
		discardPile.addCards(discardedCards);
	}

	public function discardHand()
	{
		discardPile.addCards(hand.getCards());
		hand.clearHandAnimate(Std.int(discardPile.x), Std.int(discardPile.y));
	}

	/** Plays the specified cards on the chosen skill and discards those cards. **/
	public function playCards(cards:Array<Card>, skillSprite:SkillSprite)
	{
		discardPile.addCards(cards);
		return hand.playCardsAnimate(cards, skillSprite.x, skillSprite.y); // return the anims
	}

	/** Plays the picked cards on the chosen skill and discards those cards. For players.**/
	public function playPickedCards(skillSprite:SkillSprite)
	{
		return playCards(hand.pickedCards, skillSprite);
	}

	/** This function should be triggered by a player skill during their turn.
		Pointless to call during the enemy's turn, as they reveal their hand at the start.
	**/
	public function revealCards(num:Int)
	{
		for (i in 0...num)
			hand.revealCard();
	}

	/** Unhide all the cards. Called on enemy hands when their turn starts.
	 *
	 * There shouldn't be a reason you call this on a player hand.
	**/
	public function revealHand()
	{
		hand.revealAll();
	}

	function endTurnBtnClick()
	{
		if (endTurnBtn.disabled)
			return;

		bm.endTurnFlag = true;
	}

	public function getCardsInHand()
	{
		return this.hand.getCards();
	}

	public function getSkillPoints()
	{
		return this.hand.skillPoints;
	}

	/**Get an array of the characters among the picked cards "only" field.
	 *
	 * If the array is empty, there are no only's and they can be played on any skill.
	 *
	 * If there's 1 in there, they can only be played for that char's skills.
	 *
	 * If there are 2+, it's "illegal" and can't be played for any skill.
	**/
	public function getPickedCardsOnly()
	{
		return this.hand.getPickedCardsOnly();
	}

	public function onPlayerStartTurn(context:BattleContext)
	{
		var cardsToDraw = 0;
		for (char in chars) // this side draws cards equal to the sum of their characters' draw stat.
		{
			if (!char.dead)
				cardsToDraw += char.info.draw;
		}

		drawCards(cardsToDraw);
	}

	public function onPlayerEndTurn(context:BattleContext)
	{
		if (type == PLAYER) // only the player discards their hand at the end of their turn
			discardHand();
	}

	public function onEnemyStartTurn(context:BattleContext)
	{
		if (type == ENEMY)
			revealHand();
	}

	public function onEnemyEndTurn(context:BattleContext)
	{
		if (type == ENEMY) // only the enemy discards their hand at the end of their turn
			discardHand();
	}

	public function new(x:Int = 0, y:Int = 0, deck:Deck, type:CharacterType, chars:Array<CharacterSprite>, hiddenCards:Int = 0)
	{
		super(x, y);

		this.deck = deck;
		this.bm = GameController.battleManager;
		this.type = type;
		this.chars = chars;

		if (type == ENEMY)
		{
			this.hiddenCards = hiddenCards;
		}

		var width = type == PLAYER ? FlxG.width : ENEMY_DECK_WIDTH;

		body = new FlxSprite(0, 0).makeGraphic(width, DECK_HEIGHT, FlxColor.fromRGB(255, 255, 255, 10));
		drawPile = new CardPile(0, 0, FlxColor.GREEN, 'Draw');
		discardPile = new CardPile(0, 0, FlxColor.RED, 'Discard');
		hand = new Hand(0, 0, type);

		// where everything is placed depends on if its an player or enemy decksprite.
		if (type == PLAYER)
		{
			drawPile.setPosition(200, Std.int(body.height / 2));
			discardPile.setPosition(Std.int(body.width - 200), Std.int(body.height / 2));
			hand.setPosition(Std.int(body.width / 2), Std.int(body.height / 2));
		}
		else if (type == ENEMY)
		{
			drawPile.setPosition(0, Std.int(body.height / 2));
			discardPile.setPosition(Std.int(body.width), Std.int(body.height / 2));
			hand.setPosition(Std.int(body.width / 2), Std.int(body.height / 2));
		}
		add(drawPile);
		add(discardPile);
		add(hand);

		if (type == PLAYER)
		{
			endTurnBtn = new BasicWhiteButton('End Turn', endTurnBtnClick);
			endTurnBtn.setPosition(Std.int(body.width - 300), Std.int(body.height / 2) + 50);
			add(endTurnBtn);
		}

		hand.clearHand();
		discardPile.clearPile();
		drawPile.set(deck.cardList);
		shuffle();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (endTurnBtn != null)
			endTurnBtn.disabled = !bm.canEndTurn();
	}
}
