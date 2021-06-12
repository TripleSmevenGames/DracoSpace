package ui.battle.status;

import ui.battle.combatUI.SkillSprite;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
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
		type = STATIC;
		name = 'Static';

		var desc = 'The first time ${owner.info.name} plays a skill each turn, each ally gains 1 Static. Some skills Expend all Static.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Static1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
