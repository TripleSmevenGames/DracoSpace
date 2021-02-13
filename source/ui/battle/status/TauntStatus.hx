package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;

// taunts usage is defined in BattleManager's target state.
class TauntStatus extends DecayingStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = TAUNT;
		name = 'Taunt';
		var desc = 'Enemies will target this character if able. Lose 1 stack at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Taunt1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
