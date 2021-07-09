package ui.battle.status.enemyPassives;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;

class UnstablePassive extends DebuffStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 10)
	{
		var info:StatusInfo = {
			type: UNSTABLE,
			name: 'Unstable Down',
			desc: 'If ${owner.info.name} starts its turn below 50% hp, it will explode, dealing $initialStacks damage to all enemies. When killed by an' +
			' enemy, it will deal $initialStacks damage to all allies instead.',
			iconPath: AssetPaths.Dodge2__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
