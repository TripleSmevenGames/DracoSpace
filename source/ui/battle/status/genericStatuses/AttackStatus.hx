package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

/** usage is defined in characterSprite's dealDamage**/
class AttackStatus extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s skills deal $valAfter more damage');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: ATTACK,
			name: 'Attack Up',
			desc: '${owner.info.name}\'s skills deal $initialStacks more damage.',
			iconPath: AssetPaths.Attack1__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
