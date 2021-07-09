package ui.battle.status.enemyPassives;

import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class LastBreathPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			// decide the target when the effect is played rather than when its triggered, because enemies might die between
			// when its triggered and when its played.
			var trueTarget = context.getLowestHealthEnemy();
			if (trueTarget != null)
			{
				trueTarget.currBlock += 10;
				trueTarget.healHp(5);
			}
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)([this.owner], this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: LASTBREATH,
			name: 'Last Breath',
			desc: 'When ${owner.info.name} dies, an ally gains 10 Block is healed for 5 hp.',
			iconPath: AssetPaths.lastBreath__png,
			stackable: false,
		}

		super(owner, info, initialStacks);
	}
}
