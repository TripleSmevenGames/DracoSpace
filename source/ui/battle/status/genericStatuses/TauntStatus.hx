package ui.battle.status.genericStatuses;

import managers.BattleManager;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

// taunts usage is defined in EnemyIntentMaker's logic.
class TauntStatus extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Enemies are more likely to target ${owner.info.name} for the next $stacks turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: TAUNT,
			name: 'Taunt',
			desc: 'Enemies are more likely to target ${owner.info.name} for the next $initialStacks turn(s).',
			iconPath: AssetPaths.Taunt1__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
