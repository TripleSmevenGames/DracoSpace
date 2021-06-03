package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class DyingWishPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var attackValue = owner.getStatus(ATTACK);
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			target.addStatus(ATTACK, attackValue);
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)(context.getAliveEnemies(), this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = DYINGWISH;
		name = 'Dying Wish';
		var desc = 'When ${owner.info.name} dies, all allies gain ${owner.info.name}\'s Attack.';
		var options:IndicatorIconOptions = {
			outlined: true,
			display: false, // this status doesnt have stacks, so dont show a number.
		};
		var icon = new IndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
