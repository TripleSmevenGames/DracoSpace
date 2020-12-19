package utils;

import models.player.Player;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;

class GameController
{
	// global RNG to use throughout a run
	public static var rng:FlxRandom;

	// global save object
	public static var save:FlxSave;

	/** global view manager for playState views. */
	public static var subStateManager:SubStateManager;

	/** global manager for handling battle "business logic". **/
	public static var battleManager:BattleManager;

	/** global manager for animations during battle. */
	public static var battleAnimationManager:BattleAnimationManager;

	public static var player:Player;

	public static function initSave()
	{
		save = new FlxSave();
		save.bind('save');
	}

	public static function initRng()
	{
		var seed:Null<Int> = GameController.save.data.seed;
		if (seed == null)
			rng = new FlxRandom();
		else
			rng = new FlxRandom(seed);
	}

	public static function initSSM(playState:PlayState)
	{
		subStateManager = new SubStateManager(playState);
	}

	public static function initBattleManagers()
	{
		battleAnimationManager = new BattleAnimationManager();
		battleManager = new BattleManager();
	}
}
