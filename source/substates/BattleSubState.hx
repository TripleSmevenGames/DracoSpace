package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.player.Deck;
import ui.battle.Character;
import ui.battle.DeckSprite;
import utils.BattleAnimationManager;
import utils.BattleManager;
import utils.GameController;
import utils.SubStateManager;

class BattleView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;

	var exitButton:FlxSprite;
	var deckSprite:DeckSprite;

	var playerChars:Array<Character> = new Array<Character>();
	var enemyChars:Array<Character> = new Array<Character>();

	static inline final PLAYER_X = 100;

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		trace('battle init with ${event.enemy.name}');
		var sampleDeck = Deck.sample();
		deckSprite = new DeckSprite(0, Math.round(FlxG.height - 200), 200, sampleDeck);
		deckSprite.restart();
		deckSprite.drawCards(2);
		add(deckSprite);

		var playerChar = Character.sampleRyder();
		playerChar.setPosition(PLAYER_X, FlxG.height / 2);
		add(playerChar);

		for (i in 0...10)
		{
			// var sprite = Character.sampleRyder();
			var sprite = new FlxSprite();
			sprite.loadGraphic(AssetPaths.KiwiCat__png);
			sprite.setGraphicSize(0, Std.int(sprite.height * 8));
			sprite.setPosition(PLAYER_X + i * 100, FlxG.height / 2);
			add(sprite);
		}
	}

	public function exitBattle(_)
	{
		ssm.returnToMap();
		remove(deckSprite);
	}

	public function new()
	{
		super();

		ssm = GameController.subStateManager;

		exitButton = new FlxSprite(0, 0);
		exitButton.makeGraphic(10, 10, FlxColor.RED);
		add(exitButton);
		exitButton.scrollFactor.set(0, 0);

		FlxMouseEventManager.add(exitButton, null, null, null, null, false);
		FlxMouseEventManager.setMouseClickCallback(exitButton, exitBattle);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

// a substate containing the battle view
class BattleSubState extends FlxSubState
{
	var view:BattleView;
	var battleManager:BattleManager;
	var bam:BattleAnimationManager;

	public function initBattle(event:BattleEvent)
	{
		view.initBattle(event);
		add(bam);
	}

	override public function create()
	{
		super.create();
		view = new BattleView();
		view.scrollFactor.set(0, 0);
		add(view);

		this.bam = GameController.battleAnimationManager;
	}

	override public function destroy()
	{
		super.destroy();
		if (view != null)
			this.view.destroy();
	}
}
