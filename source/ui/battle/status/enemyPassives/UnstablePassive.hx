package ui.battle.status.enemyPassives;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;

class UnstablePassive extends DebuffStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 10)
	{
		type = UNSTABLE;
		name = 'Unstable';
		var desc = 'If ${owner.info.name} starts its turn below 50% hp, it will explode, dealing $initialStacks damage to all enemies. When killed by an '
			+ ' enemy, it will deal $initialStacks damage to all allies instead.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
