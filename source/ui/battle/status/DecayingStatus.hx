package ui.battle.status;

import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

/** A decaying status loses 1 stack at the end of the owner's turn.**/
class DecayingStatus extends Status
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

	public function new(owner:CharacterSprite, icon:IndicatorIcon, initialStacks:Int = 1)
	{
		super(owner, icon);
		stacks = initialStacks;
	}
}
