package utils.battleManagerUtils;

import Castle.SkillData_skills_rarity;
import flixel.math.FlxRandom;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import models.skills.Skill;
import models.skills.SkillFactory;

/** Helper class to create after-battle rewards. **/
class RewardHelper
{
	static final SKILL_RARITY_ITEMS = [COMMON, UNCOMMON, RARE];
	static final SKILL_RARITY_WEIGHTS_NORMAL:Array<Float> = [80, 19, 1];
	static final SKILL_RARITY_WEIGHTS_ELITE:Array<Float> = [45, 45, 5];
	static final SKILL_RARITY_WEIGHTS_BOSS:Array<Float> = [0, 0, 1];

	static final REWARD_MULTIPLIER:Map<GameEventType, Int> = [BATTLE => 1, ELITE => 2, BOSS => 3];

	static final random = new FlxRandom();

	static function getSkillRewardForChar(charName:String = 'Ryder')
	{
		var rarity = GameUtils.weightedPick(SKILL_RARITY_ITEMS, SKILL_RARITY_WEIGHTS_NORMAL);
		var pool = SkillFactory.getSkillBlueprints(charName, rarity);
		var chosenSkill = pool[random.int(0, pool.length - 1)]();
		return chosenSkill;
	}

	/** Gets a skill from a larger pool: Both characters and the generic skills. But dont choose the same ones as before. **/
	static function getThirdSkillReward(excludes:Array<Skill>):Skill
	{
		var rarity = GameUtils.weightedPick(SKILL_RARITY_ITEMS, SKILL_RARITY_WEIGHTS_NORMAL);
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
		while (checkDuplicate)
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

	/** Get the 3 skill rewards for levelling up in battle.
	 * 
	 * The first is for your first char. The 2nd is for your second char.
	 *
	 * The third one could be for either. Also could be a generic skill.
	**/
	public static function getSkillRewards()
	{
		var rewards = new Array<Skill>();
		rewards.push(getSkillRewardForChar(Player.chars[0].name));
		rewards.push(getSkillRewardForChar(Player.chars[1].name));
		rewards.push(getThirdSkillReward(rewards));
		return rewards;
	}

	public static function getExpReward(battleType:GameEventType)
	{
		return REWARD_MULTIPLIER.get(battleType) * 1;
	}

	public static function getMoneyReward(battleType:GameEventType)
	{
		return REWARD_MULTIPLIER.get(battleType) * 10;
	}
}
