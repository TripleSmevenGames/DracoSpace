package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import utils.ViewUtils;

class AttackStatus extends Status
{
	override public function onDealDamage(originalDamage:Int)
	{
		super.onDealDamage(originalDamage);
		return originalDamage + 1;
	}

	public function new(owner:CharacterSprite)
	{
		type = ATTACK;
		name = 'Attack';
		var desc = 'This character\'s skills deal X more damage.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Attack1__png, name, desc, options);

		super(owner, icon);
	}
}
