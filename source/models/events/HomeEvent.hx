package models.events;

import managers.GameController;
import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.BattleEventFactory;

class HomeEvent extends GameEvent
{
	static function getTrainingDummyChoice()
	{
		var text = 'Spar with the training dummy. (COMBAT TUTORIAL)';
		var effect = (choice:Choice) ->
		{
			GameController.subStateManager.ess.goToSubEvent(BattleEventFactory.trainingDummy());
			GameController.flags.showTutorial = true;
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Base';
		var desc = 'HQ has sent your party to investigate this forest. 
			Monsters are more hostile than usual. Meet up with the research camp deeper in the forest.';
		var choices:Array<Choice> = [getTrainingDummyChoice(), Choice.getLeave()];
		super(name, desc, HOME, choices);
	}
}
