package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		var resolutionX = 0;
		var resolutionY = 0;

		// enforce a min resolution, anything smaller and the UI starts breaking.
		if (FlxG.stage.stageWidth < 1440)
			resolutionX = 1440;
		if (FlxG.stage.stageHeight < 900)
			resolutionY = 900;
		addChild(new FlxGameDebug(resolutionX, resolutionY, MenuState, 1, 60, 60, true));
	}
}
