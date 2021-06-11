package models.events;

import managers.GameController;
import models.events.Choice;
import models.player.Player;

enum GameEventType
{
	BATTLE;
	ELITE;
	BOSS;
	TREASURE;
	ENCOUNTER;
	SHOP;
	CAMP;
	CLEARING;
	HOME;
	SUB; // a sub event of a one of the above root events.
	TUTORIAL;
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

	/** Get a generic event that just has a "leave" choice. Good for creating subevents that end the event chain and bring player back to the map. **/
	public static function getGenericEvent(name:String, desc:String)
	{
		var choices = [Choice.getLeave()];
		return new GameEvent(name, desc, SUB, choices);
	}

	static public function sampleEncounter()
	{
		var name = 'Sample Encounter';
		var desc = 'You find something glistening on the ground.';

		var effect = (choice:Choice) ->
		{
			var subEvent = GameEvent.getGenericEvent(name, 'You found 20 Dracocoins.');
			GameController.subStateManager.ess.goToSubEvent(subEvent);
			Player.money += 20;

			choice.disabled = true;
		}
		var choice = new Choice('Pick it up', effect);
		var choices = [choice, Choice.getLeave()];
		return new GameEvent(name, desc, TREASURE, choices);
	}

	/** Code to run when when the event starts and is shown to the player. **/
	public function onEventShown() {}

	public function new(name:String, desc:String, type:GameEventType, ?choices:Array<Choice>)
	{
		this.name = name;
		this.desc = desc;
		this.type = type;
		this.choices = choices;
	}
}
