package models.player;

import models.artifacts.Artifact;
import models.artifacts.listOfArtifacts.BatteryArtifact;
import models.skills.Skill;
import models.skills.SkillFactory;
import ui.MapTile;
import utils.battleManagerUtils.RewardHelper;

using utils.GameUtils;

/** Represents the player's party itself outside of battle. Characters, inventory, skills, money, etc. 
 * Also holds a lot of "globals" relating to the inventory menu, equipement, etc.
**/
class Player
{
	public static var deck:Deck;
	public static var chars:Array<CharacterInfo> = [];
	public static var money:Int;
	public static var inventory:Inventory;
	public static var exp:Int;

	// we scale the price of skills based on how many you've bought already
	public static var skillsBought:Int;
	// We persist the skillShopChoices until the player buys one.
	static var currentSkillShopChoices:Array<Skill>;

	// count how many battles the player has fought so far. Used to scale the battles.
	public static var battlesFought:Int;
	public static var currentMapTile:MapTile;

	public static inline final MAX_SKILL_SLOTS = 6; // max skill slots a player char can have.
	public static inline final MAX_UNEQUIPPED_SKILLS = 8;

	public static inline final MAX_ARTIFACT_SLOTS = 3;
	public static inline final MAX_UNEQUIPPED_ARTIFACTS = 8;

	public static function getColumn()
	{
		return currentMapTile.node.column;
	}

	/** Get a list of all the skills the player has. **/
	public static function getSkills()
	{
		var skills = inventory.unequippedSkills;
		for (char in chars)
		{
			skills = char.skills.concat(skills);
		}
		return skills;
	}

	/** Get a random skill from either the player's unequipped skills or the characters' equipped skills. **/
	public static function getRandomSkill()
	{
		return getSkills().getRandomChoice();
	}

	/** Call this any time the player gains a new skill, either from an event, buying it, or battle reward. **/
	public static function gainSkill(skill:Skill)
	{
		inventory.unequippedSkills.push(skill);
	}

	/** Call this when a player permanently loses a skill. It will search the unequipped skills first before searching the player characters. **/
	public static function loseSkill(skillName:String):Bool
	{
		// first, try searching you unequipped skills.
		for (i in 0...inventory.unequippedSkills.length)
		{
			var skill = inventory.unequippedSkills[i];

			if (skill.name == skillName)
			{
				inventory.unequippedSkills.splice(i, 1);
				return true;
			}
		}

		// if we haven't returned already, that means we didnt find it. Try looking in our characters now.
		for (char in Player.chars)
		{
			// this will be true if we found that skill equipped on the character and we removed it.
			var didLoseSkill = char.loseSkill(skillName);
			if (didLoseSkill)
				return true;
		}

		return false;
	}

	public static function gainArtifact(artifact:Artifact)
	{
		inventory.unequippedArtifacts.push(artifact);
	}

	public static function rerollSkillShopChoices()
	{
		currentSkillShopChoices = RewardHelper.getSkillShopChoices();
	}

	public static function getCurrentSkillShopChoices()
	{
		if (currentSkillShopChoices.length == 0)
			rerollSkillShopChoices();

		return currentSkillShopChoices;
	}

	public static function init()
	{
		chars = [CharacterInfo.sampleRyder(), CharacterInfo.sampleKiwi()];
		deck = Deck.ryderKiwiDeck();
		inventory = new Inventory();

		money = 0;
		exp = 0;
		skillsBought = 0;
		currentSkillShopChoices = [];
		battlesFought = 0;

		// https://haxe.org/manual/lf-condition-compilation.html
		#if godmode
		gainSkill(SkillFactory.kiwiSkillsCommon.get(swordCutter)());
		gainArtifact(new BatteryArtifact());
		money = 1000;
		exp = 1000;
		#end
	}
}
