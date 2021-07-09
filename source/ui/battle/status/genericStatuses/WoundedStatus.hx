package ui.battle.status.genericStatuses;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

/** usage is defined in characterSprite's dealDamage**/
class WoundedStatus extends DebuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name}\'s takes 50% more damage from enemy skills for $valAfter turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: WOUNDED,
			name: 'Wounded',
			desc: '${owner.info.name}\'s takes more 50% damage from enemy skills for $initialStacks turn(s).',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
