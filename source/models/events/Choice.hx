package models.events;

import managers.GameController;
import models.events.battleEvents.BattleEvent;

/** A choice in an event for the player to take. **/
class Choice
{
	/** Text to appear on the choice button. **/
	public var text:String;

	/** The code to be run when the choice button is clicked. **/
	public var effect:Choice->Void;

	/** If this choice should be greyed out and disabled. **/
	public var disabled:Bool;

	/** The event to return to**/
	var parentEvent:Null<GameEvent>;

	/** Get a standard "leave the event" choice. Most non-battle events should have this somewhere.**/
	public static function getLeave()
	{
		var text = 'Leave';
		var effect = (choice:Choice) -> GameController.subStateManager.returnToMap();
		return new Choice(text, effect);
	}

	/** Get a standard "start the battle" choice. Switches to the battle sub state.**/
	public static function getBattle(battleEvent:BattleEvent)
	{
		var text = 'Fight';
		var effect = (choice:Choice) -> GameController.subStateManager.initBattle(battleEvent);
		return new Choice(text, effect);
	}

	/** Get a "Back" choice which will go back up to the previous event. **/
	public static function getGoBack()
	{
		var text = 'Back';
		var effect = (choice:Choice) -> GameController.subStateManager.ess.goBack();
		return new Choice(text, effect);
	}

	/** Get a "Back" choice which will go back to the root event. **/
	public static function getGoRoot()
	{
		var text = 'Back';
		var effect = (choice:Choice) -> GameController.subStateManager.ess.goToRoot();
		return new Choice(text, effect);
	}

	/** Get a choice which will take you to a new sub event. **/
	public static function getSubEvent(text:String, event:GameEvent)
	{
		var effect = (choice:Choice) -> GameController.subStateManager.ess.goToSubEvent(event);
		return new Choice(text, effect);
	}

	public function new(text:String, effect:Choice->Void)
	{
		this.text = text;
		this.effect = effect;
	}
}
