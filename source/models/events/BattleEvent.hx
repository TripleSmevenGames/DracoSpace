package models.events;

import haxe.Exception;
import haxe.macro.Expr.Error;
import models.events.GameEvent.GameEventType;
import ui.battle.Character;

class BattleEvent implements GameEvent
{
	public var name:String;
	public var enemy:Character;
	public var type:GameEventType;
	public var desc:String;

	public static function sampleBattle()
	{
		var desc = 'You see a normal enemy in front of you. Sample.';
		return new BattleEvent('Sample Battle', desc, Character.sampleSlime(), BATTLE);
	}

	public static function sampleElite()
	{
		var desc = 'You see a elite enemy in front of you. Sample.';
		return new BattleEvent('Sample Elite', desc, Character.sampleSlime(2), ELITE);
	}

	public static function sampleBoss()
	{
		var desc = 'You see a boss enemy in front of you. Sample.';
		return new BattleEvent('Sample Elite', desc, Character.sampleSlime(3), BOSS);
	}

	public function new(name:String, desc:String, enemy:Character, type:GameEventType)
	{
		this.name = name;
		this.desc = desc;
		this.enemy = enemy;
		switch (type)
		{
			case BATTLE, ELITE, BOSS:
				this.type = type;
			default:
				throw new Exception('Bad type for Battle event: ${type.getName()}');
		}
	}
}
