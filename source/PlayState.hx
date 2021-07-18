package;

import flixel.FlxG;
import flixel.FlxState;
import managers.GameController;
import managers.MusicManager;
import models.artifacts.ArtifactFactory;
import models.events.HomeEvent;
import models.events.battleEvents.BattleEventFactory;
import models.events.encounterEvents.EncounterEventFactory;
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

	var originalVolume:Float = .4;

	override public function create()
	{
		super.create();

		// substates aren't destroyed when closed. This should reduce sub state load time
		// at cost of greater memory.
		destroySubStates = false;

		persistentUpdate = true; // if this is false, your key presses in update wont fire. So make sure it's true.
		persistentDraw = false;

		FlxG.fixedTimestep = false;

		GameController.initSSM(this);
		GameController.initBattleManagers();
		GameController.subStateManager.initEvent(new HomeEvent());

		MusicManager.init();

		SkillFactory.init();

		Player.init();

		BattleEventFactory.init();

		EncounterEventFactory.init();

		ArtifactFactory.init();

		FlxG.camera.minScrollX = 0;
		// FlxG.camera.maxScrollX = 5000; // arbitrary
		FlxG.camera.minScrollY = 0;
		// FlxG.camera.maxScrollY = 1000;

		FlxG.sound.volume = originalVolume;

		#if debug
		memIndicator = new MemIndicator();
		add(memIndicator);
		#end
	}

	override public function update(elapsed:Float)
	{
		// so when the user presses F1, go back to the menu
		if (FlxG.keys.anyPressed([F1]))
			FlxG.switchState(new MenuState());

		// press M to mute or unmute the music
		if (FlxG.keys.justPressed.M)
		{
			if (FlxG.sound.volume == 0)
			{
				FlxG.sound.volume = originalVolume;
			}
			else
			{
				originalVolume = FlxG.sound.volume;
				FlxG.sound.volume = 0;
			}
		}

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
