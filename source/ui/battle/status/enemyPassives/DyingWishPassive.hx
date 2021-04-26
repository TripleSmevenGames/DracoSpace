package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import models.skills.SkillAnimations;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class DyingWishPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			target.addStatus(ATTACK, owner.getStatus(ATTACK));
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)(context.getAliveEnemies(), this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = DYINGWISH;
		name = 'Dying Wish';
		var desc = 'When this character dies, all allies gain this character\'s Attack.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
