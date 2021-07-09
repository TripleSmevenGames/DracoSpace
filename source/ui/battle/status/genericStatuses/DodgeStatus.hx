package ui.battle.status.genericStatuses;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

// Dodge usage is defined in CharacterSprite's takeDamage.
class DodgeStatus extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Evade the next $valAfter attack(s). Lose 1 stack per turn.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: DODGE,
			name: 'Dodge',
			desc: 'Evade the next $initialStacks attack(s). Lose 1 stack per turn.',
			iconPath: AssetPaths.Dodge2__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
