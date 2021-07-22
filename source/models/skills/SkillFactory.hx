package models.skills;

import Castle;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Exception;
import managers.BattleAnimationManager.BattleAnimationGroupOptions;
import managers.BattleManager;
import managers.GameController;
import models.skills.Skill.Effect;
import models.skills.Skill.SkillPointCombination;
import models.skills.SkillAnimations;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.battleManagerUtils.BattleContext;

using utils.GameUtils;

typedef SPC = SkillPointCombination;
typedef SkillBlueprint = ?Int->Skill;
typedef SkillList = Map<SkillData_skillsKind, SkillBlueprint>;
typedef CharSkillList = Map<SkillData_skills_rarity, SkillList>;

/** Use this to create skills. **/
@:access(models.skills.Skill)
class SkillFactory
{
	public static final ryderPlaceholder = AssetPaths.ryderSkill__png;
	public static final kiwiPlaceholder = AssetPaths.kiwiSkill__png;

	public static var enemySkills:SkillList = [];

	public static function init()
	{
		var dbPath = haxe.Resource.getString(AssetPaths.skillData__cdb);
		Castle.load(dbPath);

		enemySkills = SkillFactoryEnemy.enemySkills;
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

	static function skillFromData(category:SkillDataKind, skillId:SkillData_skillsKind, ?priority:Int = 0):Skill
	{
		var skill = new Skill(get(category, skillId));
		skill.category = category;
		skill.priority = priority;
		return skill;
	}

	public static var genericSkills:SkillList = [
		watch => (?priority:Int) ->
		{
			var skill = skillFromData(generic, watch);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.eDeck.revealCards(skill.value);
				context.pDeck.drawCards(1, null, 0, context);
			}
			skill.spritePath = AssetPaths.watch1__png;
			return skill;
		},
		patience => (?priority:Int) ->
		{
			var skill = skillFromData(generic, patience);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.carryOverAll();
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		expertise => (?priority:Int) ->
		{
			var skill = skillFromData(generic, expertise);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.drawCards(2, owner, 0, context);
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
	];

	public static var ryderSkillsBasic = [
		bash => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, bash);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.bash__png;
			return skill;
		},
		protect => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, protect);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.protect__png;
			return skill;
		},
	];

	public static var ryderSkillsCommon:SkillList = [
		distract => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, distract);
			var extraEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(TAUNT, skill.value2);
			}
			skill.play = SkillAnimations.genericBlockPlay(skill.value, extraEffect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		aggravate => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, aggravate);
			var extraEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(TAUNT, skill.value2);
			};
			skill.play = SkillAnimations.genericAttackPlay(skill.value, null, 0, null, extraEffect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		riposte => (?priority:Int) ->
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
		bladeDance => (?priority:Int) ->
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
		adrenaline => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, adrenaline);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.payHealth(skill.value, context);
				target.addStatus(ATTACK, skill.value2);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.adrenaline__png;
			return skill;
		},
		wideSwing => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, wideSwing);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.wideSwing2__png;
			return skill;
		},
		flurry => (?priority:Int) ->
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
		crush => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, crush);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var animSprite = SkillAnimations.getFastHitAnim();
				SkillAnimations.genericAttackPlay(skill.value, animSprite)(targets, owner, context);
				if (targets[0].currBlock >= skill.value)
				{
					SkillAnimations.genericAttackPlay(skill.value, animSprite)(targets, owner, context);
				}
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		recklessSwing => (?priority:Int) ->
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
		unyielding => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, unyielding);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];
	public static var ryderSkillsUncommon:SkillList = [
		riskyManeuver => (?priority:Int) -> // todo
		{
			var skill = skillFromData(ryder, riskyManeuver);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.payHealth(skill.value, context);
				context.pDeck.drawCards(2, null, 0, context);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		hideBreaker => (?_) ->
		{
			var skill = skillFromData(ryder, steadfast);
			var extraEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(HIDEBREAKER);
			};
			skill.play = SkillAnimations.genericAttackPlay(skill.value, null, 0, null, extraEffect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		steadfast => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, steadfast);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericBlockPlay(skill.value)(targets, owner, context);
				context.pDeck.drawCards(1, null, 0, context);
			};
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		reactiveArmor => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, reactiveArmor);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(COUNTER, skill.value);
				owner.addStatus(REACTIVEARMOR, skill.value2);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		staticAura => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, staticAura);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				// this will remove all static from characters and return you the total removed.
				var numStatic = context.expendAllStatic();
				owner.addStatus(COUNTER, skill.value * numStatic);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		whirlwindSwing => (?_) ->
		{
			var skill = skillFromData(ryder, whirlwindSwing);
			var animSprite = SkillAnimations.getHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				var numSwings = owner.info.getNumSwingSkills();
				var damage = skill.value * numSwings;
				owner.dealDamageTo(damage, target, context);
			};
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		blitzAttack => (?_) ->
		{
			var skill = skillFromData(ryder, blitzAttack);
			var extraEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(ATTACK, skill.value2);
			};
			skill.play = SkillAnimations.genericAttackPlay(skill.value, null, 0, null, extraEffect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		holoBarrier => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, holoBarrier);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.gainBlock(skill.value, context);
				owner.addStatus(HOLOBARRIER, skill.value2);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
	];

	public static var ryderSkillsRare:SkillList = [
		revenge => (?priority:Int) ->
		{
			var skill = skillFromData(ryder, revenge);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var damage = (owner.maxHp - owner.currHp) * 2;
				SkillAnimations.genericAttackPlay(damage)(targets, owner, context);
			}
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		brawl => (?_) ->
		{
			var skill = skillFromData(ryder, brawl);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				context.pDeck.discardHand();
				context.eDeck.discardHand();
			};
			skill.spritePath = ryderPlaceholder;
			return skill;
		},
		// todo
		// conductive => (?_) -> {}
		champion => (?_) ->
		{
			var skill = skillFromData(ryder, champion);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(TAUNT, skill.value);
				var currAttack = owner.getStatus(ATTACK);
				if (currAttack > 0)
					owner.addStatus(ATTACK, currAttack);
			};
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = ryderPlaceholder;
			return skill;
		}
	];

	public static var kiwiSkillsBasic = [
		shuriken => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, shuriken);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.shuriken__png;
			return skill;
		},
	];

	public static var kiwiSkillsCommon = [
		smokeBomb => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, smokeBomb);
			// var animeSprite = get some smoke animation
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(DODGE);
				owner.addStatus(MINUSDRAW);
				context.pDeck.drawModifier -= 1;
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			return skill;
		},
		parry => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, parry);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.gainBlock(skill.value, context);
				owner.addStatus(PLUSDRAW);
				context.pDeck.drawModifier += 1;
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			return skill;
		},
		staticShield => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, staticShield);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(STATICSHIELD, skill.value2);
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericBlockPlay(skill.value)(targets, owner, context);
				SkillAnimations.genericBuffPlay(effect)(targets, owner, context);
			}
			skill.spritePath = AssetPaths.swipe__png;
			return skill;
		},
		surgingFist => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, surgingFist);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(STATIC, skill.value2);
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				SkillAnimations.genericBuffPlay(effect)([owner], owner, context);
			}
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		shockShield => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, shockShield);
			var animSprite = SkillAnimations.getBlockAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.gainBlock(context.expendAllStatic(), context);
			}
			var effectFrame = 10;
			var sound = AssetPaths.gainBlock1__wav;
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect, effectFrame, sound);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		swordCutter => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, swordCutter);
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
		disarm => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, disarm);
			var animSprite:FlxSprite = SkillAnimations.getHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				if (target.currBlock == 0)
				{
					owner.dealDamageTo(skill.value, target, context);
					context.eDeck.discardLeftmostCard();
				}
				else
				{
					owner.dealDamageTo(0, target, context);
				}
			};
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect);
			skill.spritePath = AssetPaths.disarm__png;
			return skill;
		},
		charge => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, charge);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(STATIC, skill.value);
				context.pDeck.drawCards(1, null, 0, context);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		blindThrow => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, blindThrow);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.blindThrow__png;
			return skill;
		},
		endlessShuriken => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, endlessShuriken);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.endlessShuriken__png;
			return skill;
		},
		cripple => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, cripple);
			var extraEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) -> target.addStatus(WEAK);
			skill.play = SkillAnimations.genericAttackPlay(skill.value, null, 0, null, extraEffect);
			skill.spritePath = AssetPaths.shuriken__png;
			return skill;
		},
	];

	public static var kiwiSkillsUncommon = [
		// sabatoge => (?priority:Int) -> {},
		chainLightning => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, chainLightning);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				// todo BUG: can target a dead character;
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
		},
		freeRunning => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, freeRunning);
			var getDodgeEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.addStatus(DODGE, 1);
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				// don't count this skill
				for (i in 0...owner.skillsPlayedThisTurn - 1)
				{
					var fastHitAnim = SkillAnimations.getFastHitAnim();
					SkillAnimations.genericAttackPlay(skill.value, fastHitAnim)(targets, owner, context);
					SkillAnimations.genericBuffPlay(getDodgeEffect)([owner], owner, context);
				}
			};
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		followUp => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, followUp);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				var followUpEffect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
				{
					// get last skill (ie left most skill);
					var skill = owner.skillSprites[owner.skillSprites.length - 1];
					if (skill.cooldownTimer > 0)
					{
						skill.cooldownTimer -= 1;
						return;
					}
				};
				SkillAnimations.genericBuffPlay(followUpEffect)([owner], owner, context);
			};
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		dodgeRoll => (?priority:Int) ->
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
		reposition => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, reposition);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(REPOSITION);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		}
	];

	public static var kiwiSkillsRare = [
		fullyPrepared => (?priority:Int) ->
		{
			var skill = skillFromData(kiwi, fullyPrepared);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				if (owner.getStatus(DODGE) > 0)
					SkillAnimations.genericBlockPlay(skill.value)(targets, owner, context);
				else
				{
					var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) -> owner.addStatus(DODGE, 2);
					SkillAnimations.genericBuffPlay(effect)(targets, owner, context);
				}
			}
			skill.spritePath = kiwiPlaceholder;
			return skill;
		},
		rewind => (?_) ->
		{
			var skill = skillFromData(kiwi, rewind);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				for (skill in target.skillSprites)
				{
					skill.cooldownTimer = 0;
				}
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = kiwiPlaceholder;
			return skill;
		}
		// ultimateHeist => (?_) -> {}
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

	/** return an array of SkillBlueprints for this character and rarity, which will get you the Skill when called.
	 * Best used to create a pool of skills to grab from. You can call getSkillBlueprints().randomChoice() to grab random skill.
	**/
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
