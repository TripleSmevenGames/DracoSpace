package models.events.battleEvents;

import haxe.Exception;
import models.CharacterInfo;
import models.events.GameEvent.GameEventType;
import models.player.Deck;

class BattleEvent extends GameEvent
{
	public var enemies:Array<CharacterInfo>;
	public var eDeck:Deck;

	/** additional enemy spots we would have to render that arent initially filled when the battle starts.
	 * For example, a boss enemy might start with himself, so initially only he is in the battle
	 * But he might summon a max of 4 minions, meaning the additional spots is 4.
	**/
	public var additionalSpots:Int = 0;

	public function new(name:String, desc:String, enemies:Array<CharacterInfo>, eDeck:Deck, type:GameEventType)
	{
		switch (type)
		{
			case TUTORIAL, BATTLE, ELITE, BOSS:
			// no-op
			default:
				throw new Exception('Bad type for Battle event: ${name}, ${type.getName()}');
		}
		this.enemies = enemies;
		this.eDeck = eDeck;
		var choices:Array<Choice> = [Choice.getBattle(this)];
		super(name, desc, type, choices);
	}
}
