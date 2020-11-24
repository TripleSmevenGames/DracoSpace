package models;

import models.Enemy.SlimeEnemy;
import models.Item.EquipmentItem;

enum GameEventType
{
	BATTLE;
	ELITE_BATTLE;
	BOSS;
	TREASURE;
	CHOICE;
	SHOP;
	HOME;
	NONE;
}

interface GameEvent
{
	public var name:String;
	public var type:GameEventType;
}

class BattleEvent implements GameEvent
{
	public var name:String;
	public var enemy:Enemy;

	public var type:GameEventType = BATTLE;

	public static function sample()
	{
		return new BattleEvent('Sample Battle', new SlimeEnemy(1));
	}

	public function new(name:String, enemy:Enemy)
	{
		this.name = name;
		this.enemy = enemy;
	}
}

class BossEvent implements GameEvent
{
	public var name:String;
	public var enemy:Enemy;

	public var type:GameEventType = BOSS;

	public static function sample()
	{
		return new BossEvent('Sample Boss', new SlimeEnemy(1));
	}

	public function new(name:String, enemy:Enemy)
	{
		this.name = name;
		this.enemy = enemy;
	}
}

class TreasureEvent implements GameEvent
{
	public var name:String;
	public var item:Item;

	public var type:GameEventType = TREASURE;

	public static function sample()
	{
		return new TreasureEvent('Sample Treasure', EquipmentItem.sample());
	}

	public function new(name:String, item:Item)
	{
		this.name = name;
		this.item = item;
	}
}

class HomeEvent implements GameEvent
{
	public var name:String;

	public var type:GameEventType = HOME;

	public function new(name:String)
	{
		this.name = name;
	}
}

class NoneEvent implements GameEvent
{
	public var name:String;

	public var type:GameEventType = NONE;

	public function new()
	{
		this.name = 'none event';
	}
}
