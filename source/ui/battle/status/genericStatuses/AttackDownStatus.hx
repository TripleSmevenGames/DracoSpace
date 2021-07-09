package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

/** usage is defined in characterSprite's dealDamage**/
class AttackDownStatus extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s skills deal $valAfter less damage');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: ATTACKDOWN,
			name: 'Attack Down',
			desc: '${owner.info.name}\'s skills deal $initialStacks less damage.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
