package ui.battle.status.genericStatuses;

import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.SkillSprite;
import ui.battle.status.Status.StatusInfo;
import utils.battleManagerUtils.BattleContext;

class StaticStatus extends Status
{
	override public function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		super.onPlaySkill(skillSprite, context);
		var allies:Array<CharacterSprite> = [];
		if (skillSprite.owner.info.type == PLAYER)
			allies = context.pChars;
		else if (skillSprite.owner.info.type == ENEMY)
			allies = context.eChars;

		// if this skill is the first skill played by this character...
		if (skillSprite.owner.skillsPlayedThisTurn == 1)
		{
			for (ally in allies)
				ally.addStatus(STATIC, 1);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		var info:StatusInfo = {
			type: STATIC,
			name: 'Static',
			desc: 'The first time ${owner.info.name} plays a skill each turn, each ally gains 1 Static. Some skills Expend all Static.',
			iconPath: AssetPaths.Static1__png,
			stackable: true,
		};

		super(owner, info, initialStacks);
	}
}
