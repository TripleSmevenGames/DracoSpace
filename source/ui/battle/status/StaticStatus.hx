package ui.battle.status;

import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
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

		for (ally in allies)
		{
			if (ally.skillsPlayedThisTurn == 1)
				ally.addStatus(STATIC, 1);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = STATIC;
		name = 'Static';

		var desc = 'The first time this character plays a skill this turn, they and their allies gain 1 Static.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Static1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
