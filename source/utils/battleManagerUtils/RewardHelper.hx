package utils.battleManagerUtils;

import Castle.SkillData_skills_rarity;
import flixel.math.FlxRandom;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import models.skills.Skill;
import models.skills.SkillFactory;

using utils.GameUtils;

/** Helper class to create after-battle rewards. **/
class RewardHelper
{
	static final SKILL_RARITY_ITEMS = [COMMON, UNCOMMON, RARE];
	static final SKILL_RARITY_WEIGHTS_NORMAL:Array<Float> = [80, 19, 1];
	static final SKILL_RARITY_WEIGHTS_ELITE:Array<Float> = [45, 45, 5];
	static final SKILL_RARITY_WEIGHTS_BOSS:Array<Float> = [0, 0, 1];

	static final BATTLE_TYPE_TO_WEIGHTS = [
		BATTLE => SKILL_RARITY_WEIGHTS_NORMAL,
		ELITE => SKILL_RARITY_WEIGHTS_ELITE,
		BOSS => SKILL_RARITY_WEIGHTS_BOSS
	];
	static final REWARD_MULTIPLIER:Map<GameEventType, Int> = [TUTORIAL => 0, BATTLE => 1, ELITE => 2, BOSS => 3];
	static inline final baseExpReward = 10;

	static final random = new FlxRandom();

	static function getSkillRewardForChar(charName:String = 'Ryder', battleType:GameEventType)
	{
		var rarity = GameUtils.weightedPick(SKILL_RARITY_ITEMS, BATTLE_TYPE_TO_WEIGHTS.get(battleType));
		var pool = SkillFactory.getSkillBlueprints(charName, rarity);
		var chosenSkill = pool[random.int(0, pool.length - 1)]();
		return chosenSkill;
	}

	/** Gets a skill from a larger pool: Both characters and the generic skills. But dont choose the same ones as before. **/
	static function getThirdSkillReward(excludes:Array<Skill>, battleType:GameEventType):Skill
	{
		var rarity = GameUtils.weightedPick(SKILL_RARITY_ITEMS, BATTLE_TYPE_TO_WEIGHTS.get(battleType));
		var pool = new Array<SkillBlueprint>();

		for (charInfo in Player.chars)
		{
			pool = pool.concat(SkillFactory.getSkillBlueprints(charInfo.name, rarity));
		}

		for (blueprint in SkillFactory.genericSkills)
		{
			pool.push(blueprint);
		}

		var checkDuplicate = true;
		var chosenSkill:Skill = pool[random.int(0, pool.length - 1)]();
		while (checkDuplicate && rarity == COMMON)
		{
			checkDuplicate = false;
			for (exclude in excludes)
			{
				if (chosenSkill.name == exclude.name)
				{
					chosenSkill = pool[random.int(0, pool.length - 1)]();
					checkDuplicate = true;
					break;
				}
			}
		}
		return chosenSkill;
	}

	/** Get the 3 skill rewards from a battle. Elite or boss only?
	 * 
	 * The first is for your first char. The 2nd is for your second char.
	 *
	 * The third one could be for either. Also could be a generic skill.
	**/
	public static function getSkillRewards(?battleType:GameEventType)
	{
		var rewards = new Array<Skill>();
		if (battleType == null)
			battleType = BATTLE;

		rewards.push(getSkillRewardForChar(Player.chars[0].name, battleType));
		rewards.push(getSkillRewardForChar(Player.chars[1].name, battleType));
		rewards.push(getThirdSkillReward(rewards, battleType));
		return rewards;
	}

	public static function getExpReward(battleType:GameEventType)
	{
		if (REWARD_MULTIPLIER.exists(battleType))
			return REWARD_MULTIPLIER.get(battleType) * baseExpReward;
		else
			return 0;
	}

	public static function getMoneyReward(battleType:GameEventType)
	{
		var baseMoney = random.int(4, 7);
		if (REWARD_MULTIPLIER.exists(battleType))
			return REWARD_MULTIPLIER.get(battleType) * baseMoney;
		else
			return 0;
	}

	public static function getSkillShopChoices()
	{
		var retVal = new Array<Skill>();

		// get x skills for each character. Small chance of uncommon or rare.
		for (char in Player.chars)
		{
			var x = 2;
			var currentChoices = new Array<SkillBlueprint>(); // keep track of our choices so we don't choose duplicates
			for (i in 0...x)
			{
				var rarity = GameUtils.weightedPick(SKILL_RARITY_ITEMS, SKILL_RARITY_WEIGHTS_NORMAL);
				var pool = SkillFactory.getSkillBlueprints(char.name, rarity);
				var choice = pool.getRandomChoice(currentChoices); // pass in the currentChoices as excludes so we dont get duplicates.
				currentChoices.push(choice); // add the skill blueprint to that array.
				retVal.push(choice()); // call the skill blueprint to add the actual skill to the return array.
			}
		}

		return retVal;
	}
}
