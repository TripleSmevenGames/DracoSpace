package models.events.encounterEvents;

import flixel.math.FlxRandom;
import managers.GameController;
import models.artifacts.ArtifactFactory;
import models.player.Player;
import substates.EventSubState;
import utils.GameUtils;

using utils.GameUtils;

class EncounterEventFactory
{
	static var eventQueue:Array<Void->GameEvent> = [armorScraps, danglingArtifact, happyCampers1, happyCampers2];
	static var counter:Int;
	static var ess:EventSubState;

	/** Call this at the start of the game, after managers are set up.**/
	public static function init()
	{
		ess = GameController.subStateManager.ess;
		counter = 0;

		var random = new FlxRandom();
		random.shuffle(eventQueue); // shuffle the event queue so that every run is different.
	}

	public static function getNextEvent()
	{
		// if the counter has somehow passed the length of the event queue, just return something random.
		// this shouldn't ever happen though.
		var eventFunction:Void->GameEvent;
		if (counter >= eventQueue.length)
		{
			eventFunction = eventQueue.getRandomChoice();
		}
		else
		{
			eventFunction = eventQueue[counter];
			counter += 1;
		}

		return eventFunction();
	}

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

			var event = GameEvent.getLeaveEvent(name, 'You decided that ${char.name} should get the scraps.');
			var effect = (_) ->
			{
				char.maxHp += 3;
				char.currHp += 3;
				ess.goToSubEvent(event);
			};
			var choice = new Choice(text, effect);
			choices.push(choice);
		}

		return new GameEvent(name, desc, ENCOUNTER, choices);
	}

	// trade hp or a skill for an artifact
	public static function danglingArtifact()
	{
		// this is the artifact they get if they choose to retrieve it.
		var artifact = ArtifactFactory.getNextArtifact();
		var a_or_an = GameUtils.getAOrAn(artifact.name);

		// this the skill the player will lose if they choose "use some equipment"
		var lostSkill = Player.getRandomSkill();

		var name = 'Dangling Artifact';
		var desc = 'There\'s ${a_or_an} ${artifact.name} hanging on a nearby ledge. '
			+ 'Your party could spend some time climbing to grab it, or you could sacrifice some equipment instead.';

		var createUseHpChoice = () ->
		{
			var hpLoss = 3;
			var effect = (_) ->
			{
				for (char in Player.chars)
				{
					char.currHp -= hpLoss;
				}
				Player.gainArtifact(artifact);

				var eventDesc = 'The party spends some energy scaling the cliff. They manage to retrieve it. \n\n You obtained ${a_or_an} ${artifact.name}!';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			}

			return new Choice('Scale the cliff. (All party -3 HP)', effect);
		}

		var createUseSkillChoice = () ->
		{
			var effect = (_) ->
			{
				Player.loseSkill(lostSkill.name);

				var eventDesc = 'The party uses some of their equipment to scale the cliff safely. They manage to retrieve it.'
					+ '\n\n You obtained ${a_or_an} ${artifact.name}!'
					+ ' \n You lost ${lostSkill.name}.';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			}
			return new Choice('Use some equipment. (Lose ${lostSkill.name})', effect);
		};

		var choices = [createUseHpChoice(), createUseSkillChoice()];
		return new GameEvent(name, desc, ENCOUNTER, choices);
	}

	// get a random skill from you current shop choices and shuffle it.
	public static function happyCampers1()
	{
		var skill = Player.getCurrentSkillShopChoices().getRandomChoice();
		var name = 'Happy Campers';
		var desc = 'Your party spots a camp with a few foragers looking for herbs in the forest. No doubt this is a popular place for potion brewers. '
			+ 'One of the foragers, an anteater, approaches your group. \n\n'
			+ '\"Hey fellas. I\'ve got this special brew and I need test subjects.\n'
			+ ' Drinking will unlock some hidden memories of the past, but you might experience short term memory loss. \n\nWhat do you say?\"';

		var acceptChoice = () ->
		{
			var effect = (_) ->
			{
				Player.gainSkill(skill);
				Player.rerollSkillShopChoices();

				var eventDesc = 'The party drinks some of the brew. \n\n You gained ${skill.name}! \nYour skill shop has been rerolled.';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			};
			return new Choice('Have your party accept the brew. (Gain a random skill from your shop, then reroll the shop)', effect);
		};

		var declineChoice = () ->
		{
			var effect = (_) ->
			{
				var eventDesc = '"Oh, haha, well, of course. I will let you be on your way then!"';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			};
			return new Choice('Decline.', effect);
		};

		return new GameEvent(name, desc, ENCOUNTER, [acceptChoice(), declineChoice()]);
	}

	// upgrade a character's skill slots for reduced cost.
	public static function happyCampers2()
	{
		var expCost = 7;
		var name = 'Happy Campers';
		var desc = 'Your party spots a camp with a few foragers looking for herbs in the forest. No doubt this is a popular place for potion brewers.'
			+ 'One of the foragers, an anteater, approaches your group. \n\n'
			+ '\"Hey fellas. I\'ve got this special brew and I need test subjects.'
			+ ' This one\'ll clear your mind and let you remember more things. Might have a small headache at first though.\"';

		var acceptChoice = (char:CharacterInfo) ->
		{
			var effect = (_) ->
			{
				char.numSkillSlots += 1;
				Player.exp -= expCost;

				var eventDesc = '${char.name} drinks some of the brew. \n\nUpgraded skill slots by 1! \nYou lost $expCost XP.';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			};

			var choice = new Choice('Have ${char.name} accept the brew. (-$expCost XP, upgrade)', effect);
			choice.disabled = Player.exp < expCost; // can't choose this choice if your exp is less than expCost.
			return choice;
		};

		var declineChoice = () ->
		{
			var effect = (_) ->
			{
				var eventDesc = '"Oh, haha, well, of course. I will let you be on your way then!"';
				var event = GameEvent.getLeaveEvent(name, eventDesc);
				ess.goToSubEvent(event);
			};
			return new Choice('Decline.', effect);
		};

		return new GameEvent(name, desc, ENCOUNTER, [acceptChoice(Player.chars[0]), acceptChoice(Player.chars[1]), declineChoice()]);
	}
}
