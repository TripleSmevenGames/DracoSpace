package substates;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.events.GameEvent;
import ui.buttons.EventButton;
import utils.GameController;
import utils.SubStateManager;
import utils.ViewUtils;

class EventView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;

	// the overlay that should cover the entire camera, dimming the map behind it.
	var screen:FlxSprite;

	var titleSprite:FlxText;
	var descSprite:FlxText;
	var windowSprite:FlxUI9SliceSprite;
	var battleButton:EventButton;
	var exitButton:EventButton;

	public var exitCallback:Void->Void;

	public var event:GameEvent;

	// how many pixels below the screen midpoint that the choices start rendering from.
	static inline final CHOICES_TOP = 200;

	function onClickExit()
	{
		ssm.returnToMap();
	}

	function onClickBattle()
	{
		try
		{
			var battleEvent:BattleEvent = cast(this.event, BattleEvent);
			ssm.initBattle(battleEvent);
		}
		catch (err)
		{
			trace('error during onClickBattle(), ${err.message}');
		}
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

	public function showEvent(event:GameEvent)
	{
		this.event = event;
		titleSprite.text = '${event.name} (${event.type.getName()})';
		descSprite.text = event.desc;

		if (event.type == BATTLE)
			battleButton.visible = true;
		else
			battleButton.visible = false;

		centerSprites();
	}

	public function new()
	{
		super();
		trace('in new() for event view');

		this.ssm = GameController.subStateManager;

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
	}
}

// a substate containing the event view
class EventSubState extends FlxSubState
{
	var view:EventView;

	public function showEvent(event:GameEvent)
	{
		if (view == null)
		{
			trace('bad view in ess');
		}
		view.showEvent(event);
	}

	override public function create()
	{
		trace('calling create in event');
		super.create();
		trace('calling new EventView()');
		this.view = new EventView();
		trace('finished new EventView()');
		this.view.scrollFactor.set(0, 0);
		add(view);
		openCallback = function()
		{
			trace('opened event');
		}

		closeCallback = function()
		{
			trace('closed event');
		}
	}

	override public function destroy()
	{
		super.destroy();
		// this.view.destroy();
	}
}
