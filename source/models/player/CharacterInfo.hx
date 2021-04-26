package models.player;

import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill;
import models.skills.SkillFactory;
import ui.battle.status.Status;

enum CharacterType
{
	PLAYER;
	ENEMY;
	NONE;
}

/** Represents a character outside of battle. Health, skills, etc. **/
class CharacterInfo
{
	public var spritePath:FlxGraphicAsset;
	public var avatarPath:FlxGraphicAsset;

	public var name:String;
	public var type:CharacterType;
	public var category:Castle.SkillDataKind; // used by a Skill to know what player character can equip it.
	public var maxHp:Int = 1;
	public var currHp:Int = 1;
	public var skills:Array<Skill> = [];
	public var numSkillSlots:Int = 2;
	public var draw:Int = 0;

	public var initialStatuses:Array<StatusType> = [];

	static var sf = SkillFactory;

	public function equipSkill(skill:Skill)
	{
		if (skill.category != this.category)
		{
			trace('Warning: $name tried to equip ${skill.name}, which the this char cant equip');
			return;
		}

		if (!Player.inventory.unequippedSkills.contains(skill))
		{
			trace('Warning: $name tried to equip ${skill.name}, which the Player does not own');
			return;
		}

		if (this.skills.length < numSkillSlots)
		{
			Player.inventory.unequippedSkills.remove(skill);
			this.skills.push(skill);
		}
	}

	public function unequipSkill(skill:Skill)
	{
		if (this.skills.contains(skill))
		{
			this.skills.remove(skill);
			Player.inventory.unequippedSkills.push(skill);
		}
	}

	public static function sampleRyder()
	{
		var ryder = new CharacterInfo();

		ryder.name = 'Ryder';
		ryder.category = Castle.SkillDataKind.ryder;
		ryder.type = PLAYER;
		ryder.spritePath = AssetPaths.lucario__png;
		ryder.avatarPath = AssetPaths.RyderAvatar__png;
		ryder.maxHp = 30;
		ryder.currHp = 30;
		ryder.skills = [sf.ryderSkillsBasic.get(protect)()];
		ryder.draw = 1;

		return ryder;
	}

	public static function sampleKiwi()
	{
		var kiwi = new CharacterInfo();

		kiwi.name = 'Kiwi';
		kiwi.category = Castle.SkillDataKind.kiwi;
		kiwi.type = PLAYER;
		kiwi.spritePath = AssetPaths.kiwi__png;
		kiwi.avatarPath = AssetPaths.KiwiAvatar__png;
		kiwi.maxHp = 30;
		kiwi.currHp = 30;
		kiwi.skills = [sf.kiwiSkillsBasic.get(shuriken)()];
		kiwi.draw = 1;

		return kiwi;
	}

	public static function createEnemy(name:String, spritePath:FlxGraphicAsset, hp:Int, skills:Array<Skill>, draw:Int = 1)
	{
		var enemy = new CharacterInfo();
		enemy.name = name;
		enemy.type = ENEMY;
		enemy.spritePath = spritePath;
		enemy.maxHp = hp;
		enemy.currHp = hp;
		enemy.skills = skills;
		enemy.draw = draw;
		return enemy;
	}

	public function new() {}
}
