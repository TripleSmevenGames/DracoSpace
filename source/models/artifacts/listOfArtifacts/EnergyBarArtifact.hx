package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class EnergyBarArtifact extends Artifact
{
	override public function onPlayerEndTurn(context:BattleContext)
	{
		// We want to draw the extra card on the start of the third turn.
		// So we should add to the player deck's drawModifier at the end of the player's SECOND turn.
		if (context.turnCounter == 2)
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
