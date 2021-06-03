package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class CunningPassive extends Status
{
	override public function onEnemyEndTurn(context:BattleContext)
	{
		// apply carryover to all wisdom cards
		var cards = context.eDeck.getCardsInHand();
		for (card in cards)
		{
			if (card.name == 'Wisdom')
				card.carryOver = true;
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = CUNNING;
		name = 'Cunning';
		var desc = 'Rattle doesn\'t discard Wisdom cards at the end of her turn.';
		var options:IndicatorIconOptions = {
			outlined: true,
			display: false, // this status doesnt have stacks, so dont show a number.
		};
		var icon = new IndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
