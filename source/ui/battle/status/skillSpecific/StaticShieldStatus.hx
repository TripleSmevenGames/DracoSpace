package ui.battle.status.skillSpecific;

import ui.battle.character.CharacterSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class StaticShieldStatus extends OneTurnStatus
{
	override public function onTakeDamage(damage:Int, dealer:CharacterSprite, context:BattleContext)
	{
		owner.addStatus(STATIC, stacks);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: STATICSHIELD,
			name: 'Static Shield',
			desc: 'This turn, gain $initialStacks Static when taking damage.',
			iconPath: AssetPaths.AttackDown__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
