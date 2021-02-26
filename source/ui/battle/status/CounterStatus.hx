package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

class CounterStatus extends Status
{
	override public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		// prevent countering self damage.
		if (dealer != owner)
		{
			owner.dealDamageTo(stacks, dealer, context);
			stacks = 0;
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = COUNTER;
		name = 'Counter';

		var desc = 'This turn, this character deals X damage back to attackers.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Static1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
