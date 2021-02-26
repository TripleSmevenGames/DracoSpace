package models.skills;

import Castle;
import flixel.FlxG;
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
typedef SkillBlueprint = Void->Skill;
typedef SkillList = Map<SkillData_skillsKind, SkillBlueprint>;
typedef CharSkillList = Map<SkillData_skills_rarity, SkillList>;

/** Use this to create skills. **/
@:access(models.skills.Skill)
class SkillFactory
{
	public static final ryderPlaceholder = AssetPaths.ryderSkill__png;
	public static final kiwiPlaceholder = AssetPaths.kiwiSkill__png;

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
		var skill = new Skill(get(category, skillId));
		skill.category = category;
		return skill;
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

	public static var ryderSkillsBasic = [
		bash => () ->
		{
			var skill = skillFromData(ryder, bash);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		guard => () ->
		{
			var skill = skillFromData(ryder, guard);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];

	public static var ryderSkillsCommon = [
		distract => () ->
		{
			var skill = skillFromData(ryder, distract);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(TAUNT, skill.value);
				context.pDeck.drawCards(1);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
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
			skill.spritePath = ryderPlaceholder;
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
			skill.spritePath = ryderPlaceholder;
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
			skill.spritePath = ryderPlaceholder;
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
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		wideSwing => () ->
		{
			var skill = skillFromData(ryder, wideSwing);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		flurry => () ->
		{
			var skill = skillFromData(ryder, flurry);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				for (i in 0...3)
				{
					var animSprite = SkillAnimations.getFastHitAnim();
					SkillAnimations.genericAttackPlay(skill.value, animSprite)(targets, owner, context);
				}
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		crush => () ->
		{
			var skill = skillFromData(ryder, crush);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var animSprite = SkillAnimations.getFastHitAnim();
				SkillAnimations.genericAttackPlay(skill.value, animSprite)(targets, owner, context);
				if (targets[0].currBlock <= skill.value)
				{
					SkillAnimations.genericAttackPlay(skill.value, animSprite)(targets, owner, context);
				}
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		recklessSwing => () ->
		{
			var skill = skillFromData(ryder, recklessSwing);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				var animSprite = SkillAnimations.getFastHitAnim();
				var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					owner.takeDamage(skill.value2, owner, context);
				};
				SkillAnimations.getCustomPlay(animSprite, effect)(targets, owner, context);
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		protect => () ->
		{
			var skill = skillFromData(ryder, protect);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];

	public static var ryderSkillsUncommon = [
		lunge => () ->
		{
			var skill = skillFromData(ryder, lunge);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					owner.addStatus(ATTACK, skill.value2);
				}
				SkillAnimations.genericBuffPlay(effect)([], owner, context);
			};
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];

	public static var ryderSkillsRare = [
		revenge => () ->
		{
			var skill = skillFromData(ryder, revenge);
			skill.play = skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var damage = owner.maxHp - owner.currHp;
				SkillAnimations.genericAttackPlay(damage)(targets, owner, context);
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];

	public static var kiwiSkillsBasic = [
		kick => () ->
		{
			var skill = skillFromData(kiwi, kick);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		dodgeRoll => () ->
		{
			var skill = skillFromData(kiwi, dodgeRoll);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(DODGE, skill.value);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
	];

	public static var kiwiSkillsCommon = [
		takeCover => () ->
		{
			var skill = skillFromData(kiwi, takeCover);
			var animSprite = SkillAnimations.getBlockAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.currBlock += skill.value;
				context.pDeck.drawCards(1);
			}
			var effectFrame = 10;
			var sound = FlxG.sound.load(AssetPaths.gainBlock1__wav);
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect, effectFrame, sound);
			return skill;
		},
		electricSurge => () ->
		{
			var skill = skillFromData(kiwi, electricSurge);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(STATIC, 1);
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				SkillAnimations.genericBuffPlay(effect)(targets, owner, context);
			}
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		shockShield => () ->
		{
			var skill = skillFromData(kiwi, shockShield);
			var animSprite = SkillAnimations.getBlockAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.currBlock += context.expendStatic();
			}
			var effectFrame = 10;
			var sound = FlxG.sound.load(AssetPaths.gainBlock1__wav);
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect, effectFrame, sound);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		surpriseAttack => () ->
		{
			var skill = skillFromData(kiwi, surpriseAttack);
			var animSprite:FlxSprite = SkillAnimations.getHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				if (target.currBlock == 0)
					owner.dealDamageTo(skill.value, target, context);
				else
					owner.dealDamageTo(0, target, context);
			};
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		disarm => () ->
		{
			var skill = skillFromData(kiwi, disarm);
			var animSprite:FlxSprite = SkillAnimations.getHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				if (target.currBlock == 0)
				{
					owner.dealDamageTo(skill.value, target, context);
					context.eDeck.discardRandomCards(1);
				}
				else
				{
					owner.dealDamageTo(0, target, context);
				}
			};
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		// sabatoge => () -> {},
		charge => () ->
		{
			var skill = skillFromData(kiwi, charge);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(STATIC, skill.value);
				context.pDeck.drawCards(1);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		blindThrow => () ->
		{
			var skill = skillFromData(kiwi, blindThrow);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		endlessShuriken => () ->
		{
			var skill = skillFromData(kiwi, endlessShuriken);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		}
	];

	public static var kiwiSkillsUncommon = [
		chainLightning => () ->
		{
			var skill = skillFromData(kiwi, chainLightning);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				// BUG: can target a dead character;
				// var sound = some shock sound;
				for (i in 0...3)
				{
					var target = context.getRandomTarget(ENEMY);
					var fastHitAnim = SkillAnimations.getFastHitAnim();
					SkillAnimations.genericAttackPlay(skill.value, fastHitAnim)([target], owner, context);
				}
			}
			skill.spritePath = kiwiPlaceholder;
			return skill;
		}
	];

	public static var kiwiSkillsRare = [
		fullyPrepared => () ->
		{
			var skill = skillFromData(kiwi, fullyPrepared);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				if (owner.hasStatus(DODGE) > 0)
					SkillAnimations.genericBlockPlay(skill.value)(targets, owner, context);
			}
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
	];

	public static var ryderSkills:CharSkillList = [
		BASIC => ryderSkillsBasic,
		COMMON => ryderSkillsCommon,
		UNCOMMON => ryderSkillsUncommon,
		RARE => ryderSkillsRare,
	];

	public static var kiwiSkills:CharSkillList = [
		BASIC => kiwiSkillsBasic,
		COMMON => kiwiSkillsCommon,
		UNCOMMON => kiwiSkillsUncommon,
		RARE => kiwiSkillsRare,
	];

	public static var charNameToSkillListMap = ['Ryder' => ryderSkills, 'Kiwi' => kiwiSkills];

	/** return an array of SkillBlueprints, which will get you the Skill when called. **/
	public static function getSkillBlueprints(charName:String = 'Ryder', rarity:SkillData_skills_rarity = BASIC)
	{
		var skillsToRetrieve = charNameToSkillListMap.get(charName).get(rarity);
		var skillsToReturn = new Array<SkillBlueprint>();
		for (skill in skillsToRetrieve)
		{
			skillsToReturn.push(skill);
		}
		return skillsToReturn;
	}
}
