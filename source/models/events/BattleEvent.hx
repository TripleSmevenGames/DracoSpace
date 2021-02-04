package models.events;

import haxe.Exception;
import haxe.macro.Expr.Error;
import models.events.GameEvent.GameEventType;
import models.player.CharacterInfo;
import ui.battle.character.CharacterSprite;

class BattleEvent implements GameEvent
{
	public var name:String;
	public var enemies:Array<CharacterInfo>;
	public var type:GameEventType;
	public var desc:String;

	public static function sampleBattle()
	{
		var desc = 'You see a normal enemy in front of you. Sample.';
		var enemies = [CharacterInfo.sampleSlime(), CharacterInfo.sampleSlime()];
		return new BattleEvent('Sample Battle', desc, enemies, BATTLE);
	}

	public static function sampleElite()
	{
		var desc = 'You see a elite enemy in front of you. Sample.';
		var enemies = [CharacterInfo.sampleSlime(), CharacterInfo.sampleSlime()];
		return new BattleEvent('Sample Elite', desc, enemies, ELITE);
	}

	public static function sampleBoss()
	{
		var desc = 'You see a boss enemy in front of you. Sample.';
		var enemies = [CharacterInfo.sampleSlime(), CharacterInfo.sampleSlime()];
		return new BattleEvent('Sample Elite', desc, enemies, BOSS);
	}

	public function new(name:String, desc:String, enemies:Array<CharacterInfo>, type:GameEventType)
	{
		this.name = name;
		this.desc = desc;
		this.enemies = enemies;
		switch (type)
		{
			case BATTLE, ELITE, BOSS:
				this.type = type;
			default:
				throw new Exception('Bad type for Battle event: ${type.getName()}');
		}
	}
}
