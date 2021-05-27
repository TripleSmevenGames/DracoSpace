package managers;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import models.player.Player;
import models.skills.SkillAnimations;
import ui.TooltipLayer;
import ui.battle.DamageNumbers;
import ui.battle.SpriteAnimsLayer;

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

	/** global manager for tooltips during battle. **/
	public static var battleTooltipLayer:TooltipLayer;

	/** global manager for tooltips during inv menu. **/
	public static var invTooltipLayer:TooltipLayer;

	public static var battleDamageNumbers:DamageNumbers;

	public static var battleSpriteAnimsLayer:SpriteAnimsLayer;

	/** Sound manager. One is created (then destroyed) for every battle sequence. 
	 * The bss needs to set this variable so its easily accessible by its children.
	**/
	public static var battleSoundManager:BattleSoundManager;

	public static var latestException:haxe.Exception;

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
		initBattleLayers();

		invTooltipLayer = new TooltipLayer();
	}

	public static function initBattleLayers()
	{
		// maybe memory leak if we're not destroying before re-creating them??
		battleTooltipLayer = new TooltipLayer();
		battleDamageNumbers = new DamageNumbers();
		battleSpriteAnimsLayer = new SpriteAnimsLayer();
	}
}
