package ui.battle;

import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import managers.GameController;
import managers.SubStateManager;
import ui.buttons.BasicWhiteButton;
import utils.ViewUtils;

class LoseScreen extends FlxSpriteGroup
{
	var ssm:SubStateManager;
	var text:FlxText;
	var mainMenuBtn:BasicWhiteButton;

	var youDiedSound:FlxSound;

	/** Play the animation of this screen.**/
	public function play()
	{
		this.revive();

		youDiedSound.play();

		text.scale.set(0.1, 0.1);
		text.alpha = .2;
		FlxTween.tween(text, {
			alpha: 1,
			'scale.x': 1,
			'scale.y': 1,
			x: text.x - 50,
		}, 3);

		mainMenuBtn.alpha = 0;
		FlxTween.tween(mainMenuBtn, {
			alpha: 1,
		}, .5);
	}

	public function new(onMainMenuClick:Void->Void)
	{
		super(0, 0);
		this.ssm = GameController.subStateManager;

		var screen = new FlxSprite(0, 0);
		screen.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 128));
		add(screen);

		this.text = new FlxText(0, 0, FlxG.width, 'YOU DIED');
		text.setFormat(Fonts.STANDARD_FONT, 100, FlxColor.WHITE, 'center');
		text.setPosition(0, 300);
		add(text);

		this.mainMenuBtn = new BasicWhiteButton('Main Menu', onMainMenuClick);
		ViewUtils.centerSprite(mainMenuBtn, FlxG.width / 2, FlxG.height / 2 + 100);
		add(mainMenuBtn);

		this.youDiedSound = FlxG.sound.load(AssetPaths.youDied__wav);

		this.kill();
	}
}
