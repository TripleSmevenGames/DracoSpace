package ui.battle.status.enemyPassives;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class PetalSpikesPassive extends Status
{
	override public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		var players = context.getAlivePlayers();
		for (player in players)
		{
			owner.dealDamageTo(stacks, player, context);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 3)
	{
		var info:StatusInfo = {
			type: PETALSPIKES,
			name: 'Petal Spikes',
			desc: 'Upon taking damage, ${owner.info.name} deals $initialStacks to its all enemies.',
			iconPath: AssetPaths.petalSpikes__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
