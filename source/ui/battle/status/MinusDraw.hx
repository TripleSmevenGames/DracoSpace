package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;

// Dummy status, the actual effect of lowering the draw should be done by the skill, from calling deckSprite.drawModifier.
class MinusDraw extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Draw  $valAfter fewer card(s) next turn.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = MINUSDRAW;
		name = '- Draw';
		var desc = 'Draw $initialStacks fewer card(s) next turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.minusDraw__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
