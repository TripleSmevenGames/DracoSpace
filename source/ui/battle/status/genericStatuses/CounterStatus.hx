package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class CounterStatus extends Status
{
	// counter back the damage. Test: killing an enemy with counter damage.
	override public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		// prevent countering self damage.
		if (dealer != owner)
		{
			owner.dealDamageTo(stacks, dealer, context);
			stacks = 0;
		}
	}

	override public function onPlayerStartTurn(context:BattleContext)
	{
		removeFromOwner();
	}

	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('This turn, ${owner.info.name} deals $valAfter damage back to attackers.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: COUNTER,
			name: 'Counter',
			desc: 'This turn, ${owner.info.name} deals $initialStacks damage back to attackers.',
			iconPath: AssetPaths.Static1__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
