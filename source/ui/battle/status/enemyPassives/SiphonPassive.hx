package ui.battle.status.enemyPassives;

import ui.battle.combatUI.SkillSprite;
import flixel.math.FlxRandom;
import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class SiphonPassive extends Status
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
		type = SIPHON;
		name = 'Siphon';
		var desc = 'Yuyi draws a card every time an enemy plays a skill. (You\'re her enemy!)';
		var options:IndicatorIconOptions = {
			outlined: true,
			display: false,
		};
		var icon = new IndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		this.stackable = false;

		super(owner, icon, initialStacks);
	}
}
