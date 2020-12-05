package models.characters;

import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import models.skills.Skill;

enum CharacterType
{
	PLAYER;
	ENEMY;
}

class Character extends FlxNestedSprite
{
	public var name:String;
	public var type:CharacterType;
	public var maxHp:Int;
	public var currHp(default, set):Int;
	public var currBlock(default, set):Int;
	public var skills:Array<Skill> = new Array<Skill>();

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
		var ryder = new Character('Ryder', PLAYER, 50);
		ryder.skills.concat([Skill.sampleAttack(), Skill.sampleDefend()]);
		return ryder;
	}

	public static function sampleSlime(lvl:Int = 1)
	{
		var slime = new Character('Slime', ENEMY, 10 * lvl);
		slime.skills.push(Skill.sampleEnemyAttack());
		return slime;
	}

	public function new(name:String, type:CharacterType, hp:Int)
	{
		super();
		this.name = name;
		this.type = type;

		this.maxHp = hp;
		this.currHp = hp;
	}
}
