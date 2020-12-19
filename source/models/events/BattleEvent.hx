package models.events;

import haxe.Exception;
import haxe.macro.Expr.Error;
import models.events.GameEvent.GameEventType;
import ui.battle.CharacterSprite;

// todo: probably map this with a character before battle?
enum EnemyClass
{
	SLIME;
}

class BattleEvent implements GameEvent
{
	public var name:String;
	public var enemy:EnemyClass;
	public var type:GameEventType;
	public var desc:String;

	public static function sampleBattle()
	{
		var desc = 'You see a normal enemy in front of you. Sample.';
		return new BattleEvent('Sample Battle', desc, SLIME, BATTLE);
	}

	public static function sampleElite()
	{
		var desc = 'You see a elite enemy in front of you. Sample.';
		return new BattleEvent('Sample Elite', desc, SLIME, ELITE);
	}

	public static function sampleBoss()
	{
		var desc = 'You see a boss enemy in front of you. Sample.';
		return new BattleEvent('Sample Elite', desc, SLIME, BOSS);
	}

	public function new(name:String, desc:String, enemy:EnemyClass, type:GameEventType)
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
