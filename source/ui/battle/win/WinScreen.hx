package ui.battle.win;

import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import managers.GameController;
import managers.SubStateManager;
import models.events.GameEvent.GameEventType;
import ui.buttons.BasicWhiteButton;
import utils.ViewUtils;

using utils.ViewUtils;

class WinScreen extends FlxSpriteGroup
{
	var ssm:SubStateManager;
	var text:FlxText;
	var continueBtn:BasicWhiteButton;

	var canContinue:Bool = false;

	function createNewContinueBtn(battleType:GameEventType)
	{
		// first, cleanup the old continue button
		if (this.continueBtn != null)
		{
			remove(this.continueBtn);
			this.continueBtn.destroy();
			this.continueBtn = null;
		}

		var onContinueClick = () -> ssm.returnToMap();
		if (battleType == TUTORIAL)
			onContinueClick = () -> ssm.returnToHome();

		this.continueBtn = new BasicWhiteButton('Continue', onContinueClick);
		ViewUtils.centerSprite(continueBtn, FlxG.width / 2, FlxG.height - 100);
		continueBtn.disabled = true;
		add(continueBtn);
	}

	/** Play the animation of this screen.
	**/
	public function play(expReward:Int, moneyReward:Int, battleType:GameEventType)
	{
		this.revive();
		createNewContinueBtn(battleType);

		text.scale.set(0.1, 0.1);
		text.alpha = 0;
		FlxTween.tween(text, {
			alpha: 1,
			'scale.x': 1,
			'scale.y': 1,
		}, .5);

		if (battleType == BATTLE || battleType == TUTORIAL)
			continueBtn.disabled = false; // there's no skill reward to claim, so just let them continue;
		else // ie ELITE battle or BOSS battle.
			continueBtn.disabled = true; // other wise, stop player from continuing until they claim their skill reward

		var onClaim = () -> continueBtn.disabled = false;
		var rewardsSprite = new RewardsSprite(expReward, moneyReward, battleType, onClaim);
		rewardsSprite.setPosition(FlxG.width / 2, FlxG.height / 2 + 100);
		add(rewardsSprite);
	}

	public function new()
	{
		super(0, 0);
		this.ssm = GameController.subStateManager;

		var screen = new FlxSprite(0, 0);
		screen.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 128));
		add(screen);

		this.text = new FlxText(0, 0, 0, 'VICTORY');
		text.setFormat(Fonts.STANDARD_FONT, 100, FlxColor.WHITE);
		ViewUtils.centerSprite(text, FlxG.width / 2, 200);
		add(text);

		this.kill();
	}
}
