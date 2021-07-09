package ui.battle.status.genericStatuses;

import managers.BattleManager;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import ui.battle.combatUI.SkillSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class ColdStatus extends DebuffStatus
{
	override public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		var deck:DeckSprite = null;
		if (owner.info.type == ENEMY)
			deck = context.eDeck;
		else if (owner.info.type == PLAYER)
			deck = context.pDeck;

		if (deck != null)
		{
			deck.discardLeftmostCard();
			stacks -= 1;
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: COLD,
			name: 'Cold',
			desc: 'Whenever ${owner.info.name} plays a skill, they discard a card.' + '\n\nLose 1 stack at the end of turn.',
			iconPath: AssetPaths.Cold1__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
