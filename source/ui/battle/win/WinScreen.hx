package ui.battle.win;

import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import ui.buttons.BasicWhiteButton;
import utils.GameController;
import utils.SubStateManager;
import utils.ViewUtils;

using utils.ViewUtils;

class WinScreen extends FlxSpriteGroup
{
	var ssm:SubStateManager;
	var text:FlxText;
	var continueBtn:BasicWhiteButton;

	/** Play the animation of this screen.
	 *
	 * If we leveled up, show the rewards!
	**/
	public function play(leveledUp:Bool = false)
	{
		this.revive();

		text.scale.set(0.1, 0.1);
		text.alpha = 0;
		FlxTween.tween(text, {
			alpha: 1,
			'scale.x': 1,
			'scale.y': 1,
			x: text.x - 50,
		}, .5);

		continueBtn.alpha = 0;
		FlxTween.tween(continueBtn, {
			alpha: 1,
		}, .5);
	}

	public function new(onContinueClick:Void->Void)
	{
		super(0, 0);
		this.ssm = GameController.subStateManager;

		var screen = new FlxSprite(0, 0);
		screen.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 128));
		add(screen);

		this.text = new FlxText(0, 0, 0, 'VICTORY');
		text.setFormat(Fonts.STANDARD_FONT, 100, FlxColor.WHITE);
		add(text);
		ViewUtils.centerSprite(text, FlxG.width / 2, 200);

		var anchor = ViewUtils.newAnchor();
		anchor.setPosition(FlxG.width / 2, 200);
		add(anchor);

		this.continueBtn = new BasicWhiteButton('Continue', onContinueClick);
		ViewUtils.centerSprite(continueBtn, FlxG.width / 2, FlxG.height / 2 + 100);
		add(continueBtn);

		this.kill();
	}
}
