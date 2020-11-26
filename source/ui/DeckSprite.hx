package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import models.cards.Card;
import models.player.Deck;

// DeckSprite builds the UI for your draw pile, hand and discard pile during battle.
// handles all interactions between hand, draw, and discard.
// any logic that is self-contained within a location should be in the class itself, ie. re-rendering on change.
// You should never interact with Hand or CardPile's internal card array.
class DeckSprite extends FlxSpriteGroup
{
	var drawPile:CardPile;
	var discardPile:CardPile;
	var hand:Hand;
	var body:FlxSprite;

	public var deck:Deck;

	public function restart()
	{
		hand.clearHand();
		discardPile.clearPile();
		drawPile.set(deck.cardList);
		#if debug
		trace('restarted deck with ${deck.cardList.length} cards');
		#end
		shuffle();
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

	function drawCard()
	{
		if (drawPile.getCards().length == 0)
		{
			shuffle();
		}
		var card = drawPile.drawCard();
		if (card != null)
		{
			#if debug
			trace('drew a card');
			#end
			hand.addCard(card);
		}
	}

	public function drawCards(num:Int)
	{
		for (_ in 0...num)
		{
			drawCard();
		}
	}

	public function discardCard(card:Card)
	{
		if (hand.getCards().indexOf(card) == -1)
		{
			trace('tried to discard a card that didnt exist in hand: ${card.name}');
			return;
		}
		hand.removeCard(card);
		discardPile.addCard(card);
	}

	public function discardHand()
	{
		discardPile.addCards(hand.getCards());
		hand.clearHandAnimate(Std.int(discardPile.x), Std.int(discardPile.y));
	}

	public function new(x:Int = 0, y:Int = 0, height:Int, deck:Deck)
	{
		super(x, y);

		this.deck = deck;

		body = new FlxSprite(0, 0).makeGraphic(FlxG.width, height, FlxColor.fromRGB(255, 255, 255, 10));
		add(body);

		drawPile = new CardPile(200, Math.round(body.height / 2), FlxColor.GREEN, 'Draw');
		add(drawPile);
		FlxMouseEventManager.add(drawPile);
		FlxMouseEventManager.setMouseClickCallback(drawPile, function(_) drawCard());

		discardPile = new CardPile(Math.round(body.width - 200), Math.round(body.height / 2), FlxColor.RED, 'Discard');
		add(discardPile);

		var endTurnBtn = new FlxUIButton(discardPile.x, discardPile.y - 100, 'End Turn', discardHand);
		// endTurnBtn.loadGraphicSlice9();

		hand = new Hand(Math.round(body.width / 2), Math.round(body.height / 2));
		add(hand);
	}
}
