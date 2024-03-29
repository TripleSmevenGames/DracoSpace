package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import managers.GameController;
#if sys
import sys.io.File;
#end

class CrashState extends FlxState
{
	override public function create()
	{
		if (GameController.latestException != null)
		{
			var sorry = new FlxText(0, 0, 0,
				'An error occurred and the game crashed. \nPlease screenshot this to the developer so he can fix it. Or send the error.txt file in the DracoSpace folder. Thanks',
				20);
			add(sorry);

			var e = GameController.latestException;
			var message = new FlxText(0, sorry.height + 16, 0, e.message, 16);
			add(message);

			var stack = new FlxText(0, message.y + message.height, 0, e.details(), 12);
			add(stack);

			#if sys
			var exit = () -> Sys.exit(0);
			var exitButton = new FlxButton(FlxG.width - 200, FlxG.height - 100, 'EXIT', exit);
			add(exitButton);
			#end

			#if sys
			try
			{
				var date = Date.now().toString();
				var outputString = '${date}: ${e.message}\n${e.details()}\n';
				File.saveContent('error.txt', outputString);
			}
			catch (e)
			{
				trace('failed to write crash file: ${e.message}');
			}
			#end
		}
	}
}
