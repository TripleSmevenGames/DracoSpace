package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class EnergyBarArtifact extends Artifact
{
	override public function onPlayerEndTurn(context:BattleContext)
	{
		if (context.turnCounter == 2) // this is the second turn, so the next turn will be the third turn and we will draw the extra card.
			context.pDeck.drawModifier += 1;
	}

	public function new()
	{
		var name = 'Energy Bar';
		var desc = 'On the third turn of battle, draw an additional card.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
