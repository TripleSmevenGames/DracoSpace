package models.player;

import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;

typedef Cards = Array<Card>;

class Deck
{
	public var cardList(get, null):Cards;
	public var hiddenCards:Int = 0;
	public var cardMap:Map<SkillPointType, Int>;

	public function get_cardList()
	{
		return cardList.copy();
	}

	public static function sample()
	{
		return fromMap([POW => 2, AGI => 2, CON => 2, KNO => 2, WIS => 2]);
	}

	public static function ryderKiwiDeck()
	{
		return fromMap([POW => 6, AGI => 8, CON => 6]);
	}

	/** Generate a deck of basic cards with the passed in map. **/
	public static function fromMap(map:Map<SkillPointType, Int>, ?hiddenCards:Int = 0)
	{
		var cards = new Cards();
		for (type in SkillPointCombination.ARRAY)
		{
			if (map.exists(type))
			{
				var num = map.get(type);
				for (i in 0...num)
					cards.push(Card.newBasic(type));
			}
			else
			{
				map.set(type, 0);
			}
		}

		return new Deck(cards, hiddenCards, map);
	}

	public function new(cards:Cards, ?hiddenCards:Int = 0, ?map:Map<SkillPointType, Int>)
	{
		this.cardList = cards;
		this.hiddenCards = hiddenCards;
		this.cardMap = map;
	}
}
