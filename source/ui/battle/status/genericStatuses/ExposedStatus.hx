package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

// Exposed usage is defined in onGainBlock somewhere
class ExposedStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('For the next $valAfter turn(s), ${owner.info.name} gains 50% less Block.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: EXPOSED,
			name: 'Exposed',
			desc: 'For the next $initialStacks turn(s), ${owner.info.name} gains 50% less Block.',
			iconPath: AssetPaths.Dodge2__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
