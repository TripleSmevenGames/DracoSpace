package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.player.Deck;
import ui.DeckSprite;

class BattleView extends FlxSpriteGroup
{
	var screen:FlxSprite;
	var exitButton:FlxSprite;
	var deckSprite:DeckSprite;

	var wait:Bool;

	public function initBattle(event:BattleEvent)
	{
		visible = true;
		active = true;
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
		visible = false;
		active = false;
		remove(deckSprite);
	}

	public function new()
	{
		super();

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

		visible = false;
		active = false;
		wait = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
