package models.events;

import managers.GameController;
import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import utils.GameUtils;

class CampEvent extends GameEvent
{
	/** Get the actual game event which results from pressing the rest choice. **/
	static function getHealEvent()
	{
		var name = 'Medical Tent';
		var eventDesc = 'Your party gets checked out by the resident medical staff. You overhear the researchers talking. 
			It seems like the disturbance is definitely not a natural phenomenon. \n\n';
		eventDesc += 'Your party has been healed. \n';

		var choices = [Choice.getGoRoot()];
		return new GameEvent(name, eventDesc, SUB, choices);
	}

	static function getRerollEvent()
	{
		var name = 'Rec Center';
		var eventDesc = 'Your party decides to spend time in the rec center. You grab a few drinks and mingle with the members of the camp. \n\n';
		eventDesc += 'Your skill shop choices have been rerolled.';

		var choices = [Choice.getGoRoot()];
		return new GameEvent(name, eventDesc, SUB, choices);
	}

	static function getHealChoice()
	{
		var text = 'Visit the Medical Tent. (Heal party members)';
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

	static function getRerollChoice()
	{
		var text = 'Have a few drinks at the rec center. (Reroll skill shop choices)';
		var trainEvent = getRerollEvent();
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
		var desc = 'HQ has set up a large camp here for researchers and field personel. A small military presence keeps watch.\n\n'
			+ 'There\'s a few things you can do here.';
		var choices:Array<Choice> = [getHealChoice(), getRerollChoice(), Choice.getLeave()];
		super(name, desc, CAMP, choices);
	}
}
