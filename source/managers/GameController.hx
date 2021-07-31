package managers;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import ui.MiscUILayer;
import ui.TooltipLayer;
import ui.battle.DamageNumbersLayer;
import ui.battle.SpriteAnimsLayer;
import ui.header.Header;

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

	public static var battleMiscUILayer:MiscUILayer;

	public static var battleDamageNumbersLayer:DamageNumbersLayer;

	public static var battleSpriteAnimsLayer:SpriteAnimsLayer;

	/** Sound manager. One is created (then destroyed) for every battle sequence. 
	 * The bss needs to set this variable so its easily accessible by its children.
	**/
	public static var battleSoundManager:BattleSoundManager;

	/** Global shared header object. Make sure initHeader() was called first. **/
	public static var header:Header;

	public static var flags:GameFlags;

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
		flags = new GameFlags();
	}

	public static function initBattleLayers()
	{
		// maybe memory leak if we're not destroying before re-creating them??
		battleMiscUILayer = new MiscUILayer();
		battleTooltipLayer = new TooltipLayer();
		battleDamageNumbersLayer = new DamageNumbersLayer();
		battleSpriteAnimsLayer = new SpriteAnimsLayer();
	}

	/** Init the Header, which is the UI bar that appears at the top of the screen for map, event, and inv substates.
	 * This must be called after Player.init() is called. 
	 * Through it the player can see their money, xp, hp, and access the inv.
	 * All other substates access the shared header via the GameController.
	**/
	public static function initHeader()
	{
		header = new Header();
	}
}
