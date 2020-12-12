package views;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.events.GameEvent;
import ui.buttons.EventButton;
import utils.ViewUtils;

// this overlays the map. Triggers when you visit a node.
class EventView extends FlxSpriteGroup
{
	// the overlay that should cover the entire camera, dimming the map behind it.
	var screen:FlxSprite;

	var titleSprite:FlxText;
	var descSprite:FlxText;
	var windowSprite:FlxUI9SliceSprite;
	var battleButton:EventButton;
	var exitButton:EventButton;

	var battleView:BattleView;

	public var exitCallback:Void->Void;

	public var event:GameEvent;

	// how many pixels below the screen midpoint that the choices start rendering from.
	static inline final CHOICES_TOP = 200;

	function onClickExit()
	{
		if (!active)
			return;
		visible = false;
		active = false;
		exitCallback();
	}

	function onClickBattle()
	{
		if (!active)
			return;

		var battleEvent:BattleEvent = cast(this.event, BattleEvent);
		battleView.initBattle(battleEvent);
		visible = false;
		active = false;
	}

	function centerSprites()
	{
		var centerX = Math.round(screen.width / 2);
		var centerY = Math.round(screen.height / 2);
		ViewUtils.centerSprite(titleSprite, centerX, centerY - 200);
		ViewUtils.centerSprite(descSprite, centerX, centerY);
		ViewUtils.centerSprite(windowSprite, centerX, centerY);

		var choiceButtons = [battleButton, exitButton];
		for (i in 0...choiceButtons.length)
		{
			ViewUtils.centerSprite(choiceButtons[i], centerX, centerY + CHOICES_TOP + (i * 35));
		}
	}

	// called by GameMapView to show the event screen over itself
	public function showEvent(event:GameEvent)
	{
		visible = true;
		active = true;
		this.event = event;
		titleSprite.text = '${event.name} (${event.type.getName()})';
		descSprite.text = event.desc;

		if (event.type == BATTLE)
			battleButton.visible = true;
		else
			battleButton.visible = false;

		centerSprites();
	}

	public function new(battleView:BattleView)
	{
		super();

		this.battleView = battleView;

		screen = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 200));
		add(screen);
		// I think this prevents clicks from "bleeding" through the screen
		FlxMouseEventManager.add(screen, null, null, null, null, false);

		windowSprite = new FlxUI9SliceSprite(0, 0, AssetPaths.space__png, new Rectangle(0, 0, 1000, 600), [8, 8, 40, 40]);
		add(windowSprite);

		titleSprite = new FlxText(0, 0, 0, 'title');
		titleSprite.setFormat(AssetPaths.DOSWin__ttf, 32);
		add(titleSprite);

		descSprite = new FlxText(0, 0, 0, 'this is a sample desc. You should not see this in a real game');
		descSprite.setFormat(AssetPaths.DOSWin__ttf, 24);
		add(descSprite);

		battleButton = new EventButton('Battle', onClickBattle);
		exitButton = new EventButton('Exit', onClickExit);

		add(battleButton);
		add(exitButton);

		centerSprites();
		visible = false;
		active = false;
	}
}
