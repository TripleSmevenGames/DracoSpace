package ui.battle.status;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

// Dummy status, the actual effect of lowering the draw should be done by the skill, from calling deckSprite.drawModifier.
class MinusDraw extends BuffStatus
{
	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('Draw  $valAfter fewer card(s) next turn.');
	}

	// affect only lasts 1 turn, so remove from owner at the start of the round
	override public function onPlayerStartTurn(context:BattleContext)
	{
		removeFromOwner();
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = MINUSDRAW;
		name = '- Draw';
		var desc = 'Draw $initialStacks fewer card(s) next turn.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.minusDraw__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
