package ui.battle.combatUI;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import managers.BattleManager;
import managers.GameController;
import models.CharacterInfo.CharacterType;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import ui.battle.character.CharacterSprite;
import ui.buttons.BasicWhiteButton;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** DeckSprite builds the UI for a draw pile, hand and discard pile during battle.
 * Handles all interactions between hand, draw, and discard.
 *
 * This does NOT handle the rerendering or animating of the sprites. The sprite itself should handle that.
 * You should never interact with Hand or CardPile's internal card array.
 *
 * Not centered.
 */
@:access(ui.battle.combatUI.Hand)
class DeckSprite extends FlxSpriteGroup implements ITurnTriggerable
{
	var drawPile:CardPile;
	var discardPile:CardPile;
	var hand:Hand;
	var endTurnBtn:BasicWhiteButton;
	var skillLists:Array<CombatSkillList>;

	var type:CharacterType;

	/** The chars associated with this decksprite. IE players for a player decksprite, enemies for an enemy deck sprite.**/
	var chars:Array<CharacterSprite>;

	// for enemy only
	public var hiddenCards:Int = 0;

	/** How much the card amount is modified for the next start of round. **/
	public var drawModifier:Int = 0;

	var bm:BattleManager;

	public var deck:Deck;

	/** Basically taking the deck's card map and turning into a pool of cards for this sprite to manipulate. 
	 * Will be destroyed after every battle (but obviously the Deck object is preserved)
	**/
	public var cardPool:Array<Card>;

	function blinkSkillPointDisplay()
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
		{
			trace('tried to draw a card, but it was null!');
			return;
		}
	}

	/** Queue an animation to draw x cards. **/
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

	public function discardLeftmostCard()
	{
		var discardedCard = hand.discardLeftCardAnimate(Std.int(discardPile.x), Std.int(discardPile.y));
		if (discardedCard != null)
			discardPile.addCard(discardedCard);
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

	/** Get a shallow copy of cards in hand**/
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
		var cardsToDraw = this.deck.draw + this.drawModifier;

		// reset the modifier since we used it this turn
		this.drawModifier = 0;

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
		// only the enemy discards their hand at the end of their turn
		if (type == ENEMY)
			discardHand();
	}

	/** create skill lists BACKWARDS, so they are easy to place bottom to top**/
	function getSkillLists()
	{
		var skillLists = new Array<CombatSkillList>();
		for (i in 0...this.chars.length)
		{
			var char = this.chars[this.chars.length - 1 - i];
			var skillList = new CombatSkillList(char);
			skillLists.push(skillList);
		}
		return skillLists;
	}

	/** check if any chars are dead. If so, put the xCover on them to show they are dead. **/
	public function checkDead()
	{
		for (skillList in this.skillLists)
			skillList.checkDead();
	}

	function getCardPoolFromDeck(deck:Deck):Array<Card>
	{
		var cards = new Cards();
		var map = deck.cardMap;
		for (type in SkillPointCombination.ARRAY)
		{
			if (map.exists(type))
			{
				var num = map.get(type);
				for (i in 0...num)
					cards.push(Card.newBasic(type));
			}
		}
		return cards;
	}

	public function highlightHandTitle()
	{
		hand.titleText.color = FlxColor.YELLOW;
	}

	public function unhighlightHandTitle()
	{
		hand.titleText.color = FlxColor.WHITE;
	}

	public function new(x:Int = 0, y:Int = 0, deck:Deck, type:CharacterType, chars:Array<CharacterSprite>)
	{
		super(x, y);

		this.deck = deck;
		this.cardPool = getCardPoolFromDeck(deck);
		this.bm = GameController.battleManager;
		this.type = type;
		this.chars = chars;

		if (type == ENEMY)
		{
			this.hiddenCards = deck.hiddenCards;
		}

		var cursor = new FlxPoint(0, 0);
		// for the enemy UI, the stuff is rendered the opposite way, so we have to subtract instead of add
		var addToCursor = (x:Float, y:Float) ->
		{
			if (type == ENEMY)
				cursor.add(-x, y);
			else
				cursor.add(x, y);
		};

		// all these are centered
		drawPile = new CardPile(DRAW, deck, hiddenCards > 0);
		discardPile = new CardPile(DISCARD, deck, hiddenCards > 0);
		hand = new Hand(0, 0, type);

		// alright, time to meticulously position everything
		addToCursor(drawPile.width / 2, -drawPile.height / 2);
		drawPile.setPosition(cursor.x, cursor.y);
		addToCursor(0, discardPile.height);
		discardPile.setPosition(cursor.x, cursor.y);

		cursor.x = 0;
		cursor.y = 0;
		addToCursor(drawPile.width + hand.width / 2, 0);
		hand.setPosition(cursor.x, cursor.y);

		addToCursor(hand.width / 2 + 30, hand.height / 2 - 30); // 30 is approx half of avatar after scaling

		// place the combat skill lists bottom to top
		this.skillLists = getSkillLists();
		for (skillList in skillLists)
		{
			skillList.setPosition(cursor.x, cursor.y);
			add(skillList);
			addToCursor(0, -(skillList.height - 16));
		}

		add(drawPile);
		add(discardPile);
		add(hand);

		if (type == PLAYER)
		{
			endTurnBtn = new BasicWhiteButton('End Turn', endTurnBtnClick, 150);
			// set the btn under-center the Hand
			endTurnBtn.setPosition(hand.width / 2, hand.body.height / 2 + 4);
			add(endTurnBtn);
		}

		hand.clearHand();
		discardPile.clearPile();
		drawPile.set(this.cardPool);
		shuffle();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (endTurnBtn != null)
			endTurnBtn.disabled = !bm.canEndTurn();
	}
}
