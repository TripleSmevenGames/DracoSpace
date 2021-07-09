package ui.battle.status.genericStatuses;

import managers.BattleManager;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

// stun usage is defined in skillSprite/status display.
class StunStatus extends DebuffStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: STUN,
			name: 'Stun',
			desc: 'All skills are disabled this turn. Lose 1 stack at the end of turn.',
			iconPath: AssetPaths.Taunt1__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
