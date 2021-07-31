package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import managers.BattleAnimationManager;
import managers.BattleManager;
import managers.BattleSoundManager;
import managers.GameController;
import managers.SubStateManager;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.BattleEvent;
import models.player.Player;
import ui.battle.LoseScreen;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.BattleHeader;
import ui.battle.combatUI.CancelSkillButton;
import ui.battle.combatUI.ChooseTargetText;
import ui.battle.combatUI.DeckSprite;
import ui.battle.combatUI.TurnBanner;
import ui.battle.win.WinScreen;
import ui.debug.BAMIndicator;
import ui.debug.BMIndicator;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

class BattleView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;

	var exitButton:FlxSprite;

	var playerDeckSprite:DeckSprite;
	var playerChars:Array<CharacterSprite>;
	var enemyDeckSprite:DeckSprite;
	var enemyChars:Array<CharacterSprite>;
	var enemySpots:Array<Coords>;

	var battleHeader:BattleHeader;
	var turnBanner:TurnBanner;

	var cancelSkillButton:CancelSkillButton;
	var chooseTargetText:ChooseTargetText;

	public var winScreen:WinScreen;
	public var loseScreen:LoseScreen;

	// the reference X position of the player and enemy characters.
	final PLAYER_X = FlxG.width * (1 / 4);
	final ENEMY_X = FlxG.width * (3 / 4);

	final TURN_BANNER_Y = FlxG.height * (1 / 3);

	// make this use ViewUtil's Coords type instead (FlxPoint supposedly has bloat)
	function calculateEnemySpots(eChars:Array<CharacterSprite>, spots:Int):Array<FlxPoint>
	{
		// find the largest size we have to accomadate
		var retVal = new Array<FlxPoint>();
		var largestWidth:Float = 124;
		var largestHeight:Float = 124;
		for (char in eChars)
		{
			if (char.sprite.width > largestWidth)
				largestWidth = char.sprite.width;

			if (char.sprite.height > largestHeight)
				largestHeight = char.sprite.height;
		}
		for (i in 0...spots)
		{
			var xPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, largestWidth, 16);
			var yPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, largestHeight / 2);
			retVal.push(new FlxPoint(xPos, yPos));
		}

		return retVal;
	}

	/** Fade in and out the BATTLE START banner. Call this when the battle starts.**/
	public function queueBattleStartAnimation()
	{
		turnBanner.queueAnimation('BATTLE START');
	}

	/** Fade in and out the PLAYER TURN banner. Call this when the player turn starts.**/
	public function queuePlayerTurnAnimation()
	{
		turnBanner.queueAnimation('PLAYER TURN');
	}

	/** Fade in and out the ENEMY TURN banner. Call this when the enemy turn starts.**/
	public function queueEnemyTurnAnimation()
	{
		turnBanner.queueAnimation('ENEMY TURN');
	}

	public function initBattle(event:BattleEvent)
	{
		// add background in the middle. This way the bg will still fit different resolutions.
		var background = new FlxSprite(0, 0, AssetPaths.forestBackgroundDay__png);
		background.scale3x();
		background.centerSprite(FlxG.width / 2, FlxG.height / 2);
		add(background);

		// add the battle header at the very top
		this.battleHeader = new BattleHeader();
		add(battleHeader);

		// create the cancel button, which will appear when the player is choosing targets for a selected skill.
		// This lets them cancel their skill and refund their cards.
		this.cancelSkillButton = new CancelSkillButton();
		cancelSkillButton.setPosition(FlxG.width / 2, FlxG.height - 100);
		add(cancelSkillButton);
		cancelSkillButton.kill();

		// render the "Choose a target" text, which should pretty much always appear right above
		// the cancelSkillButton.
		this.chooseTargetText = new ChooseTargetText();
		chooseTargetText.centerSprite(cancelSkillButton.x, cancelSkillButton.y - 180);
		add(chooseTargetText);
		chooseTargetText.kill();

		// create the player chars (but dont add() them yet)
		this.playerChars = [];
		for (i in 0...Player.chars.length)
		{
			var charInfo = Player.chars[i];
			// make sure the char isnt dead. This should never happen though.
			if (charInfo.currHp != 0)
			{
				var playerChar = new CharacterSprite(charInfo);
				playerChars.push(playerChar);
			}
		}

		// create the deck sprite and add it.
		playerDeckSprite = new DeckSprite(50, FlxG.height - 120, Player.deck, PLAYER, playerChars, cancelSkillButton);
		add(playerDeckSprite);

		// now, create the enemy characters (but dont add() them yet)
		this.enemyChars = [];
		for (charInfo in event.enemies)
			enemyChars.push(new CharacterSprite(charInfo));

		// create the enemy deck sprite and add it.
		enemyDeckSprite = new DeckSprite(FlxG.width - 50, FlxG.height - 120, event.eDeck, ENEMY, enemyChars);
		add(enemyDeckSprite);

		// Start to render the player chars.
		// middleY is the y-coord reference point to render the characters based on.
		var middleY = (FlxG.height / 2) - 32;
		for (i in 0...playerChars.length)
		{
			var char = playerChars[i];
			// either the sprite's width or the hpbar's approx width
			var effectiveWidth = Math.max(char.sprite.width, 132);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, playerChars.length, effectiveWidth + 16);
			var yPos = ViewUtils.getXCoordForCenteringLR(i, playerChars.length, char.sprite.height / 2);
			char.setPosition(PLAYER_X + xPos, middleY - yPos);
			add(char);
		}

		// calculate the spots where enemies can spawn.
		// Normally if there are x enemies, we calculate x spots.
		// But some battles might spawn more enemies, so we have to calculate those additional spots ahead of time.
		// var enemySpots = calculateEnemySpots(enemyChars, event.additionalSpots);

		// render the enemy chars
		for (i in 0...enemyChars.length)
		{
			var char = enemyChars[i];
			var effectiveWidth = Math.max(char.sprite.width, 150);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, effectiveWidth + 16);
			var yPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, char.sprite.height / 2);
			char.setPosition(ENEMY_X - xPos, middleY - yPos);
			add(char);

			#if godmode
			char.currHp = 1;
			#end
		}

		// render the turn banner, which will appear briefly announcing when the player or enemy turn has started.
		this.turnBanner = new TurnBanner();
		turnBanner.setPosition(FlxG.width / 2, TURN_BANNER_Y);
		add(turnBanner);

		winScreen = new WinScreen();
		add(winScreen);

		loseScreen = new LoseScreen(() -> FlxG.switchState(new MenuState()));
		add(loseScreen);

		#if debug
		add(new BAMIndicator(GameController.battleAnimationManager));
		var bmind = new BMIndicator(GameController.battleManager);
		bmind.setPosition(0, 50);
		add(bmind);
		#end
	}

	public function exitBattle()
	{
		ssm.returnToMap();
	}

	public function new()
	{
		super();

		ssm = GameController.subStateManager;
	}
}

