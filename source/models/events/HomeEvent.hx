package models.events;

import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.BattleEventFactory;
import utils.GameController;

class HomeEvent extends GameEvent
{
	static function getTrainingDummyChoice()
	{
		var text = 'Spar with the training dummy';
		var effect = (choice:Choice) ->
		{
			GameController.subStateManager.ess.goToSubEvent(BattleEventFactory.trainingDummy());
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Base';
		var desc = 'You have your mission. Take some time to prepare.';
		var choices:Array<Choice> = [getTrainingDummyChoice(), Choice.getLeave()];
		super(name, desc, HOME, choices);
	}
}
