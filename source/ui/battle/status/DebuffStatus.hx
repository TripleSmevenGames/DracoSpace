package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

/** A debuff status loses 1 stack at the end of the owner's turn.**/
class DebuffStatus extends Status
{
	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
			stacks -= 1;
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
			stacks -= 1;
	}

	public function new(owner:CharacterSprite, info:StatusInfo, initialStacks:Int = 1)
	{
		super(owner, info, initialStacks);
	}
}