// a substate containing the battle view

@:access(substates.BattleView)
class BattleSubState extends FlxSubState
{
	static inline final GRAVITY_Y = 1200;

	var view:BattleView;
	var bm:BattleManager;
	var bam:BattleAnimationManager;
	var bsm:BattleSoundManager;

	public function initBattle(event:BattleEvent)
	{
		cleanup();
		FlxG.camera.scroll.x = 0;
		view = new BattleView();
		view.scrollFactor.set(0, 0);
		add(view);
		view.initBattle(event);

		setupBattleLayers();
		setupSoundManager();

		bam.reset();

		// make sure we do this AFTER the battle view has already been setup and added.
		var context = new BattleContext(view.playerDeckSprite, view.enemyDeckSprite, view.playerChars, view.enemyChars);
		bm.reset(context, null, event.type);
	}

	public function cleanup()
	{
		if (view != null)
		{
			remove(view);
			view.destroy();
			view = null;
		}

		if (bsm != null)
		{
			remove(bsm);
			bsm.destroy();
			bsm = null;
		}

		if (bam != null && bm != null)
		{
			bam.kill();
			bm.kill();
		}

		remove(GameController.battleTooltipLayer);
		// destroys all tooltips to cleanup memory. Might cause crashes if we try to reference a destroyed tooltip, so watch out here.
		GameController.battleTooltipLayer.cleanUpTooltips();
		GameController.battleTooltipLayer.kill();
		remove(GameController.battleSpriteAnimsLayer);
		GameController.battleSpriteAnimsLayer.kill();
		remove(GameController.battleDamageNumbersLayer);
		GameController.battleDamageNumbersLayer.kill();
	}

	public function showWinScreen(expReward:Int, moneyReward:Int, battleType:GameEventType)
	{
		view.winScreen.play(expReward, moneyReward, battleType);
	}

	public function showLoseScreen()
	{
		view.loseScreen.play();
	}

	public function queueBattleStartAnimation()
	{
		view.queueBattleStartAnimation();
	}

	/** Fade in and out the PLAYER TURN banner. Call this when the player turn starts.**/
	public function queuePlayerTurnAnimation()
	{
		view.queuePlayerTurnAnimation();
	}

	/** Fade in and out the ENEMY TURN banner. Call this when the enemy turn starts.**/
	public function queueEnemyTurnAnimation()
	{
		view.queueEnemyTurnAnimation();
	}

	public function setCancelSkillButtonOnClick(onClick:Void->Void)
	{
		view.cancelSkillButton.setOnClick(onClick);
	}

	/** show the cancel skill button and the choose target text **/
	public function showCancelSkillButton()
	{
		view.cancelSkillButton.revive();
		view.chooseTargetText.revive();
	}

	/** hide the cancel skill button and the choose target text **/
	public function hideCancelSkillButton()
	{
		view.cancelSkillButton.kill();
		view.chooseTargetText.kill();
	}

	/** Renders different layers where battle UI is rendered.
	 * The order is important, what's added last is rendered on top of everything before it.
	**/
	function setupBattleLayers()
	{
		// layer to add non-specific stuff from the view to, so it appears to render above everything else in the view.
		// e.g. the target arrows which are part of the characters, so it wont render underneath another character.
		// same with highlights on cards.
		GameController.battleMiscUILayer.revive();
		add(GameController.battleMiscUILayer);

		// layer to draw the damage numbers, which are shot out of characters when they get damaged.
		GameController.battleDamageNumbersLayer.revive();
		add(GameController.battleDamageNumbersLayer);

		// layer to draw the sprite animations
		GameController.battleSpriteAnimsLayer.revive();
		add(GameController.battleSpriteAnimsLayer);

		// create the tooltip layer, which is where all tooltips will be added to.
		// this lets them be rendered on top of the battle view.
		GameController.battleTooltipLayer.revive();
		add(GameController.battleTooltipLayer);
	}

	function setupSoundManager()
	{
		this.bsm = new BattleSoundManager();
		GameController.battleSoundManager = bsm;
		add(bsm);
	}

	override public function create()
	{
		super.create();

		view = new BattleView();
		view.scrollFactor.set(0, 0);
		add(view);

		this.bm = GameController.battleManager;
		this.bam = GameController.battleAnimationManager;

		add(bam);
		bam.kill();
		add(bm);
		bm.kill();

		// set up the physics for the damager numbers and other physics based sprites.
		// refer to https://github.com/HaxeFlixel/flixel-demos/tree/master/Features/FlxNape
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, GRAVITY_Y);

		setupBattleLayers();
	}
}
