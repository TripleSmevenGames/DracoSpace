package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class RegenerateStatus extends Status
{
	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
		{
			owner.healHp(stacks);
		}
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
		{
			owner.healHp(stacks);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: REGENERATE,
			name: 'Regenerate',
			desc: 'At the end of turn, heal $initialStacks hp.',
			iconPath: AssetPaths.Burn1__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
