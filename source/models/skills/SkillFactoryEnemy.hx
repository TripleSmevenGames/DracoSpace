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
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		bite => (?priority:Int) ->
		{
			var skill = skillFromData(enemy, bite, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
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
	];
}
