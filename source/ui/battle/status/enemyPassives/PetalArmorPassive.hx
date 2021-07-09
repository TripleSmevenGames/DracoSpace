package ui.battle.status.enemyPassives;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class PetalArmorPassive extends Status
{
	override public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		var enemies = context.getAliveEnemies();
		for (enemy in enemies)
		{
			enemy.currBlock += stacks;
		}
	}

	public function new(owner:CharacterSprite, initialStacks = 2)
	{
		var info:StatusInfo = {
			type: PETALARMOR,
			name: 'Petal Armor',
			desc: 'Upon taking damage, all its alies gain ${initialStacks} block.',
			iconPath: AssetPaths.petalArmor__png,
			stackable: true,
		}

		super(owner, info, initialStacks);
	}
}
