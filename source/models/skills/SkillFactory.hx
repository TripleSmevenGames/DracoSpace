package models.skills;

import Castle;
import flixel.FlxSprite;
import haxe.Exception;
import models.skills.Skill.SkillPointCombination;
import ui.battle.CharacterSprite;
import ui.battle.DeckSprite;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

typedef SPC = SkillPointCombination;

/** Template
	public static function clawSkill()
	{
		var skillData = Castle.skillsData.get(claw);
		var skill = new Skill(skillData);

		skill.play = (targets:Array<CharacterSprite>, context:BattleContext) ->
		{
			for (target in targets)
				target.takeDamage(5);
		}

		skill.spritePath = AssetPaths.;
		return skill;
	}
**/
/** Use this to create skills. **/
@:access(models.skills.Skill)
class SkillFactory
{
	public static function init()
	{
		var dbPath = haxe.Resource.getString(AssetPaths.skillData__cdb);
		Castle.load(dbPath);
	}

	static function get(category:SkillDataKind, skillId:SkillData_skillsKind):Null<SkillData_skills>
	{
		var skillsForCategory = Castle.skillData.get(category).skills;
		var matchedSkills = skillsForCategory.filter((skillData:SkillData_skills) -> skillData.id == skillId);

		if (matchedSkills.length == 1)
			return matchedSkills[0];
		else
			throw new Exception('bad get call in skillFactory. Did not find ${skillId.toString()} in ${category.toString()}');
		return null;
	}

	public static function laserSawSkill()
	{
		var skillData = get(ryder, laserSaw);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
				owner.dealDamageTo(target, 7);
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function fusionHammerSkill()
	{
		var skillData = get(ryder, fusionHammer);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
				owner.dealDamageTo(target, 15);
		}
		skill.spritePath = AssetPaths.fusionHammer__png;
		return skill;
	}

	public static function armGuardSkill()
	{
		var skillData = get(ryder, armGuard);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
				target.currBlock += 5;
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function watchSkill()
	{
		var skillData = get(generic, watch);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			context.eDeck.revealCards(1);
		}
		skill.spritePath = AssetPaths.watch1__png;
		return skill;
	}

	public static function kunaiSkill()
	{
		var skillData = get(generic, kunai);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
				owner.dealDamageTo(target, 5);
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function clawSkill()
	{
		var skillData = get(enemy, claw);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var bsal = GameController.battleSpriteAnimsLayer;
			var hitSprite = bsal.createStandardAnim(AssetPaths.weaponhit_spritesheet__png, 100, 100, 30, 2);
			var effect = () ->
			{
				for (target in targets)
					owner.dealDamageTo(target, 5);
			}
			for (target in targets)
				bsal.addOneShotAnim(hitSprite, target.x, target.y, effect, 2);
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function toughHideSkill()
	{
		var skillData = get(enemy, toughHide);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			owner.currBlock += 4;
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function plasmaTorchSkill()
	{
		var skillData = get(ryder, plasmaTorch);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			var bsal = GameController.battleSpriteAnimsLayer;
			var fireSprite = bsal.createStandardAnim(AssetPaths.magickahit_spritesheet__png, 100, 100, 40);
			var effect = () ->
			{
				for (target in targets)
				{
					owner.dealDamageTo(target, 6);
					target.addStatus(BURN, 2);
				}
			};

			var yAdjust = -50; // sprite is slightly off
			for (target in targets)
				bsal.addOneShotAnim(fireSprite, target.x, target.y + yAdjust, effect, 10);
		}
		skill.spritePath = AssetPaths.plasmaTorch1__png;
		return skill;
	}

	public static function adrenalineSkill()
	{
		var skillData = get(generic, adrenaline);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			owner.addStatus(ATTACK, 1);
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function patienceSkill()
	{
		var skillData = get(generic, patience);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			context.pDeck.carryOverAll();
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function expertiseSkill()
	{
		var skillData = get(generic, expertise);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			context.pDeck.drawCards(2, owner);
		}
		skill.spritePath = AssetPaths.emptySkill__png;
		return skill;
	}

	public static function mistyChillSkill()
	{
		var skillData = get(ryder, mistyChill);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
			{
				owner.dealDamageTo(target, 5);
				target.addStatus(COLD, 1);
			}
		}
		skill.spritePath = AssetPaths.mistyChill1__png;
		return skill;
	}

	public static function electricSurgeSkill()
	{
		var skillData = get(kiwi, electricSurge);
		var skill = new Skill(skillData);
		skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
		{
			for (target in targets)
			{
				owner.dealDamageTo(target, 10);
				owner.addStatus(STATIC, 1);
			}
		}
		skill.spritePath = AssetPaths.electricSurge__png;
		return skill;
	}
}
