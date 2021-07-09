package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import ui.battle.status.Status.StatusInfo;

/** usage is defined in characterSprite's dealDamage**/
class WeakStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s skills deal 50% less damage for $valAfter turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: WEAK,
			name: 'Weak',
			desc: '${owner.info.name}\'s skills deal 50% less damage for $initialStacks turn(s).',
			iconPath: AssetPaths.Burn1__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
