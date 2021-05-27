package;

import flixel.FlxG;
import flixel.FlxState;
import managers.GameController;
import managers.MusicManager;
import models.events.HomeEvent;
import models.events.battleEvents.BattleEventFactory;
import models.player.Player;
import models.skills.SkillFactory;
import ui.debug.BAMIndicator;
import ui.debug.BMIndicator;
import ui.debug.MemIndicator;

class PlayState extends FlxState
{
	#if debug
	var memIndicator:MemIndicator;
	var bamIndicator:BAMIndicator;
	var bmIndicator:BMIndicator;
	#end

	override public function create()
	{
		super.create();

		// substates aren't destroyed when closed. This should reduce sub state load time
		// at cost of greater memory.
		destroySubStates = false;

		persistentUpdate = false;
		persistentDraw = false;

		FlxG.fixedTimestep = false;

		GameController.initSSM(this);
		GameController.initBattleManagers();
		GameController.subStateManager.initEvent(new HomeEvent());

		MusicManager.init();

		SkillFactory.init();

		Player.init();

		BattleEventFactory.init();

		FlxG.camera.minScrollX = 0;
		// FlxG.camera.maxScrollX = 5000; // arbitrary
		FlxG.camera.minScrollY = 0;
		// FlxG.camera.maxScrollY = 1000;

		FlxG.sound.volume = .4;

		#if debug
		memIndicator = new MemIndicator();
		add(memIndicator);
		#end
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.anyPressed([ESCAPE]))
			FlxG.switchState(new MenuState());

		#if desktop
		if (FlxG.keys.justPressed.P)
		{
			trace('pressed p');
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		#end

		super.update(elapsed);
	}

	override public function destroy()
	{
		super.destroy();
		GameController.subStateManager.destroyAll();
	}
}
