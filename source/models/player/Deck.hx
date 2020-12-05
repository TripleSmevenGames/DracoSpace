package models.player;

import flixel.math.FlxRandom;
import haxe.Exception;
import models.cards.Card;

typedef Cards = Array<Card>;

class Deck
{
	public var cardList(get, null):Array<Card>;

	public function get_cardList()
	{
		return cardList.copy();
	}

	public static function sample()
	{
		var cards = new Cards();
		for (_ in 0...5)
		{
			cards.push(Card.basicPOW());
			cards.push(Card.basicCON());
		}

		return new Deck(cards);
	}

	public function new(cards:Cards)
	{
		this.cardList = cards;
	}
}
