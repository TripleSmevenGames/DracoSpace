package models.events.encounterEvents;

import models.player.Player;

class EncounterEventFactory
{
	static var eventQueue:Array<Void->GameEvent> = [armorScraps];

	// gain max hp
	public static function armorScraps()
	{
		var name = "Armor Scraps";
		var desc = "You detect a piece of Draco-manufactured padding in some grass. "
			+ "It probably got ripped off someone's armor. A member of your party could probably use it "
			+ "to reinforce their own armor.";

		var choices = new Array<Choice>();
		for (char in Player.chars)
		{
			var text = 'Give it to ${char.name}. (+3 max HP)';
			var effect = (_) ->
			{
				char.maxHp += 3;
			};
			var choice = new Choice(text, effect);
			choices.push(choice);
		}

		return new GameEvent(name, desc, ENCOUNTER, choices);
	}

	// trade hp or a skill for an artifact
	public static function danglingArtifact()
	{
		var name = 'Dangling Artifact';
		var desc = 'There\'s something hanging on a nearby ledge. '
			+ 'Your party could spend some time climbing to grab it, or you could sacrifice some equipment instead.';
	}
}
