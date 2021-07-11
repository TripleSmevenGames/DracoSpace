package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class RedBannerArtifact extends Artifact
{
	static inline final value = 3;

	override public function onPlayerStartTurn(context:BattleContext)
	{
		if (context.turnCounter == 1)
			owner.addStatus(TAUNT, value);
	}

	public function new()
	{
		var name = 'Red Banner';
		var desc = 'Start each battle with $value Taunt.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
