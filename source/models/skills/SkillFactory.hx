package models.skills;

import Castle;
import flixel.FlxSprite;
import haxe.Exception;
import models.skills.Skill.Effect;
import models.skills.Skill.SkillPointCombination;
import models.skills.SkillAnimations;
import ui.battle.DeckSprite;
import ui.battle.character.CharacterSprite;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

typedef SPC = SkillPointCombination;

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

	static function skillFromData(category:SkillDataKind, skillId:SkillData_skillsKind):Skill
	{
		return new Skill(get(category, skillId));
	}

	public static var genericSkills = {
		watchSkill: () ->
		{
			var skill = skillFromData(generic, watch);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.eDeck.revealCards(skill.value);
			}
			skill.spritePath = AssetPaths.watch1__png;
			return skill;
		},
		patienceSkill: () ->
		{
			var skill = skillFromData(generic, patience);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.carryOverAll();
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		expertiseSkill: () ->
		{
			var skill = skillFromData(generic, expertise);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.drawCards(2, owner);
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		}
	}

	public static var enemySkills = {
		tackleSkill: () ->
		{
			var skill = skillFromData(enemy, tackle);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		cowerSkill: () ->
		{
			var skill = skillFromData(enemy, cower);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		magicBoltSkill: () ->
		{
			var skill = skillFromData(enemy, magicBolt);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		magicBlastSkill: () ->
		{
			var skill = skillFromData(enemy, magicBlast);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		}
	}
}
