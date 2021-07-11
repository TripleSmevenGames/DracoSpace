package ui.battle.status.skillSpecific;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class HoloBarrierStatus extends OneTurnStatus
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		owner.gainBlock(stacks, context);
		super.onPlayerStartTurn(context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: HOLOBARRIER,
			name: 'Holo-Barrier',
			desc: 'Next turn, gain $initialStacks Block.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
