package models.skills;

import Castle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import managers.BattleManager;
import models.cards.Card;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.battleManagerUtils.BattleContext;

using utils.GameUtils;

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
typedef Play = (Array<CharacterSprite>, CharacterSprite, BattleContext) -> Void;
typedef Effect = (CharacterSprite, CharacterSprite, BattleContext) -> Void; // target, owner, battle context

/** Represents a combination of skill points.
 *
 * eg. 1 POW and 3 AGI
 * eg. 2 KNO and 2 ANY
 *
 * Used for skill's costs and card's skill points
 * Basically a map of skillpoint type to int, with the 0's, and cool functions.
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
		for (type in ARRAY)
		{
			var sum = this.get(type) + other.get(type);
			this.set(type, sum);
		}
	}

	/** Returns a new SPC, subracting each val in the map. **/
	public function subtract(other:SkillPointCombination)
	{
		var retVal = new SkillPointCombination();
		for (type in ARRAY)
		{
			var val = this.get(type) - other.get(type);
			retVal.set(type, val);
		}
		return retVal;
	}

	/** If this SPC would help pay for this cost. Assumes you don't care about overpaying/wasting points. **/
	public function contributesTo(other:SkillPointCombination)
	{
		// if this SPC has no value, obviously the answer is false.
		if (isZero())
			return false;

		// any non zero combination contributes to an ANY cost.
		if (other.get(ANY) > 0)
			return true;

		for (type in ARRAY)
		{
			if (this.get(type) > 0 && other.get(type) > 0)
			{
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

	public function isZero()
	{
		for (type in ARRAY)
		{
			if (this.get(type) > 0)
				return false;
		}
		return true;
	}

	public function toString()
	{
		var stringArray = new Array<String>();
		for (type in SkillPointCombination.ARRAY)
		{
			var name = type.getName();
			var val = this.get(type);
			if (val != 0)
			{
				if (val < 3)
				{
					for (i in 0...val)
						stringArray.push(name);
				}
				else
				{
					stringArray.push(Std.string(val));
					stringArray.push(name);
				}
			}
		}

		return stringArray.join(' ');
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
	// most of these fields are taken from the skill's entry in the skillData database.
	public var id(default, null):Int;
	public var name(default, null):String;
	public var desc(default, null):String;
	public var value(default, null):Int;
	public var value2(default, null):Int;
	public var flavor(default, null):String;
	public var rarity(default, null):SkillData_skills_rarity;
	public var costs(default, null):Costs = new Costs(); // need to translate from DB in code
	public var type(default, null):SkillPointType; // need to translate from cost
	public var targetMethod(default, null):SkillData_skills_targetMethod;
	public var play(default, null):Play; // not in DB. Define in a SkillFactory.
	public var cooldown(default, null):Int = 1;
	public var maxCharges(default, null):Int = 1;
	public var chargesPerCD(default, null):Int = 1;

	/** Borderless skill art. Border is added later according to its type.**/
	public var spritePath(default, null):FlxGraphicAsset; // not in DB

	public var category(default, null):SkillDataKind; // not in DB, need to translate in code
	public var priority(default, null):Int = 0; // not in DB, set in code. Used for enemy skills only.

	/** Returns if the pay can pay for the cost. If overpay is true, the functions returns true even if you are over paying.**/
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

	/** Returns if the pay can pay for any of this skill's costs.
	 * Remember a skill could have multiple costs. You only
	 * need to pay for one of them to activate the skill.
	**/
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

	/** Returns true if any subset these cards COULD pay for the skill. **/
	public function couldPayWithCards(cards:Array<Card>)
	{
		var skillPointTotal = cards.getSkillPointTotal();
		return canPayWith(skillPointTotal, true);
	}

	/** From the passed in cards, pick cards which can pay for this skill. 
	 * Tries to pay for the first cost. If not, tries to pay for the second, and so on.
	 * Returns null if we can't play the skill with these cards.
	**/
	public function pickCardsForPay(cards:Array<Card>):Null<Array<Card>>
	{
		// if we couldnt pay for this skill even if we used all the cards,
		// then there's no combination of cards which can pay for the skill. Return null.
		if (!couldPayWithCards(cards))
		{
			// trace('cant pay for ${name} with ${cards.cardsToString()}');
			return null;
		}

		// the cards we will return which can play this skill.
		var pickedCards = new Array<Card>();
		// the current skillpoints among the cards we have picked.
		var skillPoints = new SkillPointCombination();

		var donePicking = false;

		for (cost in costs)
		{
			if (donePicking)
				break;

			pickedCards = [];
			skillPoints = new SkillPointCombination();

			for (card in cards)
			{
				// calculate what points we need left to pay for this skill.
				// if this card contributes to this need, pick it.
				var need = cost.subtract(skillPoints);
				if (card.skillPoints.contributesTo(need))
				{
					pickedCards.push(card);
					skillPoints.add(card.skillPoints);

					// if we've just picked enough cards to pay for this skill,
					// just break out of the loop. We're good now.
					if (canPayWith(skillPoints))
					{
						donePicking = true;
						break;
					}
				}
			}
		}

		return pickedCards;
	}

	public function getCostString()
	{
		return costs.join(' OR ');
	}

	public function getCostStringCompact()
	{
		return costs.join(' / ');
	}

	/** Used for the skillsprite tool tip. **/
	public function getInfoString()
	{
		var string = '';
		string += 'Cost: ${this.getCostString()}\n';
		string += 'Cooldown: ${cooldown} turn(s)';
		return string;
	}

	function parseCostsFromSkillData(dataCosts:cdb.Types.ArrayRead<Castle.SkillData_skills_costs>)
	{
		var costs:Array<Map<SkillPointType, Int>> = [];
		for (dataCost in dataCosts)
		{
			var cost = new Map<SkillPointType, Int>(); // dirty, I know. But I dont see a way to iterate over the columns in the DB.
			if (dataCost.POW != null)
				cost.set(POW, dataCost.POW);

			if (dataCost.AGI != null)
				cost.set(AGI, dataCost.AGI);

			if (dataCost.CON != null)
				cost.set(CON, dataCost.CON);

			if (dataCost.KNO != null)
				cost.set(KNO, dataCost.KNO);

			if (dataCost.WIS != null)
				cost.set(WIS, dataCost.WIS);

			if (dataCost.ANY != null)
				cost.set(ANY, dataCost.ANY);

			costs.push(cost);
		}
		return SkillPointCombination.newCosts(costs);
	}

	/** Return the first type we run into in the first cost**/
	function getTypeFromCost(costs:Costs)
	{
		if (costs.length != 0)
		{
			for (type in SkillPointCombination.ARRAY)
			{
				if (costs[0].get(type) != 0)
					return type;
			}
		}
		return ANY;
	}

	function new(skillData:SkillData_skills)
	{
		this.name = skillData.name;
		this.desc = skillData.desc;
		this.value = skillData.value;
		this.value2 = skillData.value2;
		this.flavor = skillData.flavor != null ? skillData.flavor : '';
		this.rarity = skillData.rarity;
		this.costs = parseCostsFromSkillData(skillData.costs);
		this.type = getTypeFromCost(this.costs);
		this.targetMethod = skillData.targetMethod;
		this.cooldown = skillData.cooldown != null ? skillData.cooldown : 1;
		this.maxCharges = skillData.maxCharges != null ? skillData.maxCharges : 1;
		this.chargesPerCD = skillData.chargesPerCD != null ? skillData.chargesPerCD : 1;

		// defaults
		this.spritePath = AssetPaths.emptySkill__png;
		this.category = generic;
	}
}
