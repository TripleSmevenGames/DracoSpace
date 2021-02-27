package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGameDebug(0, 0, MenuState, 1, 60, 60, true));
	}
}
