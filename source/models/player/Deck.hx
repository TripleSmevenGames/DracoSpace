package models.player;

import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;

typedef Cards = Array<Card>;

class Deck
{
	public var cardList(get, null):Cards;

	public function get_cardList()
	{
		return cardList.copy();
	}

	public static function sample()
	{
		return newDeckFromList([POW => 2, AGI => 2, CON => 2, KNO => 2, WIS => 2]);
	}

	public static function enemySample()
	{
		return newDeckFromList([POW => 4, CON => 4]);
	}

	/** Generate a deck of basic cards with the passed in map. **/
	public static function newDeckFromList(list:Map<SkillPointType, Int>)
	{
		var cards = new Cards();
		for (type in SkillPointCombination.ARRAY)
		{
			if (list.exists(type))
			{
				var num = list.get(type);
				for (i in 0...num)
					cards.push(Card.newBasic(type));
			}
		}

		return new Deck(cards);
	}

	public function new(cards:Cards)
	{
		this.cardList = cards;
	}
}
