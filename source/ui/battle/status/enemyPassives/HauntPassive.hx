package ui.battle.status.enemyPassives;

import models.skills.SkillAnimations;
import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class HauntPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			target.addStatus(EXPOSED, stacks);
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)(context.getAlivePlayers(), this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 2)
	{
		var info:StatusInfo = {
			type: HAUNT,
			name: 'Haunt',
			desc: 'When ${owner.info.name} dies, all its enemies gain ${initialStacks} Exposed.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
