package ui.battle.status.enemyPassives;

import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.SkillSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class SiphonPassive extends Status
{
	override public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		if (skillSprite.owner.info.type == PLAYER)
		{
			context.eDeck.drawCards(1, null, 0, context);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: SIPHON,
			name: 'Siphon',
			desc: 'Yuyi draws a card every time an enemy plays a skill. (You\'re her enemy!)',
			iconPath: AssetPaths.AttackDown__png,
			stackable: false,
		}

		super(owner, info, initialStacks);
	}
}
