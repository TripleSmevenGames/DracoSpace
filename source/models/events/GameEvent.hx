package models.events;

import models.events.Choice;
import utils.GameController;

enum GameEventType
{
	BATTLE;
	ELITE;
	BOSS;
	TREASURE;
	CHOICE;
	SHOP;
	CAMP;
	HOME;
	SUB; // a sub event of a one of the above root events.
}

/** Base class for all Events. Pretty much every single node on the map should result in an event.**/
class GameEvent
{
	/** The title of the event, appears at the top**/
	public var name:String;

	/** The text to show under the title**/
	public var desc:String;

	/** The buttons underneath that the player can choose in the event.**/
	public var choices:Array<Choice>;

	public var type:GameEventType;

	/** Get a generic event that just has a "leave" choice. **/
	public static function getGenericEvent(name:String, desc:String)
	{
		var choices = [Choice.getLeave()];
		return new GameEvent(name, desc, SUB, choices);
	}

	public function new(name:String, desc:String, type:GameEventType, ?choices:Array<Choice>)
	{
		this.name = name;
		this.desc = desc;
		this.type = type;
		this.choices = choices;
	}
}
