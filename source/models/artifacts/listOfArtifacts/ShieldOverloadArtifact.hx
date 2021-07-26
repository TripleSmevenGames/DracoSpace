package models.artifacts.listOfArtifacts;

import utils.battleManagerUtils.BattleContext;

class ShieldOverloadArtifact extends Artifact
{
	static final blockNeeded = 20;
	static final damageDealt = 10;

	override public function onGainBlock(block:Int, context:BattleContext)
	{
		if (owner.currBlock >= blockNeeded)
		{
			for (char in context.getAliveEnemies())
			{
				owner.dealDamageTo(damageDealt, char, context);
			}
		}
	}

	public function new()
	{
		var name = 'Shield Overload';
		var desc = 'If gain ${blockNeeded} in one turn, deals ${damageDealt} to all enemies.';
		var assetPath = AssetPaths.artifactPlaceholder__png;
		super(name, desc, assetPath);
	}
}
