package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;

// Exhaust usage is defined in onDraw somewhere
class ExhaustStatus extends DecayingStatus
{
	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = EXHAUST;
		name = 'Exhaust';
		var desc = 'Lose 1 Draw for each stack. Lose 1 stack at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Dodge2__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
