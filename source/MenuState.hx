package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import ui.FlxTextWithReplacements;
import ui.buttons.MenuButton;
import ui.debug.MemIndicator;
import utils.GameController;
import utils.GameUtils;
import utils.ViewUtils;

class MenuState extends FlxState
{
	var memIndicator:MemIndicator;

	function clickNew()
	{
		// clear the saved seed
		GameController.save.data.seed = null;
		GameController.initRng();
		FlxG.switchState(new PlayState());
	}

	function clickContinue()
	{
		GameController.initRng();
		FlxG.switchState(new PlayState());
	}

	function clickExit()
	{
		#if sys
		Sys.exit(0);
		#end
	}

	function setupScreen()
	{
		var titleText = new FlxText(0, 0, 0, "DracoSpace");
		titleText.setFormat(AssetPaths.font04B30__ttf, 100);
		ViewUtils.centerSprite(titleText, FlxG.width / 2, 200);
		add(titleText);

		var newGameButton = new MenuButton('New Game', clickNew);
		newGameButton.screenCenter();
		add(newGameButton);

		var continueButton = new MenuButton('Continue', clickContinue);
		continueButton.screenCenter();
		continueButton.y += 80;
		add(continueButton);

		#if sys
		var exitButton = new MenuButton('Exit', clickExit);
		exitButton.screenCenter();
		exitButton.y += 160;
		add(exitButton);
		#end
	}

	override public function create()
	{
		super.create();
		#if debug
		trace('debug activated');
		#end
		setupScreen();

		GameController.initSave();

		// watch mem usage
		#if debug
		memIndicator = new MemIndicator();
		add(memIndicator);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
