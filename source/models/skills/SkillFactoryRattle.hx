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
class SkillFactoryRattle
{
	static var skillFromData = SkillFactory.skillFromData;

	public static var rattleSkills:SkillList = [
		rattlesGaze => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, rattlesGaze, priority);
			skill.play = null;
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		snakeFangs => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, snakeFangs, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
		crossCutter => (?priority:Int) ->
		{
			var skill = skillFromData(rattle, crossCutter, priority);
			skill.play = SkillAnimations.genericAttackPlay(skill.value);
			skill.spritePath = AssetPaths.emptySkill__png;
			return skill;
		},
	];
}
