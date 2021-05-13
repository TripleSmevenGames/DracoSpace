package ui.battle.status.enemyPassives;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;

class UnstablePassive extends DecayingStatus
{
	static inline final damage = 10;

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = UNSTABLE;
		name = 'Unstable';
		var desc = 'If this character starts its turn below 30% hp, it will explode, dealing $damage damage to all enemies. When killed by an '
			+ ' enemy, it will deal $damage damage to all allies instead.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		stackable = false;

		super(owner, icon, initialStacks);
	}
}
