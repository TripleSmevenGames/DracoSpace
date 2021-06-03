package models.ai;

import flixel.math.FlxRandom;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

using utils.GameUtils;

/** Represents the skill, the targets, and the cards to be played of 1 enemy move.**/
typedef Intent =
{
	skill:Null<SkillSprite>,
	targets:Array<CharacterSprite>,
	cardsToPlay:Array<Card>,
}

class GhostSkill
{
	/** The actual skillSprite this ghost represents. **/
	public var skillSprite:SkillSprite;

	// these ghost values are what the value would be if they were played. It's like a preview to what
	// the value WOULD look like in the future.
	public var ghostCooldown:Int;
	public var ghostCharges:Int;

	public function new(skillSprite:SkillSprite)
	{
		this.skillSprite = skillSprite;
		ghostCharges = skillSprite.currentCharges;
		if (ghostCharges == 0)
		{
			throw new haxe.Exception('tried to create a ghost skill with no charges: ${skillSprite.skill.name}');
		}
	}
}

/** This class recalculates the intent of the enemy every time it the battle transitions to the idle state.
 * It will use "ghost" objects to decide the enemy's list of moves without actually affecting the battlecontext.
 * The ghost objects represents "what would have been" if the intents are carried out.
**/
class EnemyIntentMaker
{
	var ghostHand:Array<Card>;
	var ghostSkills:Array<GhostSkill>;
	var context:BattleContext;
	var random:FlxRandom;

	/** Whether this skill should be considered as a possible skill this turn, and turned into a ghost for decision making. **/
	function shouldConsiderSkill(skillSprite:SkillSprite):Bool
	{
		if (skillSprite.disabled) // no charges left, or is disabled somehow..
			return false;

		if (!skillSprite.couldPayWithCards(ghostHand)) // or, can't pay even if used whole hand
			return false;

		if (skillSprite.owner.dead) // or, double check that the owner is dead.
			return false;

		return true;
	}

	/** Return skills of the highest priority that are playable with the current ghostHand. 
	 * If we want a custom AI, override this function with custom logic, and have it return a set of ghost skills.
	 * Whatever you return here, decideSkill() will choose a random one to play.
	**/
	function getHighestPriorityPlaybleSkills():Array<GhostSkill>
	{
		var highest = 0;
		var ghostsToReturn = new Array<GhostSkill>();

		for (ghostSkill in ghostSkills)
		{
			var skill = ghostSkill.skillSprite;

			// if we find a skill that is higher priority than what we've seen, make that the new highest priority.
			if (skill.priority > highest)
			{
				highest = skill.priority;
				ghostsToReturn = [ghostSkill];
			}
			else if (skill.priority == highest)
			{
				ghostsToReturn.push(ghostSkill);
			}
		}

		return ghostsToReturn;
	}

	/** Decide on a one of the ghost skills to play randomly. If that skill has only 1 charge left, remove it from the ghostSkills. 
	 * Return null if no skill can be played.
	**/
	function decideSkill():Null<SkillSprite>
	{
		var possibleSkills = getHighestPriorityPlaybleSkills();

		if (possibleSkills.length == 0)
			return null;

		var choice = possibleSkills[random.int(0, possibleSkills.length - 1)];

		choice.ghostCharges -= 1;
		if (choice.ghostCharges == 0)
			ghostSkills.remove(choice);

		return choice.skillSprite;
	}

	/** Similar to hand.pickCardsForSkill, but this accounts for the "ghost hand". **/
	function pickCardsForSkill(skillSprite:SkillSprite):Null<Array<Card>>
	{
		var pickedCards = skillSprite.skill.pickCardsForPay(ghostHand);

		// remove the cards we picked from the ghost hand,
		// so we can accurately decide what additional skills we could play this turn.
		for (card in pickedCards)
			ghostHand.remove(card);

		return pickedCards;
	}

	public function decideTargets(skillSprite:Null<SkillSprite>):Array<CharacterSprite>
	{
		if (skillSprite == null)
			return [];

		var skill = skillSprite.skill;
		var method = skill.targetMethod;
		var targets:Array<CharacterSprite> = [];

		if (method == SELF || method == DECK)
		{
			targets.push(skillSprite.owner);
		}
		else if (method == RANDOM_ENEMY || method == SINGLE_ENEMY)
		{
			var tauntedChars = context.getCharsWithStatus(TAUNT, PLAYER);
			if (tauntedChars.length > 0)
			{
				targets.push(tauntedChars[0]);
			}
			else
			{
				var alivePlayers = context.getAlivePlayers();
				targets.push(alivePlayers.getRandomChoice([], this.random));
			}
		}
		else if (method == SINGLE_ALLY)
		{
			var aliveEnemies = context.getAliveEnemies();
			targets.push(aliveEnemies.getRandomChoice([], this.random));
		}
		else if (method == SINGLE_OTHER_ALLY)
		{
			var aliveEnemies = context.getAliveEnemies();
			aliveEnemies.remove(skillSprite.owner);
			targets.push(aliveEnemies.getRandomChoice([], this.random));
		}
		else if (method == ALL_ENEMY)
		{
			targets = context.getAlivePlayers();
		}
		else if (method == ALL_ALLY)
		{
			targets = context.getAliveEnemies();
		}
		else
		{
			var choice = random.int(0, context.pChars.length - 1);
			targets.push(context.pChars[choice]);
		}

		return targets;
	}

	/** Decide skill and targets based on the current "ghost" context**/
	function decideIntent():Null<Intent>
	{
		var skillSprite = decideSkill();
		if (skillSprite == null)
			return null;

		return {
			skill: skillSprite,
			targets: decideTargets(skillSprite),
			cardsToPlay: pickCardsForSkill(skillSprite),
		};
	}

	public function decideIntents():Array<Intent>
	{
		var decidedIntents = new Array<Intent>();

		var decidedIntent = decideIntent();
		var counter = 0;
		while (decidedIntent != null)
		{
			decidedIntents.push(decidedIntent);
			decidedIntent = decideIntent();
			counter += 1;
			if (counter == 10)
			{
				trace('an AI decided on 10 intents. Probably something wrong.');
				break;
			}
		}

		return decidedIntents;
	}

	public function new(context:BattleContext, seed:Int)
	{
		this.context = context;
		ghostHand = context.eDeck.getCardsInHand();
		ghostSkills = [];
		for (eChar in context.eChars)
		{
			for (skillSprite in eChar.skillSprites)
			{
				if (shouldConsiderSkill(skillSprite))
					ghostSkills.push(new GhostSkill(skillSprite));
			}
		}
		this.random = new FlxRandom(seed);
	}
}
