package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.skills.Skill;

enum CharacterType
{
	PLAYER;
	ENEMY;
}

/** Represents a character's sprite during battle. */
class Character extends FlxSpriteGroup
{
	public var name:String;
	public var type:CharacterType;
	public var maxHp:Int;
	public var currHp(default, set):Int;
	public var currBlock(default, set):Int;
	public var skills:Array<Skill> = new Array<Skill>();

	public var sprite:FlxSprite;

	public function set_currHp(val:Int)
	{
		if (val > maxHp)
			val = maxHp;
		else if (val < 0)
			val = 0;

		return currHp = val;
	}

	public function set_currBlock(val:Int)
	{
		if (val < 0)
			val = 0;

		return currBlock = val;
	}

	public function takeDamage(val:Int)
	{
		if (val > currBlock)
		{
			currHp -= (val - currBlock);
		}
		currBlock -= val;
	}

	public static function sampleRyder()
	{
		var ryder = new Character('Ryder', PLAYER);

		var skillsToAdd = [Skill.sampleAttack(), Skill.sampleDefend()];
		ryder.skills = ryder.skills.concat(skillsToAdd);

		var sprite = new FlxSprite(0, 0, AssetPaths.KiwiCat__png);
		sprite.setGraphicSize(0, Std.int(sprite.height * 8));
		sprite.updateHitbox();
		ryder.sprite = sprite;

		ryder.add(ryder.sprite);

		for (i in 0...ryder.skills.length)
		{
			var skill = ryder.skills[i];
			var skillSprite = new SkillSprite(skill);
			skillSprite.setPosition(sprite.width + skillSprite.width * i, 0);
			ryder.add(skillSprite);
		}

		return ryder;
	}

	public static function sampleSlime(lvl:Int = 1)
	{
		var slime = new Character('Slime', ENEMY);
		slime.maxHp = 10 * lvl;
		slime.currHp = slime.maxHp;
		slime.skills.push(Skill.sampleEnemyAttack());
		return slime;
	}

	public function new(name:String, type:CharacterType)
	{
		super();
		this.name = name;
		this.type = type;

		maxHp = currHp = 1;
		currBlock = 0;
		sprite = new FlxSprite();
		sprite.setGraphicSize(0, 64);
	}
}
