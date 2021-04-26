package models.events;

import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import utils.GameController;
import utils.GameUtils;

class CampEvent extends GameEvent
{
	static function getRestEvent()
	{
		var name = 'Rest';
		var eventDesc = 'Your party takes a quick breather to rest in the cots and grab some rations. You overhear the researchers talking. 
			It seems like the disturbance is definitely not a natural phenomenon. \n\n';
		for (char in Player.chars)
			eventDesc += '${char.name} is now at ${char.currHp} health. \n';

		var choices = [Choice.getGoRoot()];
		return new GameEvent(name, eventDesc, SUB, choices);
	}

	static function getRestChoice()
	{
		var text = 'Rest';
		var restEvent = getRestEvent();
		var effect = (choice:Choice) ->
		{
			GameController.subStateManager.ess.goToSubEvent(restEvent);
			for (char in Player.chars)
				GameUtils.healCharFromRestEvent(char);

			choice.disabled = true;
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Researcher\'s Camp';
		var desc = 'A group a researchers studying the forest have setup camp here. There\'s a few things you can do here.';
		var choices:Array<Choice> = [getRestChoice(), Choice.getLeave()];
		super(name, desc, CAMP, choices);
	}
}
