package models.artifacts.listOfArtifacts;

import ui.battle.combatUI.SkillSprite;
import utils.battleManagerUtils.BattleContext;

class BootsArtifact extends Artifact
{
	/** This is called BEFORE The skill's play() is called, but after the skill has been "counted" for skills played this turn. **/
	override public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		if (skillSprite.owner.skillsPlayedThisTurn == 3)
			owner.addStatus(DODGE, 1);
	}

	public function new()
	{
		var name = 'Boots of Cool';
		var desc = 'After playing 3 skills in a turn, gain 1 Dodge.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
