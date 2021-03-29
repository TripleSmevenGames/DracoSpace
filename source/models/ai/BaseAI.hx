package models.ai;

import flixel.math.FlxRandom;
import models.ai.EnemyIntentMaker.Intent;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import ui.battle.DeckSprite;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
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

	public var currentDecidedIntents:Array<Intent>;

	/** Decide the enemy's intents. Re call this every time we transition to the player idle state, because we may need to
	 * recalculate the enemy's moves.
	**/
	public function decideIntents()
	{
		var intentMaker = new EnemyIntentMaker(context);
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
	}
}
