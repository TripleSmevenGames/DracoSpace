package models.skills;

import constants.Constants.Colors;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import models.cards.Card;
import ui.battle.CharacterSprite;

enum TargetMethod
{
	SINGLE_ENEMY;
	RANDOM_ENEMY;
	ALL_ENEMY;
	SINGLE_ALLY;
	SINGLE_OTHER_ALLY;
	RANDOM_ALLY;
	ALL_ALLY;
	SELF;
	NONE;
}

enum SkillPointType
{
	POW;
	AGI;
	CON;
	KNO;
	WIS;
	ANY;
}

// a skill's cost is just a skill point combination
// skill can have multiple costs, any valid cost paid will activate the skill.
typedef Costs = Array<SkillPointCombination>;
typedef Effect = Array<CharacterSprite>->Void;

/** Represents a combination of skill points.
 *
 * eg. 1 POW and 3 AGI
 *
 * eg. 2 KNO and 2 ANY
 *
 * Used for skill's costs and card's skill points
 */
class SkillPointCombination
{
	var map:Map<SkillPointType, Int> = new Map<SkillPointType, Int>();

	/** For easy iterating for each skill point type.**/
	public static var ARRAY = [POW, AGI, CON, KNO, WIS, ANY];

	// helper to fill in 0's for keys that don't exist
	public static function newCosts(input:Array<Map<SkillPointType, Int>>)
	{
		var result = new Costs();
		for (cost in input)
		{
			result.push(new SkillPointCombination(cost));
		}
		return result;
	}

	/** Take in an array of SPC's and sum them, returning a new SPC. **/
	public static function sum(combos:Array<SkillPointCombination>)
	{
		var result = new SkillPointCombination([]);
		for (combo in combos)
		{
			for (type in SkillPointCombination.ARRAY)
			{
				result.set(type, result.get(type) + combo.get(type));
			}
		}
		return result;
	}

	/** Add to this SPC IN PLACE. **/
	public function add(other:SkillPointCombination)
	{
		for (type in ARRAY) {
			var sum = this.get(type) + other.get(type);
			this.set(type, sum);
		}
	}

	/** Returns a new SPC, subracting each val in the map. **/
	public function subtract(other:SkillPointCombination) {
		var retVal = new SkillPointCombination();
		for (type in ARRAY) {
			var val = this.get(type) - other.get(type);
			retVal.set(type, val);
		}
		return retVal;
	}

	/** If this SPC would help pay for this cost. Assumes you don't care about overpaying. **/
	public function contributesTo(other:SkillPointCombination) {
		for (type in ARRAY) {
			if (this.get(type) > 0 && other.get(type) > 0) {
				return true;
			}
		}
		return false;
	}

	public function get(key:SkillPointType)
	{
		return map.get(key);
	}

	public function set(key:SkillPointType, val:Int)
	{
		return map.set(key, val);
	}

	public function exists(key:SkillPointType)
	{
		return map.exists(key);
	}

	public function toString()
	{
		var string = '';
		for (type in SkillPointCombination.ARRAY)
		{
			string += '${type.getName()}: ${this.get(type)}, ';
		}

		return string;
	}

	public function new(?inputMap:Map<SkillPointType, Int>)
	{
		if (inputMap == null)
		{
			inputMap = new Map<SkillPointType, Int>();
		}
		for (type in SkillPointCombination.ARRAY)
		{
			var inputMapVal = inputMap.exists(type) ? inputMap.get(type) : 0;
			this.map.set(type, inputMapVal);
		}
	}
}

/* Represents the skill data itself. Its tile during a battle is represented by SkillSprite. */
class Skill
{
	public var name(default, null):String;
	public var desc(default, null):String;
	public var costs(default, null):Costs = new Costs();
	public var targetMethod(default, null):TargetMethod;
	public var effect(default, null):Effect;
	public var cooldown(default, null):Int = 1;
	public var maxCharges(default, null):Int = 1;
	public var chargesPerCD(default, null):Int = 1;
	public var spritePath(default, null):FlxGraphicAsset;

	public static function sampleAttack()
	{
		var name = 'Prying Tool';
		var desc = 'Pry \'em real good. \n\n1POW or 2ANY';
		var costs:Costs = SkillPointCombination.newCosts([[POW => 1], [ANY => 2]]);
		var effect = function(targets:Array<CharacterSprite>)
		{
			for (target in targets)
			{
				target.takeDamage(7);
			}
		}
		var skill = new Skill(name, desc, costs, effect);

		skill.spritePath = AssetPaths.WhiteSword__png;
		skill.targetMethod = SINGLE_ENEMY;

		return skill;
	}

	public static function sampleDefend()
	{
		var name = 'Welder\'s Helmet';
		var desc = 'Eye protection is best protection. \n\n1CON or 2ANY';
		var costs:Costs = SkillPointCombination.newCosts([[CON => 1], [ANY => 2]]);
		var effect = function(targets:Array<CharacterSprite>)
		{
			for (target in targets)
			{
				target.currBlock += 5;
			}
		}
		var skill = new Skill(name, desc, costs, effect);

		skill.spritePath = AssetPaths.TanShield__png;
		skill.targetMethod = SELF;

		return skill;
	}

	public static function sampleEnemyAttack()
	{
		var name = 'Claw';
		var desc = 'This enemy may or may not actually have a claw. \n\n1POW';
		var costs:Costs = SkillPointCombination.newCosts([[POW => 1]]);
		var effect = function(targets:Array<CharacterSprite>)
		{
			for (target in targets)
			{
				target.takeDamage(6);
			}
		}

		var skill = new Skill(name, desc, costs, effect);

		skill.spritePath = AssetPaths.WhiteBox__png;
		skill.targetMethod = RANDOM_ALLY;

		return skill;
	}

	static function paysCost(pay:SkillPointCombination, cost:SkillPointCombination, overpay:Bool = false)
	{
		var leftover:Int = 0;
		for (type in SkillPointCombination.ARRAY)
		{
			if (type == ANY)
				continue;
			else if (type != ANY && pay.get(type) < cost.get(type))
				return false;
			else
				leftover += pay.get(type) - cost.get(type); // convert all leftover into ANY.
		}
		// finally, compare the ANY. Your total ANY is your explicit ANY and leftovers.
		if (overpay)
			return leftover + pay.get(ANY) >= cost.get(ANY);
		else
			return leftover + pay.get(ANY) == cost.get(ANY);
	}

	/** Returns false if the pay combo can't pay any of the card's costs. **/
	public function canPayWith(pay:SkillPointCombination, overpay:Bool = false)
	{
		for (cost in costs)
		{
			if (paysCost(pay, cost, overpay))
			{
				return true;
			}
		}
		return false;
	}

	public function new(name:String, desc:String, costs:Costs, effect:Effect)
	{
		this.name = name;
		this.desc = desc;
		this.costs = costs;
		this.effect = effect;

		spritePath = '';
		targetMethod = SINGLE_ENEMY;
	}
}
