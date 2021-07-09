package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

// Dummy status, the actual effect of lowering the draw should be done by the skill, from calling deckSprite.drawModifier.
class MinusDraw extends Status
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
		var info:StatusInfo = {
			type: MINUSDRAW,
			name: '- Draw',
			desc: 'Draw $initialStacks fewer card(s) next turn.',
			iconPath: AssetPaths.minusDraw__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
