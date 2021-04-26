package models.skills;

import Castle;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Exception;
import models.skills.Skill.Effect;
import models.skills.Skill.SkillPointCombination;
import models.skills.SkillAnimations;
import models.skills.SkillFactory.SkillList;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

@:access(models.skills.SkillFactory)
@:access(models.skills.Skill)
class SkillFactoryEnemy
{
	static var skillFromData = SkillFactory.skillFromData;

	public static var enemySkills:SkillList = [
		dummy => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, dummy, priority);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.trainingDummySkill__png;
			return skill;
		},
		tackle => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, tackle, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.slimeTackle__png;
			return skill;
		},
		houndBite => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, houndBite, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		houndRam => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, houndRam, priority);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericAttackPlay(skill.value)(targets, owner, context);
				SkillAnimations.genericBlockPlay(skill.value2)([owner], owner, context);
			}
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		cower => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, cower, priority);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		laserBolt => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, laserBolt, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		laserBlast => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, laserBlast, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		howl => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, howl, priority);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(ATTACK);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		selfDestruct => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, selfDestruct, priority);
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var explosionAnim = SkillAnimations.getSmallBlueExplosionAnim();
				var sound = FlxG.sound.load(AssetPaths.smallExplosion1__wav);
				SkillAnimations.genericAttackPlay(skill.value2, explosionAnim, sound)(targets, owner, context);
				SkillAnimations.genericAttackPlay(skill.value, explosionAnim, sound)([owner], owner, context); // hit self
			};
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		spook => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, spook, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		giveLife => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, giveLife, priority);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.takeDamage(skill.value, owner, context);
				target.addStatus(ATTACK);
			}
			skill.play = SkillAnimations.genericBuffPlay(effect);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		hotHands => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, hotHands, priority);
			var animSprite = SkillAnimations.getHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				owner.dealDamageTo(skill.value, target, context);
				target.addStatus(BURN, skill.value2);
			}
			skill.play = SkillAnimations.getCustomPlay(animSprite, effect);
			skill.spritePath = AssetPaths.hotHands__png;
			return skill;
		},
		flameShield => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, flameShield, priority);
			var animSprite = SkillAnimations.getFastHitAnim();
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(BURN, skill.value2);
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				SkillAnimations.genericBlockPlay(skill.value)([owner], owner, context);
				SkillAnimations.getCustomPlay(animSprite, effect)(targets, owner, context);
			};
			skill.spritePath = AssetPaths.flameShield__png;
			return skill;
		},
		golemSmash => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, golemSmash, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		petalShield => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, petalShield, priority);
			skill.play = SkillAnimations.genericBlockPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		petalBlade => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, petalBlade, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
	];
}
