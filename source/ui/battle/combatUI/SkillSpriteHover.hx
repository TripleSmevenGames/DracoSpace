package ui.battle.combatUI;

import models.CharacterInfo.CharacterType;
import utils.ViewUtils;
import models.skills.Skill;
import flixel.group.FlxSpriteGroup;
import ui.battle.combatUI.SkillSprite;

/** Represents what you see when you hover over a SkillSprite.
 * Really just a SkillCard and button hints. Centered on SkillCard.
**/
class SkillSpriteHover extends FlxSpriteGroup
{
	function createButtonHints()
	{
		var group = new FlxSpriteGroup();

		var lmbToPlay = ViewUtils.getClickToSomethingText(true, 'Play');
		var rmbToAutoPlay = ViewUtils.getClickToSomethingText(false, 'Autopay');
		rmbToAutoPlay.setPosition(0, lmbToPlay.height + 4);

		var bgHeight = lmbToPlay.height * 2 + 8;
		var bgWidth = rmbToAutoPlay.width + 16;
		var bg = ViewUtils.newSlice9(AssetPaths.tooltipDefaultBg__png, bgWidth, bgHeight, [4, 4, 28, 28]);
		bg.setPosition(-4, -18);

		group.add(bg);
		group.add(lmbToPlay);
		group.add(rmbToAutoPlay);

		return group;
	}

	public function new(skillSprite:SkillSprite)
	{
		super();

		var skillCard = new SkillCard(skillSprite.skill);
		add(skillCard);

		if (skillSprite.owner.info.type == PLAYER)
		{
			var buttonHints = createButtonHints();
			buttonHints.setPosition(SkillCard.bodyWidth / 2 + 4, SkillCard.bodyHeight / 2 - buttonHints.height);
			add(buttonHints);
		}
	}
}
