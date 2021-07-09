package ui.battle.status.skillSpecific;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

// Real usage is defined in onGainBlock
class HideBreakerStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('For the next $valAfter turn(s), ${owner.info.name} can\'t gain block.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: HIDEBREAKER,
			name: 'Hide Breaker',
			desc: 'For the next $initialStacks turn(s), ${owner.info.name} can\'t gain block.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
