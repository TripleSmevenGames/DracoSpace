package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import models.skills.SkillAnimations;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class LastBreathPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var random = new FlxRandom();
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			// decide the target when the effect is played rather than when its triggered, because enemies might die between
			// when its triggered and when its played.
			var trueTarget = context.getLowestHealthEnemy();
			if (trueTarget != null)
				trueTarget.healHp(15);
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)([this.owner], this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = LASTBREATH;
		name = 'Last Breath';
		var desc = 'When this character dies, an ally is healed for 15 hp.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
