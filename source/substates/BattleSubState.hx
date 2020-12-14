package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.player.Deck;
import ui.DeckSprite;
import utils.GameController;
import utils.SubStateManager;

class BattleView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;

	var screen:FlxSprite;
	var exitButton:FlxSprite;
	var deckSprite:DeckSprite;

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		trace('battle init with ${event.enemy.name}');
		var sampleDeck = Deck.sample();
		deckSprite = new DeckSprite(0, Math.round(screen.height - 200), 200, sampleDeck);
		deckSprite.restart();
		deckSprite.drawCards(2);
		add(deckSprite);
	}

	public function exitBattle(_)
	{
		trace('clicked on exit button');
		ssm.returnToMap();
		remove(deckSprite);
	}

	public function new()
	{
		super();

		ssm = GameController.subStateManager;

		screen = new FlxSprite(0, 0);
		screen.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(screen);
		screen.scrollFactor.set(0, 0);
		FlxMouseEventManager.add(this, null, null, null, null, false);

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

	public function initBattle(event:BattleEvent)
	{
		view.initBattle(event);
	}

	override public function create()
	{
		super.create();
		view = new BattleView();
		view.scrollFactor.set(0, 0);
		add(view);
		openCallback = function()
		{
			trace('opened battle');
		}

		closeCallback = function()
		{
			trace('closed battle');
		}
	}

	override public function destroy()
	{
		super.destroy();
		// view.destroy();
	}
}
