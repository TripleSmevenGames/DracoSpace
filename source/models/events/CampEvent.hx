package models.events;

import managers.GameController;
import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import utils.GameUtils;

class CampEvent extends GameEvent
{
	/** Get the actual game event which results from pressing the rest choice. **/
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

	static function getTrainEvent()
	{
		var name = 'Train';
		var eventDesc = 'Your party decides to spend time in the barracks training. The instructors there give you some advice. \n\n';
		eventDesc += 'Your skill shop choices have been rerolled.';

		var choices = [Choice.getGoRoot()];
		return new GameEvent(name, eventDesc, SUB, choices);
	}

	static function getRestChoice()
	{
		var text = 'Rest (Heal party members)';
		var restEvent = getRestEvent();
		var effect = (choice:Choice) ->
		{
			for (char in Player.chars)
				GameUtils.healCharFromRestEvent(char);

			GameController.subStateManager.ess.goToSubEvent(restEvent);
			choice.disabled = true; // disable the choice so the player cant choose it again.
		}
		return new Choice(text, effect);
	}

	static function getTrainChoice()
	{
		var text = 'Train (Reroll skill shop choices)';
		var trainEvent = getTrainEvent();
		var effect = (choice:Choice) ->
		{
			Player.rerollSkillShopChoices();

			GameController.subStateManager.ess.goToSubEvent(trainEvent);
			choice.disabled = true; // disable the choice so the player cant choose it again.
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Researcher\'s Camp';
		var desc = 'A group a researchers studying the forest have setup camp here. A small military presence keeps watch.\n\n'
			+ 'There\'s a few things you can do here.';
		var choices:Array<Choice> = [getRestChoice(), getTrainChoice(), Choice.getLeave()];
		super(name, desc, CAMP, choices);
	}
}
