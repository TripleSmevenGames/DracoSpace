package ui.battle.status;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

/** A decaying status loses 1 stack at the end of the owner's turn.**/
class DecayingStatus extends Status
{
	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
			stacks -= 1;
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
			stacks -= 1;
	}

	public function new(owner:CharacterSprite, icon:BattleIndicatorIcon, initialStacks:Int = 1)
	{
		super(owner, icon);
		stacks = initialStacks;
	}
}
