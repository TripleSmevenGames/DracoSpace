package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

/** A buff status loses 1 stack at the start of the owner's turn.**/
class BuffStatus extends Status
{
	override function onPlayerStartTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
			stacks -= 1;
	}

	override function onEnemyStartTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
			stacks -= 1;
	}

	public function new(owner:CharacterSprite, info:StatusInfo, initialStacks:Int = 1)
	{
		super(owner, info, initialStacks);
	}
}
