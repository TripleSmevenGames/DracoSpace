package ui.battle.combatUI;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import managers.BattleAnimationManager;
import managers.BattleManager;
import managers.GameController;
import models.CharacterInfo.CharacterType;
import models.cards.Card;
import models.player.Deck;
import models.skills.Skill.SkillPointCombination;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;

using utils.GameUtils;
using utils.ViewUtils;

/** Indicator on the side of the "Hand" telling you how many
 * of each skill point you will get from the picked cards. 
 * Currently UNUSED.
**/
class SkillPointDisplay extends FlxSpriteGroup
{
	var pointList:Array<FlxText>;
	var bm:BattleManager;

	// used for the blink() function
	var timer:FlxTimer;

	var LINE_HEIGHT = 18;

	/** Rerender the display based on the information. **/
	function refresh(skillPoints:SkillPointCombination)
	{
		var nonZeroCount = 0;
		for (i in 0...pointList.length)
		{
			var line = pointList[i];
			line.visible = false;

			var type = SkillPointCombination.ARRAY[i];
			var name = type.getName();
			var val = skillPoints.get(type);
			if (val > 0) // just show the types that are non-zero
			{
				line.text = '${val} ${name}';
				line.setPosition(this.x, this.y + nonZeroCount * LINE_HEIGHT);
				line.visible = true;
				nonZeroCount++;
			}
		}
	}

	// handles a single "blink", ie turning the sprite white to red, or red to white.
	function singleBlink()
	{
		var currColor = pointList[0].color;
		var white:FlxColor = 0x00FFFFFF; // same as FlxColor.WHITE but without the alpha
		var color = currColor == white ? FlxColor.RED : white;
		for (text in pointList)
			text.color = color;
	}

	/** Flash the indicator red using an FlxTimer, if its not blinking already. **/
	function blink()
	{
		if (!timer.finished)
			return;

		var time = .20; // time each loop lasts.
		var loops = 6;
		var onComplete = (_) -> singleBlink();

		timer.start(time, onComplete, loops);
	}

	public function new(x:Int = 0, y:Int = 0)
	{
		super(x, y);
		this.pointList = new Array<FlxText>();
		this.timer = new FlxTimer();
		timer.cancel();
		this.bm = GameController.battleManager;

		for (i in 0...SkillPointCombination.ARRAY.length)
		{
			var flxText = new FlxText(0, 0, 0, ' ');
			flxText.setFormat(Fonts.STANDARD_FONT, BATTLE_UI_FONT_SIZE_SM);
			pointList.push(flxText);
			add(flxText);
			flxText.visible = false;
		}
	}
}
