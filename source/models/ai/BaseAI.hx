package models.ai;

import flixel.math.FlxRandom;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import ui.battle.DeckSprite;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

typedef Intent =
{
	skill:Null<SkillSprite>,
	targets:Array<CharacterSprite>,
}

/** Base enemy AI "decider." Has handy functions. 
 *
 * To create a custom AI, extend this class and override the functions.
 *
 * Remember this is the AI for the enemy as a whole, not an individual enemy character.
**/
class BaseAI
{
	// skills among all enemy characters
	var skillSprites:Array<SkillSprite>;

	var context:BattleContext;
	var random:FlxRandom;

	public var intent(default, null):Intent;

	function getSkillPointTotal():SkillPointCombination
	{
		var cardSkillPoints = new Array<SkillPointCombination>();
		var cards = context.eDeck.getCardsInHand();
		for (card in cards)
			cardSkillPoints.push(card.skillPoints);
		return SkillPointCombination.sum(cardSkillPoints);
	}

	function canPlaySkill(skillSprite:SkillSprite)
	{
		if (skillSprite.disabled) // no charges left, or owner is dead
			return false;

		var skillPointTotal = getSkillPointTotal();
		if (!skillSprite.skill.canPayWith(skillPointTotal, true)) // or, can't pay even if used whole hand
			return false;

		return true;
	}

	/** Get a list of all the skills this enemy could play right now. **/
	function getPlayableSkills()
	{
		var playableSkills = new Array<SkillSprite>();
		for (skillSprite in skillSprites)
		{
			if (canPlaySkill(skillSprite))
				playableSkills.push(skillSprite);
		}

		return playableSkills;
	}

	/** from this array of skills, get a subarray of skills with the highest priority that exists in the array. 
	 * This has the potential to be slow? Because it does one loop to getPlaybleSkills and another to get the highest prio.
	 * But total number of skills that the enemy would have is pretty low too.	
	 */
	function getHighestPrioritySkills()
	{
		var playableSkills = getPlayableSkills();
		var highest = 0;
		var skillsToReturn = new Array<SkillSprite>();

		for (skill in playableSkills)
		{
			if (skill.priority > highest)
			{
				highest = skill.priority;
				skillsToReturn = [skill];
			}
			else if (skill.priority == highest)
			{
				skillsToReturn.push(skill);
			}
		}

		return skillsToReturn;
	}

	/** Decide skill based on priority. Override this function for a custom decider. Return null if no skills can be played.**/
	public function decideSkill():Null<SkillSprite>
	{
		var highestPrioritySkills = getHighestPrioritySkills();

		if (highestPrioritySkills.length == 0)
			return null;

		var choice = random.int(0, highestPrioritySkills.length - 1);
		return highestPrioritySkills[choice];
	}

	public function pickCardsForSkill(skillSprite:SkillSprite)
	{
		var cards = context.eDeck.getCardsInHand();
		var pickedCards = new Array<Card>();
		var skillPoints = new SkillPointCombination();

		// For now, we're going to assume enemy skills just have 1 cost.
		var cost = skillSprite.skill.costs[0];

		for (card in cards)
		{
			if (skillSprite.skill.canPayWith(skillPoints))
			{
				break;
			}
			else
			{
				var need = cost.subtract(skillPoints);
				if (card.skillPoints.contributesTo(need))
				{
					pickedCards.push(card);
					skillPoints.add(card.skillPoints);
				}
			}
		}
		return pickedCards;
	}

	/** Override this for a smarter target-er**/
	public function decideTargetsForSkill(skillSprite:Null<SkillSprite>):Array<CharacterSprite>
	{
		if (skillSprite == null)
		{
			return [];
		}
		var skill = skillSprite.skill;
		var method = skill.targetMethod;
		var targets:Array<CharacterSprite> = [];

		if (method == SELF)
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
				var choice = random.int(0, context.pChars.length - 1);
				targets.push(context.pChars[choice]);
			}
		}
		else if (method == ALL_ENEMY)
		{
			targets = context.pChars;
		}
		else
		{
			var choice = random.int(0, context.pChars.length - 1);
			targets.push(context.pChars[choice]);
		}

		return targets;
	}

	/** Properly set the public variable "intent" on this AI.**/
	public function decideMove(?skill:SkillSprite, ?targets:Array<CharacterSprite>)
	{
		var decidedSkill = skill != null ? skill : decideSkill();
		var decidedTargets = targets != null ? targets : decideTargetsForSkill(decidedSkill);
		this.intent = {
			skill: decidedSkill,
			targets: decidedTargets,
		};

		return this.intent;
	}

	/** Check if we need to redecide our move, and do so if we need to.
	 * e.g. our chosen skill got disabled, or a character gained taunt.
	 * Preserve the skill if just the targets need to change.
	**/
	public function redecideMove()
	{
		if (this.intent == null)
			return decideMove();

		// if the chosen skill is not playable, decide a new move.
		if (!canPlaySkill(this.intent.skill))
			return decideMove();

		// check that the target is valid and there isn't a taunted character that should be targeted instead
		var targetMethod = this.intent.skill.skill.targetMethod;
		if (targetMethod == SINGLE_ENEMY || targetMethod == RANDOM_ENEMY)
		{
			var tauntedChars = context.getCharsWithStatus(TAUNT, PLAYER);
			if (tauntedChars.length != 0)
				this.intent.targets = [tauntedChars[0]];
		}
		return this.intent;
	}

	public function new(skillSprites:Array<SkillSprite>, context:BattleContext)
	{
		this.skillSprites = skillSprites;
		this.context = context;
		this.random = new FlxRandom();
	}
}
