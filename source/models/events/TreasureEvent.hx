package models.events;

import models.events.GameEvent.GameEventType;
import models.items.Item;
import models.player.Player;
import utils.GameController;

class TreasureEvent extends GameEvent
{
	public var item:Item;

	static public function sample()
	{
		var name = 'Sample treasure event';
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

	public function new(name:String, desc:String, item:Item)
	{
		var choices = [Choice.getLeave()];
		super(name, desc, TREASURE, choices);
		this.item = item;
	}
}
