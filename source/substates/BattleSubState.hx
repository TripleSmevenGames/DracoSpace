package substates;

import ui.battle.LoseScreen;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.player.Deck;
import ui.battle.CharacterSprite;
import ui.battle.DeckSprite;
import ui.battle.WinScreen;
import utils.BattleAnimationManager;
import utils.BattleManager;
import utils.DamageNumbers;
import utils.GameController;
import utils.SubStateManager;

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

	static inline final PLAYER_X = 100;

	var ENEMY_X = FlxG.width - 200;

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		var playerDeck = Deck.sample();
		playerDeckSprite = new DeckSprite(0, FlxG.height - 200, playerDeck, PLAYER);
		add(playerDeckSprite);

		var enemyDeck = Deck.sample();
		enemyDeckSprite = new DeckSprite(Std.int(FlxG.width / 2), 10, enemyDeck, ENEMY, 1);
		add(enemyDeckSprite);

		playerChars = [];
		playerChars.push(CharacterSprite.sampleRyder());
		for (i in 0...playerChars.length)
		{
			var char = playerChars[i];
			char.setPosition(PLAYER_X, (FlxG.height / 2) - (i * 150));
			add(char);
		}

		enemyChars = [];
		enemyChars.push(CharacterSprite.sampleSlime());
		enemyChars.push(CharacterSprite.sampleSlime());
		for (i in 0...enemyChars.length)
		{
			var char = enemyChars[i];
			char.setPosition(ENEMY_X, FlxG.height / 3 + i * 150);
			add(char);
		}

		winScreen = new WinScreen(this.exitBattle);
		add(winScreen);

		loseScreen = new LoseScreen(() -> FlxG.switchState(new MenuState()));
		add(loseScreen);
	}

	public function exitBattle()
	{
		ssm.returnToMap();
		cleanup();
	}

	public function cleanup()
	{
		this.forEach((sprite:FlxSprite) ->
		{
			remove(sprite);
			sprite.destroy(); // possibly un needed
		});
	}

	public function new()
	{
		super();

		ssm = GameController.subStateManager;
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
	var damageNumbersLayer:DamageNumbers;

	public function initBattle(event:BattleEvent)
	{
		view.initBattle(event);

		bam.reset();

		bm.reset(view.playerDeckSprite, view.enemyDeckSprite, view.playerChars, view.enemyChars);
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

	public function showWinScreen()
	{
		view.winScreen.play();
	}

	public function showLoseScreen(){
		view.loseScreen.play();
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

		// layer to draw the damage numbers, which are shot out of characters when they get damaged.
		this.damageNumbersLayer = new DamageNumbers();
		add(damageNumbersLayer);
	}

	override public function destroy()
	{
		super.destroy();
		if (view != null)
			this.view.destroy();
	}
}
