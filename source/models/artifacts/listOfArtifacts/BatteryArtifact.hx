package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class BatteryArtifact extends Artifact
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		if (context.turnCounter == 1)
			owner.addStatus(STATIC, 1);
	}

	public function new()
	{
		var name = 'Battery';
		var desc = 'Start each battle with 1 Static.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
