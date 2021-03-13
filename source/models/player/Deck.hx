package models.player;

import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;

typedef Cards = Array<Card>;

class Deck
{
	public var cardList(get, null):Cards;
	public var hiddenCards:Int = 0;

	public function get_cardList()
	{
		return cardList.copy();
	}

	public static function sample()
	{
		return fromMap([POW => 2, AGI => 2, CON => 2, KNO => 2, WIS => 2]);
	}

	public static function enemySample()
	{
		return fromMap([POW => 4, CON => 4]);
	}

	/** Generate a deck of basic cards with the passed in map. **/
	public static function fromMap(list:Map<SkillPointType, Int>, ?hiddenCards:Int = 0)
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

		return new Deck(cards, hiddenCards);
	}

	public function new(cards:Cards, ?hiddenCards:Int = 0)
	{
		this.cardList = cards;
		this.hiddenCards = hiddenCards;
	}
}
