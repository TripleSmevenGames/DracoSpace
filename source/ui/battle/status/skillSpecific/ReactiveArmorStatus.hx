package ui.battle.status.skillSpecific;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class ReactiveArmorStatus extends OneTurnStatus
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		owner.addStatus(COUNTER, stacks);
		super.onPlayerStartTurn(context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: REACTIVEARMOR,
			name: 'Reactive Armor',
			desc: 'Next turn, gain $initialStacks Counter.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}