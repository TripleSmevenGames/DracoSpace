package ui.battle.status;

import ui.battle.character.CharacterSprite;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import utils.battleManagerUtils.BattleContext;

class RegenerateStatus extends Status
{
	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
		{
			owner.healHp(stacks);
		}
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
		{
			owner.healHp(stacks);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = REGENERATE;
		name = 'Regenerate';
		var desc = 'At the end of turn, heal $initialStacks hp.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Burn1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
