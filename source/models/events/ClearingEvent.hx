package models.events;

import managers.GameController;
import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import utils.GameUtils;

/** This event appears randomly in the map, but is gaurunteed to appear before the map's boss. **/
class ClearingEvent extends GameEvent
{
	/** Get the actual game event which results from pressing the rest choice. **/
	static function getHealEvent()
	{
		var name = 'Rest';
		var eventDesc = 'Your party sets up a tent and a campfire. A well needed rest and some rations is enough to keep them going. \n\n';
		eventDesc += 'Your party was healed.';

		var choices = [Choice.getGoRoot()];
		return new GameEvent(name, eventDesc, SUB, choices);
	}

	static function getHealChoice()
	{
		var text = 'Rest (Heal party members)';
		var restEvent = getHealEvent();
		var effect = (choice:Choice) ->
		{
			for (char in Player.chars)
				GameUtils.healCharFromRestEvent(char);

			GameController.subStateManager.ess.goToSubEvent(restEvent);
			choice.disabled = true; // disable the choice so the player cant choose it again.
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Clearing';
		var desc = 'There\'s a small clearing here where your party take a break.';
		var choices:Array<Choice> = [getHealChoice(), Choice.getLeave()];
		super(name, desc, CLEARING, choices);
	}
}
