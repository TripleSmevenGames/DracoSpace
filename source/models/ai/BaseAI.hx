package models.ai;

import flixel.math.FlxRandom;
import models.ai.EnemyIntentMaker.Intent;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.battleManagerUtils.BattleContext;

/** Base enemy AI "decider." Has handy functions. 
 *
 * To create a custom AI, extend this class and override the functions.
 *
 * Remember this is the AI for the enemy as a whole, not an individual enemy character.
**/
class BaseAI
{
	var context:BattleContext;

	/** The AI will generate a new seed to use for its intents every turn.**/
	var currentSeed:Int;

	var random:FlxRandom;

	public var currentDecidedIntents:Array<Intent>;

	/** call this ONCE per round, like at the start of the player's turn. 
	 * The seed guaruntees that if nothing changed the RNG will produce the same intent every time.
	**/
	public function generateNewSeedForTurn()
	{
		currentSeed = random.int();
	}

	/** Decide the enemy's intents. Re call this every time we transition to the player idle state, because we may need to
	 * recalculate the enemy's moves.
	 * In most cases however, the enemy's intent should NOT change, since conditions are probably the same.
	 * Re-using the same seed should be guarunteeing it does not change unless it needs to.
	**/
	public function decideIntents()
	{
		var intentMaker = new EnemyIntentMaker(context, currentSeed);
		currentDecidedIntents = intentMaker.decideIntents();
		return currentDecidedIntents;
	}

	/** Return the intent at index 0, and remove it from the array**/
	public function getNextIntent():Null<Intent>
	{
		if (currentDecidedIntents.length == 0)
			return null;

		var intent:Intent = currentDecidedIntents.splice(0, 1)[0];
		return intent;
	}

	public function new(skillSprites:Array<SkillSprite>, context:BattleContext)
	{
		this.context = context;
		this.currentDecidedIntents = [];
		this.currentSeed = 0;
		this.random = new FlxRandom();
	}
}
