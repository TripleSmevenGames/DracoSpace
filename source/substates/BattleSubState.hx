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
import models.events.BattleEvent;
import models.player.Deck;
import models.player.Player;
import ui.TooltipLayer;
import ui.battle.DamageNumbers;
import ui.battle.DeckSprite;
import ui.battle.LoseScreen;
import ui.battle.character.CharacterSprite;
import ui.battle.win.WinScreen;
import utils.BattleAnimationManager;
import utils.BattleManager;
import utils.GameController;
import utils.SubStateManager;
import utils.battleManagerUtils.BattleContext;

class BattleView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;
	var tooltipLayer:TooltipLayer;

	var exitButton:FlxSprite;

	var playerDeckSprite:DeckSprite;
	var playerChars:Array<CharacterSprite>;
	var enemyDeckSprite:DeckSprite;
	var enemyChars:Array<CharacterSprite>;

	public var winScreen:WinScreen;
	public var loseScreen:LoseScreen;

	final PLAYER_X = FlxG.width * (1 / 5);
	final ENEMY_X = FlxG.width * (4 / 5);

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.battlebg_mistywoods__png);
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
		add(background);

		playerChars = [];
		for (charInfo in Player.chars)
			playerChars.push(new CharacterSprite(charInfo));

		var cursor:Float = 0;
		for (i in 0...playerChars.length)
		{
			var char = playerChars[i];
			char.setPosition(PLAYER_X, FlxG.height / 3 + cursor);
			add(char);
			if (char.drone != null)
				FlxTween.tween(char.drone, {y: char.drone.y + 10}, 2, {type: PINGPONG, ease: FlxEase.quadOut});
			cursor += char.height + 24;
		}

		enemyChars = [];
		for (charInfo in event.enemies)
			enemyChars.push(new CharacterSprite(charInfo));

		cursor = 0;
		for (i in 0...enemyChars.length)
		{
			var char = enemyChars[i];
			char.setPosition(ENEMY_X, FlxG.height / 3 + cursor);
			add(char);
			cursor += char.height + 24;
		}

		playerDeckSprite = new DeckSprite(0, FlxG.height - 200, Player.deck, PLAYER, playerChars);
		add(playerDeckSprite);

		enemyDeckSprite = new DeckSprite(Std.int(FlxG.width / 2), 10, event.eDeck, ENEMY, enemyChars);
		add(enemyDeckSprite);

		winScreen = new WinScreen();
		add(winScreen);

		loseScreen = new LoseScreen(() -> FlxG.switchState(new MenuState()));
		add(loseScreen);

		add(tooltipLayer);
	}

	public function exitBattle()
	{
		ssm.returnToMap();
	}

	public function cleanup()
	{
		tooltipLayer.cleanupTooltips();
		this.forEach((sprite:FlxSprite) ->
		{
			if (sprite != tooltipLayer)
			{
				remove(sprite);
				sprite.destroy(); // possibly un needed
			}
		});
	}

	public function new()
	{
		super();

		ssm = GameController.subStateManager;
		tooltipLayer = GameController.battleTooltipLayer;

		#if debug
		exitButton = new FlxSprite(0, 0);
		exitButton.makeGraphic(10, 10, FlxColor.RED);
		add(exitButton);
		exitButton.scrollFactor.set(0, 0);
		FlxMouseEventManager.add(exitButton, null, null, null, null, false);
		FlxMouseEventManager.setMouseClickCallback(exitButton, (_) -> exitBattle());
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
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

	public function initBattle(event:BattleEvent)
	{
		view.initBattle(event);

		bam.reset();
		var context = new BattleContext(view.playerDeckSprite, view.enemyDeckSprite, view.playerChars, view.enemyChars);
		bm.reset(context, null, event.type);
	}

	public function cleanup()
	{
		if (view != null)
			view.cleanup();
		if (bam != null && bm != null)
		{
			bam.kill();
			bm.kill();
		}
	}

	public function showWinScreen(leveledUp:Bool = false, expReward:Int, moneyReward:Int)
	{
		view.winScreen.play(leveledUp, expReward, moneyReward);
	}

	public function showLoseScreen()
	{
		view.loseScreen.play();
	}

	override public function create()
	{
		super.create();

		// do only once when you first switch to the battle state (that's when create() is called);
		if (view == null)
		{
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

			// layer to draw the sprite animations
			add(GameController.battleSpriteAnimsLayer);

			// layer to draw the damage numbers, which are shot out of characters when they get damaged.
			add(GameController.battleDamageNumbers);

			// create the tooltip layer, which is where all tooltips will be added to.
			// this lets them be rendered on top of the battle view.
			add(GameController.battleTooltipLayer);
		}
	}

	override public function destroy()
	{
		super.destroy();
		if (view != null)
			this.view.destroy();
	}
}
