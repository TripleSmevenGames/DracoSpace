package models.player;

import flixel.system.FlxAssets.FlxGraphicAsset;
import models.skills.Skill;

enum CharacterType
{
	PLAYER;
	ENEMY;
	NONE;
}

/** Represents a character outside of battle. Health, skills, etc. **/
class CharacterInfo {
    public var spritePath: FlxGraphicAsset;

    public var name:String;
    public var type:CharacterType;
    public var maxHp:Int;
    public var currHp:Int;
    public var skills:Array<Skill>;

    public static function sampleRyder() {
        var ryder = new CharacterInfo();

        ryder.name = 'Ryder';
        ryder.type = PLAYER;
        ryder.spritePath = AssetPaths.KiwiCat__png;
        ryder.maxHp = 30;
        ryder.currHp = 30;
        ryder.skills = [Skill.sampleAttack(), Skill.sampleDefend()];

        return ryder;
    }

    public static function sampleSlime() {
        var slime = new CharacterInfo();

        slime.name = 'Slime';
        slime.type = ENEMY;
        slime.spritePath = AssetPaths.Waffles__png;
        slime.maxHp = 10;
        slime.currHp = 10;
        slime.skills = [Skill.sampleEnemyAttack()];

        return slime;
    }

    public function new() {

    }
}