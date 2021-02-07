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
typedef SkillList = Map<SkillData_skillsKind, Void->Skill>;

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

	public static var genericSkills:SkillList = [
		watch => () ->
		{
			var skill = skillFromData(generic, watch);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.eDeck.revealCards(skill.value);
			}
			skill.spritePath = AssetPaths.watch1__png;
			return skill;
		},
		patience => () ->
		{
			var skill = skillFromData(generic, patience);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.carryOverAll();
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		expertise => () ->
		{
			var skill = skillFromData(generic, expertise);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.drawCards(2, owner);
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
	];

	public static var enemySkills:SkillList = [
		tackle => () ->
		{
			var skill = skillFromData(enemy, tackle);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		cower => () ->
		{
			var skill = skillFromData(enemy, cower);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		magicBolt => () ->
		{
			var skill = skillFromData(enemy, magicBolt);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		magicBlast => () ->
		{
			var skill = skillFromData(enemy, magicBlast);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		howl => () ->
		{
			var skill = skillFromData(enemy, howl);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(ATTACK);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		}
	];

	public static var ryderSkills = [
		bash => () ->
		{
			var skill = skillFromData(ryder, bash);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		guard => () ->
		{
			var skill = skillFromData(ryder, guard);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		distract => () ->
		{
			var skill = skillFromData(ryder, distract);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(TAUNT, skill.value);
				context.pDeck.drawCards(1);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		aggravate => () ->
		{
			var skill = skillFromData(ryder, aggravate);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					owner.addStatus(TAUNT, skill.value2);
				}
				SkillAnimations.genericBuffPlay(effect)([owner], owner, context);
			};
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		riposte => () ->
		{
			var skill = skillFromData(ryder, riposte);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericBlockPlay(skill.value)(targets, owner, context);
				var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					owner.addStatus(COUNTER, skill.value);
				}
				SkillAnimations.genericBuffPlay(effect)(targets, owner, context);
			};
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		bladeDance => () ->
		{
			var skill = skillFromData(ryder, bladeDance);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					owner.addStatus(COUNTER, skill.value);
				}
				SkillAnimations.genericBuffPlay(effect)([owner], owner, context);
			};
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		adrenaline => () ->
		{
			var skill = skillFromData(ryder, adrenaline);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(ATTACK, 1);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		}
	];

	public static function getAllRyderSkills()
	{
		var skills = new Array<Skill>();
		for (skill in ryderSkills)
		{
			skills.push(skill());
		}
		return skills;
	}
}
