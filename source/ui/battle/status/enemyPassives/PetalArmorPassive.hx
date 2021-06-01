package ui.battle.status.enemyPassives;

import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
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
		type = PETALARMOR;
		name = 'Petal Armor';
		var desc = 'Upon taking damage, all alies gain ${initialStacks} block.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.petalArmor__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
