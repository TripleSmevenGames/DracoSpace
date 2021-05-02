package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.BattleEvent;
import models.player.Deck;
import models.player.Player;
import models.skills.SkillAnimations;
import ui.TooltipLayer;
import ui.battle.DamageNumbers;
import ui.battle.LoseScreen;
import ui.battle.character.CharacterSprite;
import ui.battle.combatUI.DeckSprite;
import ui.battle.win.WinScreen;
import ui.debug.BAMIndicator;
import ui.debug.BMIndicator;
import utils.BattleAnimationManager;
import utils.BattleManager;
import utils.BattleSoundManager;
import utils.GameController;
import utils.SubStateManager;
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

	public var winScreen:WinScreen;
	public var loseScreen:LoseScreen;

	final PLAYER_X = FlxG.width * (1 / 4);
	final ENEMY_X = FlxG.width * (3 / 4);

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		// add background in the middle. This way the bg will still fit different resolutions.
		var background = new FlxSprite(0, 0, AssetPaths.forestBackgroundDay__png);
		background.scale3x();
		background.centerSprite(FlxG.width / 2, FlxG.height / 2);
		add(background);

		// create the characters and the deck, but only add the deck first.
		playerChars = [];
		for (charInfo in Player.chars)
			playerChars.push(new CharacterSprite(charInfo));

		playerDeckSprite = new DeckSprite(50, FlxG.height - 120, Player.deck, PLAYER, playerChars);
		add(playerDeckSprite);

		enemyChars = [];
		for (charInfo in event.enemies)
			enemyChars.push(new CharacterSprite(charInfo));

		enemyDeckSprite = new DeckSprite(FlxG.width - 50, FlxG.height - 120, event.eDeck, ENEMY, enemyChars);
		add(enemyDeckSprite);

		// the y "0" of where to start rendering characters from.
		var middleY = (FlxG.height / 2) - 32;

		// render the player chars
		for (i in 0...playerChars.length)
		{
			var char = playerChars[i];
			var xPos = ViewUtils.getXCoordForCenteringLR(i, playerChars.length, char.sprite.width + 20);
			var yPos = ViewUtils.getXCoordForCenteringLR(i, playerChars.length, char.sprite.height / 2);
			char.setPosition(PLAYER_X + xPos, middleY - yPos);
			add(char);
		}

		// render the enemy chars
		for (i in 0...enemyChars.length)
		{
			var char = enemyChars[i];
			var xPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, char.sprite.width + 20);
			var yPos = ViewUtils.getXCoordForCenteringLR(i, enemyChars.length, char.sprite.height / 2);
			char.setPosition(ENEMY_X - xPos, middleY - yPos);
			add(char);

			#if godmode
			char.currHp = 1;
			#end
		}

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
		view = new BattleView();
		view.scrollFactor.set(0, 0);
		add(view);
		view.initBattle(event);

		setupBattleLayers();
		setupSoundManager();

		bam.reset();
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
		GameController.battleTooltipLayer.kill();
		remove(GameController.battleSpriteAnimsLayer);
		GameController.battleSpriteAnimsLayer.kill();
		remove(GameController.battleDamageNumbers);
		GameController.battleDamageNumbers.kill();
	}

	public function showWinScreen(expReward:Int, moneyReward:Int, battleType:GameEventType)
	{
		view.winScreen.play(expReward, moneyReward, battleType);
	}

	public function showLoseScreen()
	{
		view.loseScreen.play();
	}

	function setupBattleLayers()
	{
		// layer to draw the damage numbers, which are shot out of characters when they get damaged.
		GameController.battleDamageNumbers.revive();
		add(GameController.battleDamageNumbers);

		// create the tooltip layer, which is where all tooltips will be added to.
		// this lets them be rendered on top of the battle view.
		GameController.battleTooltipLayer.revive();
		add(GameController.battleTooltipLayer);

		// layer to draw the sprite animations
		GameController.battleSpriteAnimsLayer.revive();
		add(GameController.battleSpriteAnimsLayer);
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
