package models.player;

import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill;
import models.skills.SkillFactory;

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
	public var maxHp:Int = 1;
	public var currHp:Int = 1;
	public var skills:Array<Skill>;
	public var draw:Int = 0;

	static var sf = SkillFactory;

	public static function sampleRyder()
	{
		var ryder = new CharacterInfo();

		ryder.name = 'Ryder';
		ryder.type = PLAYER;
		ryder.spritePath = AssetPaths.lucario__png;
		ryder.avatarPath = AssetPaths.RyderAvatar__png;
		ryder.maxHp = 30;
		ryder.currHp = 30;
		ryder.skills = sf.getAllRyderSkills();
		ryder.draw = 2;

		return ryder;
	}

	public static function sampleKiwi()
	{
		var kiwi = new CharacterInfo();

		kiwi.name = 'Kiwi';
		kiwi.type = PLAYER;
		kiwi.spritePath = AssetPaths.zangoose__png;
		kiwi.avatarPath = AssetPaths.KiwiAvatar__png;
		kiwi.maxHp = 30;
		kiwi.currHp = 30;
		kiwi.skills = [sf.genericSkills.get(watch)()];
		kiwi.draw = 2;

		return kiwi;
	}

	public static function sampleSlime()
	{
		var slime = new CharacterInfo();

		slime.name = 'Slime';
		slime.type = ENEMY;
		slime.spritePath = AssetPaths.gulpin__png;
		slime.maxHp = 10;
		slime.currHp = 10;
		slime.skills = [sf.enemySkills.get(tackle)(), sf.enemySkills.get(cower)()];
		slime.draw = 2;

		return slime;
	}

	function new() {}
}
