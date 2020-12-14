package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import openfl.system.System;
import ui.buttons.MenuButton;
import utils.GameController;
import utils.GameUtils;
import utils.ViewUtils;

class MenuState extends FlxState
{
	var memoryUsage:FlxText;

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
		Sys.exit(0);
	}

	function setupScreen()
	{
		var titleText = new FlxText(0, 0, 0, "DrakoSpace");
		titleText.setFormat(AssetPaths.font04B30__ttf, 100);
		ViewUtils.centerSprite(titleText, Math.round(FlxG.width / 2), 200);
		add(titleText);

		var newGameButton = new MenuButton('New Game', clickNew);
		newGameButton.screenCenter();
		add(newGameButton);

		var continueButton = new MenuButton('Continue', clickContinue);
		continueButton.screenCenter();
		continueButton.y += 80;
		add(continueButton);

		var exitButton = new MenuButton('Exit', clickExit);
		exitButton.screenCenter();
		exitButton.y += 160;
		add(exitButton);
	}

	override public function create()
	{
		#if debug
		trace('debug activated');
		#else
		trace('normal mode');
		#end
		setupScreen();

		GameController.initSave();

		// watch mem usage
		#if debug
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		memoryUsage = new FlxText(0, 0, 0, 'MEM: ${mem}MB', 10);
		memoryUsage.scrollFactor.set(0, 0);
		add(memoryUsage);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		memoryUsage.text = 'MEM: ${mem}MB';
		#end
	}
}
