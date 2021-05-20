package models.player;

import models.skills.Skill;
import models.skills.SkillFactory;
import utils.battleManagerUtils.RewardHelper;

/** Represents the player's party itself outside of battle. Characters, inventory, skills, money, etc. **/
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

	public static function refreshSkillShopChoices()
	{
		currentSkillShopChoices = RewardHelper.getSkillShopChoices();
	}

	public static function getCurrentSkillShopChoices()
	{
		if (currentSkillShopChoices.length == 0)
			refreshSkillShopChoices();

		return currentSkillShopChoices;
	}

	public static function init()
	{
		chars = [CharacterInfo.sampleRyder(), CharacterInfo.sampleKiwi()];
		deck = Deck.ryderKiwiDeck();
		inventory = new Inventory();
		gainSkill(SkillFactory.kiwiSkillsCommon.get(surpriseAttack)());

		money = 0;
		exp = 0;
		skillsBought = 0;
		currentSkillShopChoices = [];
	}
}
