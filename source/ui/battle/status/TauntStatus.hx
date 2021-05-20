package ui.battle.status;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;

// taunts usage is defined in BattleManager's target state.
class TauntStatus extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Enemies are more likely to target this character for the next $stacks turn(s).');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = TAUNT;
		name = 'Taunt';
		var desc = 'Enemies are more likely to target this character for the next $initialStacks turn(s).';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Taunt1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
