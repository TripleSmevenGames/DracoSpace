package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class RedBannerArtifact extends Artifact
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		if (context.turnCounter == 1)
			owner.addStatus(TAUNT, 1);
	}

	public function new()
	{
		var name = 'Red Banner';
		var desc = 'Start each battle with 1 Taunt.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
