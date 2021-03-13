package models.events;

import haxe.Exception;
import haxe.macro.Expr.Error;
import models.events.GameEvent.GameEventType;
import models.player.CharacterInfo;
import models.player.Deck;
import ui.battle.character.CharacterSprite;

class BattleEvent implements GameEvent
{
	public var name:String;
	public var enemies:Array<CharacterInfo>;
	public var eDeck:Deck;
	public var type:GameEventType;
	public var desc:String;

	public function new(name:String, desc:String, enemies:Array<CharacterInfo>, eDeck:Deck, type:GameEventType)
	{
		this.name = name;
		this.desc = desc;
		this.enemies = enemies;
		this.eDeck = eDeck;
		switch (type)
		{
			case BATTLE, ELITE, BOSS:
				this.type = type;
			default:
				throw new Exception('Bad type for Battle event: ${type.getName()}');
		}
	}
}
