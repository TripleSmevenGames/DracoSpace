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
import models.skills.SkillFactory.SkillList;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.battleManagerUtils.BattleContext;

@:access(models.skills.SkillFactory)
@:access(models.skills.Skill)
class SkillFactoryPin
{
	static var skillFromData = SkillFactory.skillFromData;

	public static var pinSkills:SkillList = [
		summonK9 => (?priority:Int) ->
		{
			var skill = skillFromData(pin, summonK9, priority);
			skill.play = null;
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		commandGuard => (?priority:Int) ->
		{
			var skill = skillFromData(pin, commandGuard, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		// this skill is for his dogs
		commandAttack => (?priority:Int) ->
		{
			var skill = skillFromData(pin, commandAttack, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		}
	];
}
