package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

/** A self-inflicted status that only lasts one turn**/
class OneTurnStatus extends Status
{
	override function onPlayerStartTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
			removeFromOwner();
	}

	override function onEnemyStartTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
			removeFromOwner();
	}

	public function new(owner:CharacterSprite, info:StatusInfo, initialStacks:Int = 1)
	{
		super(owner, info, initialStacks);
	}
}
