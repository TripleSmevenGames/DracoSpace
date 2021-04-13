package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import models.skills.SkillAnimations;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class ObservationPassive extends Status
{
	override public function onAnyPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		if (skillSprite.owner.info.type == PLAYER)
		{
			context.eDeck.drawCards(1);
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = OBSERVATION;
		name = 'Observation';
		var desc = 'Pin draws a card every time an enemy plays a skill. (You\'re his enemy!)';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
