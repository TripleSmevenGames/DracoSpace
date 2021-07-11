package ui.battle.status.skillSpecific;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class RepositionStatus extends OneTurnStatus
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		owner.addStatus(DODGE, 1);
		super.onPlayerStartTurn(context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: REPOSITION,
			name: 'Reposition',
			desc: 'Next turn, gain 1 Dodge.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: false,
		};

		super(owner, info, initialStacks);
	}
}
