package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
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
			{
				trueTarget.currBlock += 10;
				trueTarget.healHp(15);
			}
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)([this.owner], this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = LASTBREATH;
		name = 'Last Breath';
		var desc = 'When ${owner.info.name} dies, an ally gains 10 Block is healed for 15 hp.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.lastBreath__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
