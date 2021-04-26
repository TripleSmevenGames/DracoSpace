package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;

// Dummy status, the actual effect of lowering the draw should be done by the skill, from calling deckSprite.drawModifier.
class PlusDraw extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Draw an extra $valAfter card(s) next turn.');
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = PLUSDRAW;
		name = '+ Draw';
		var desc = 'Draw an extra $initialStacks card(s) next turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.plusDraw__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
