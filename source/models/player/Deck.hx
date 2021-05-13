package models.player;

import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import models.skills.Skill.SkillPointType;

typedef Cards = Array<Card>;

class Deck
{
	public var hiddenCards:Int = 0;
	public var draw:Int = 1;
	public var cardMap:Map<SkillPointType, Int>;

	public static function sample()
	{
		return new Deck([POW => 2, AGI => 2, CON => 2, KNO => 2, WIS => 2]);
	}

	public static function ryderKiwiDeck()
	{
		return new Deck([POW => 6, AGI => 8, CON => 6]);
	}

	public function new(?map:Map<SkillPointType, Int>, ?hiddenCards:Int = 0, ?draw:Int = 1)
	{
		this.hiddenCards = hiddenCards;
		this.draw = draw;
		for (type in SkillPointCombination.ARRAY)
		{
			if (!map.exists(type))
				map.set(type, 0);
		}
		this.cardMap = map;
	}
}
