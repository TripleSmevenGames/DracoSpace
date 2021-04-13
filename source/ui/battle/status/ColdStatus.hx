package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import utils.BattleManager;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class ColdStatus extends DecayingStatus
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
		type = COLD;
		name = 'Cold';
		var desc = 'Whenever this character plays a skill, they discard a card.' + '\n\nLose 1 stack at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
