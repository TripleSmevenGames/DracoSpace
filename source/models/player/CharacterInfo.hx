package models.player;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill;
import models.skills.SkillFactory;
import ui.battle.status.Status;
import utils.BattleSoundManager.SoundType;

using utils.ViewUtils;

enum CharacterType
{
	PLAYER;
	ENEMY;
	NONE;
}

typedef SpriteSheetInfo =
{
	?spritePath:FlxGraphicAsset,
	?width:Int,
	?height:Int,
	?idleFrames:Array<Int>,
	?hurtFrames:Array<Int>,
	?attackFrames:Array<Int>,
}

/** Represents a character outside of battle. Health, skills, etc. **/
class CharacterInfo
{
	public var spriteSheetInfo:SpriteSheetInfo;
	public var avatarPath:FlxGraphicAsset;

	public var name:String;

	/** PLAYER or ENEMY**/
	public var type:CharacterType;

	/** What type of sound should be played when this character is hit. E.g. Flesh, rock, ghost, etc. **/
	public var soundType:SoundType;

	public var category:Castle.SkillDataKind; // used by a Skill to know what player character can equip it.
	public var maxHp:Int = 1;
	public var currHp:Int = 1;
	public var skills:Array<Skill> = [];
	public var numSkillSlots:Int = 2;

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

	public static function newSpriteSheetInfo(spritePath:FlxGraphicAsset, width:Int, height:Int, numIdleFrames:Int)
	{
		var idleFrames = new Array<Int>();
		for (i in 0...numIdleFrames)
			idleFrames.push(i);

		var spriteSheetInfo:SpriteSheetInfo = {
			spritePath: spritePath,
			width: width,
			height: height,
			idleFrames: idleFrames,
		};

		return spriteSheetInfo;
	}

	public static function sampleRyder()
	{
		var ryder = new CharacterInfo();

		ryder.name = 'Ryder';
		ryder.category = Castle.SkillDataKind.ryder;
		ryder.type = PLAYER;
		ryder.spriteSheetInfo = newSpriteSheetInfo(AssetPaths.RyderIdle74x79x16__png, 74, 79, 16);
		ryder.avatarPath = AssetPaths.RyderAvatar__png;
		ryder.maxHp = 30;
		ryder.currHp = 30;
		ryder.skills = [sf.ryderSkillsBasic.get(protect)()];
		ryder.soundType = FLESH;

		return ryder;
	}

	public static function sampleKiwi()
	{
		var kiwi = new CharacterInfo();

		kiwi.name = 'Kiwi';
		kiwi.category = Castle.SkillDataKind.kiwi;
		kiwi.type = PLAYER;
		kiwi.spriteSheetInfo = newSpriteSheetInfo(AssetPaths.kiwi__png, 48, 50, 1);
		kiwi.avatarPath = AssetPaths.KiwiAvatar__png;
		kiwi.maxHp = 30;
		kiwi.currHp = 30;
		kiwi.skills = [sf.kiwiSkillsBasic.get(shuriken)()];
		kiwi.soundType = FLESH;

		return kiwi;
	}

	public static function createEnemy(name:String, spriteSheetInfo:SpriteSheetInfo, hp:Int, skills:Array<Skill>)
	{
		var enemy = new CharacterInfo();
		enemy.name = name;
		enemy.type = ENEMY;
		enemy.category = Castle.SkillDataKind.enemy;
		enemy.spriteSheetInfo = spriteSheetInfo;
		enemy.maxHp = hp;
		enemy.currHp = hp;
		enemy.skills = skills;
		enemy.soundType = FLESH;
		return enemy;
	}

	function new() {}
}
