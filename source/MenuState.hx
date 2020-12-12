package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import ui.buttons.MenuButton;
import utils.GameUtils;
import utils.ViewUtils;

class MenuState extends FlxState
{
	function clickNew()
	{
		// clear the saved seed
		GameUtils.save.data.seed = null;
		FlxG.switchState(new PlayState());
	}

	function clickContinue()
	{
		FlxG.switchState(new PlayState());
	}

	function clickExit()
	{
		Sys.exit(0);
	}

	override public function create()
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

		// set up the global save
		GameUtils.save = new FlxSave();
		GameUtils.save.bind('save');
	}
}
