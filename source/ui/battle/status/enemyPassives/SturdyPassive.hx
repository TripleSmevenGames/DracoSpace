package ui.battle.status.enemyPassives;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

/** usage is defined in characterSprite's onTakeDamage**/
class SturdyPassive extends Status
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('${owner.info.name} takes $valAfter less damage from all sources.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: STURDY,
			name: 'Sturdy',
			desc: '${owner.info.name} takes $initialStacks less damage from all sources.',
			iconPath: AssetPaths.sturdy__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
