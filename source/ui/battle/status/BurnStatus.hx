package ui.battle.status;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class BurnStatus extends DebuffStatus
{
	var sounds:Array<FlxSound> = [];

	function getSound()
	{
		var random = new FlxRandom();
		return sounds[random.int(0, sounds.length - 1)];
	}

	override public function onSetStacks(valBefore:Int, valAfter:Int)
	{
		updateTooltip('At the end of turn, take $valAfter damage and lose 1 stack.');
	}

	override function onPlayerEndTurn(context:BattleContext)
	{
		if (owner.info.type == PLAYER)
		{
			owner.takeDamage(stacks, owner, context);
			getSound().play();
		}
		super.onPlayerEndTurn(context); // decay the stacks
	}

	override function onEnemyEndTurn(context:BattleContext)
	{
		if (owner.info.type == ENEMY)
		{
			owner.takeDamage(stacks, owner, context);
			getSound().play();
		}
		super.onEnemyEndTurn(context); // decay the stacks
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = BURN;
		name = 'Burn';
		var desc = 'At the end of turn, take $initialStacks damage and lose 1 stack.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Burn1__png, name, desc, options);

		sounds.push(FlxG.sound.load(AssetPaths.burn1__wav));
		sounds.push(FlxG.sound.load(AssetPaths.burn2__wav));

		super(owner, icon, initialStacks);
	}
}
