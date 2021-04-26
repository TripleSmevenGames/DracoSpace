package models.skills;

import Castle;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Exception;
import models.skills.Skill.Effect;
import models.skills.Skill.SkillPointCombination;
import models.skills.SkillAnimations;
import models.skills.SkillFactory.SkillList;
import ui.battle.SpriteAnimsLayer;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.BattleAnimationManager.BattleAnimationGroupOptions;
import utils.BattleManager;
import utils.GameController;
import utils.battleManagerUtils.BattleContext;

@:access(models.skills.SkillFactory)
@:access(models.skills.Skill)
class SkillFactoryRattle
{
	static var skillFromData = SkillFactory.skillFromData;
	static var gazeAnimSprite:FlxSprite;

	// the sprite sheet for rattle's gaze attack is pretty big
	// so lets save it here
	public static function init()
	{
		gazeAnimSprite = SpriteAnimsLayer.createScreenAnim(AssetPaths.rattlesGaze600x400x70__png, 70);
	}

	public static var rattleSkills:SkillList = [
		rattlesGaze => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, rattlesGaze, priority);
			if (gazeAnimSprite == null)
			{
				init();
			}
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				target.addStatus(STUN);
			}
			skill.play = SkillAnimations.screenAnimPlay(effect, gazeAnimSprite, 45);
			skill.spritePath = AssetPaths.rattlesGaze__png;
			return skill;
		},
		snakeFangs => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, snakeFangs, priority);
			var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
			{
				var beforeHp = target.currHp;
				owner.dealDamageTo(skill.value, target, context);
				if (target.currHp < beforeHp)
				{
					context.eDeck.drawCards(skill.value2);
				}
			}
			skill.play = (targets:Array<CharacterSprite>, owner:CharacterSprite, context:BattleContext) ->
			{
				var animSprite = SkillAnimations.getHitAnim();
				SkillAnimations.getCustomPlay(animSprite, effect)(targets, owner, context);
			}
			skill.spritePath = AssetPaths.snakeFangs__png;
			return skill;
		},
		crossCutter => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, crossCutter, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.crossCutter__png;
			return skill;
		},
	];
}
