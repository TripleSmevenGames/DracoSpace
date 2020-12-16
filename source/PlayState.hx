package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import openfl.system.System;
import utils.GameController;
import utils.SubStateManager;

class PlayState extends FlxState
{
	var memoryUsage:FlxText;

	override public function create()
	{
		super.create();

		// substates aren't destroyed when closed. This should reduce sub state load time
		// at cost of greater memory.
		destroySubStates = false;

		persistentUpdate = true;
		persistentDraw = false;

		GameController.subStateManager = new SubStateManager(this);
		GameController.subStateManager.returnToMap();

		FlxG.camera.minScrollX = 0;
		FlxG.camera.maxScrollX = 5000; // arbitrary
		FlxG.camera.minScrollY = 0;
		FlxG.camera.maxScrollY = 1000;

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
		if (FlxG.keys.anyPressed([ESCAPE]))
			FlxG.switchState(new MenuState());

		#if debug
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		memoryUsage.text = 'MEM: ${mem}MB';
		#end
	}

	override public function destroy()
	{
		super.destroy();
		GameController.subStateManager.destroyAll();
	}
}
