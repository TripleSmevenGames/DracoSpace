package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

class CounterStatus extends Status
{
	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
			stacks -= 0;
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
			stacks -= 0;
	}

	override public function onTakeDamage(damage:Int, context:BattleContext, dealer:CharacterSprite)
	{
		owner.dealDamageTo(dealer, stacks, {}, context);
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
