package models.skills;

import flixel.system.FlxAssets.FlxGraphicAsset;
import models.cards.Card;
import ui.battle.Character;

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
// skill can have multiple costs, each of which will activate the skill when paid
typedef Costs = Array<SkillPointCombination>;
typedef Effect = (Array<Character>) -> Void;

// represents a combination of skill points.
// eg. 1 POW and 3 AGI
// eg. 2 KNO and 2 ANY
// used for skill's costs and card's skill points
class SkillPointCombination
{
	var map:Map<SkillPointType, Int> = new Map<SkillPointType, Int>();

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

class Skill
{
	public var name:String;
	public var desc:String;
	public var costs:Costs = new Costs();
	public var targetMethod:TargetMethod;
	public var effect:Effect;
	public var spritePath:FlxGraphicAsset;

	public static function sampleAttack()
	{
		var name = 'Prying Tool';
		var desc = 'Pry \'em real good.';
		var costs:Costs = SkillPointCombination.newCosts([[POW => 1], [ANY => 2]]);
		var effect = function(targets:Array<Character>)
		{
			for (target in targets)
			{
				target.takeDamage(10);
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
		var desc = 'Eye protection is best protection.';
		var costs:Costs = SkillPointCombination.newCosts([[CON => 1], [ANY => 2]]);
		var effect = function(targets:Array<Character>)
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
		var desc = 'This enemy may or may not actually have a claw.';
		var costs:Costs = SkillPointCombination.newCosts([[POW => 1]]);
		var effect = function(targets:Array<Character>)
		{
			for (target in targets)
			{
				target.takeDamage(6);
			}
		}
		return new Skill(name, desc, costs, effect);
	}

	static function paysCost(pay:SkillPointCombination, cost:SkillPointCombination)
	{
		var leftover:Int = 0;
		for (type in SkillPointCombination.ARRAY)
		{
			if (type != ANY && pay.get(type) < cost.get(type))
				return false;
			else
				leftover += pay.get(type) - cost.get(type);
		}
		// finally, compare the ANY
		var payAny = pay.exists(ANY) ? pay.get(ANY) : 0;
		var costAny = cost.exists(ANY) ? cost.get(ANY) : 0;
		return leftover + payAny >= costAny;
	}

	public function canPayWith(pay:SkillPointCombination)
	{
		for (cost in costs)
		{
			if (paysCost(pay, cost))
			{
				return true;
			}
		}
		trace('cant pay with this');
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
