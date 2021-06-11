package models.player;

import models.artifacts.Artifact;
import models.artifacts.listOfArtifacts.BatteryArtifact;
import models.skills.Skill;
import models.skills.SkillFactory;
import ui.MapTile;
import utils.battleManagerUtils.RewardHelper;

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
		var skills = new Array<Skill>();
		for (char in chars)
		{
			skills = char.skills.concat(skills);
		}
		return skills;
	}

	public static function gainSkill(skill:Skill)
	{
		inventory.unequippedSkills.push(skill);
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

		// https://haxe.org/manual/lf-condition-compilation.html
		#if godmode
		gainSkill(SkillFactory.kiwiSkillsCommon.get(swordCutter)());
		gainArtifact(new BatteryArtifact());
		money = 1000;
		exp = 1000;
		#end
	}
}
