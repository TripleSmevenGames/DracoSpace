package models.events.battleEvents;

import haxe.Exception;
import models.events.GameEvent.GameEventType;
import models.player.CharacterInfo;
import models.player.Deck;

class BattleEvent extends GameEvent
{
	public var enemies:Array<CharacterInfo>;
	public var eDeck:Deck;

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
