package ui.battle.status.enemyPassives;

import models.CharacterInfo.CharacterType;
import models.cards.Card;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class CunningPassive extends Status
{
	override public function onDrawCard(card:Card, type:CharacterType, context:BattleContext)
	{
		if (card.name == 'Wisdom' && type == ENEMY)
		{
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
