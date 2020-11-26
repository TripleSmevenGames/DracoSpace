package models.events;

enum GameEventType
{
	BATTLE;
	ELITE;
	BOSS;
	TREASURE;
	CHOICE;
	SHOP;
	REST;
	HOME;
	NONE;
}

interface GameEvent
{
	public var name:String;
	public var type:GameEventType;
	public var desc:String;
}
