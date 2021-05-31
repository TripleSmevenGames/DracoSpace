package models.artifacts.listOfArtifacts;

import models.skills.SkillAnimations;
import utils.battleManagerUtils.BattleContext;

class EmergencyShieldsArtifact extends Artifact
{
	static inline final VALUE = 3;

	override public function onPlayerEndTurn(context:BattleContext)
	{
		var percentHp = owner.currHp / owner.maxHp;
		if (percentHp < .5)
		{
			SkillAnimations.genericBlockPlay(VALUE)([owner], owner, context);
		}
	}

	public function new()
	{
		var name = 'Emergency Shields';
		var desc = 'When ending the turn at 50% hp or less, gain $VALUE Block.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
