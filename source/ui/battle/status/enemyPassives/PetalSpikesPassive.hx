package ui.battle.status.enemyPassives;

import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
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
		type = PETALSPIKES;
		name = 'Petal Spikes';
		var desc = 'Upon taking damage, deal $initialStacks to all enemies.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.petalSpikes__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
