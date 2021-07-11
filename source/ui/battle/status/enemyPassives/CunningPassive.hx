package ui.battle.status.enemyPassives;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class CunningPassive extends Status
{
	override public function onPlayerStartTurn(context:BattleContext)
	{
		// apply carryover to all wisdom cards in the deck every turn.
		// slow? Shouldn't be that bad. Switch this to OnDraw when thats implemented.
		var cards = context.eDeck.getCardsInDeck();
		for (card in cards)
		{
			if (card.name == 'Wisdom')
				card.carryOver = true;
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: CUNNING,
			name: 'Cunning',
			desc: 'Rattle doesn\'t discard Wisdom cards at the end of her turn.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: false,
		}

		super(owner, info, initialStacks);
	}
}
