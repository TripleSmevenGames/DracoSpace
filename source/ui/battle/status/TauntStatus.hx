package ui.battle.status;

import managers.BattleManager;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

// taunts usage is defined in EnemyIntentMaker's logic.
class TauntStatus extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Enemies are more likely to target ${owner.info.name} for the next $stacks turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = TAUNT;
		name = 'Taunt';
		var desc = 'Enemies are more likely to target ${owner.info.name} for the next $initialStacks turn(s).';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Taunt1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
