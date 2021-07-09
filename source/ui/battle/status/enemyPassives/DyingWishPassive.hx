package ui.battle.status.enemyPassives;

import models.skills.SkillAnimations;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
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
		var info:StatusInfo = {
			type: DYINGWISH,
			name: 'Dying Wish',
			desc: 'When ${owner.info.name} dies, all allies gain ${owner.info.name}\'s Attack.',
			iconPath: AssetPaths.dyingWish__png,
			stackable: false,
		}

		super(owner, info, initialStacks);
	}
}
