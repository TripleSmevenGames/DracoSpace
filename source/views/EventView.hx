package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.events.GameEvent;
import utils.ViewUtils;

// this overlays the map. Triggers when you visit a node.
class EventView extends FlxSpriteGroup
{
	// the overlay that should cover the entire camera
	var screen:FlxSprite;

	var titleSprite:FlxText;
	var descSprite:FlxText;
	var battleButton:FlxButton;
	var exitButton:FlxButton;

	var battleView:BattleView;

	public var exitCallback:Void->Void;

	public var event:GameEvent;

	function onClickExit(_)
	{
		if (!active)
			return;
		visible = false;
		active = false;
		exitCallback();
	}

	function onClickBattle(_)
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
		ViewUtils.centerSprite(titleSprite, Math.round(screen.width / 2), Math.round(screen.height / 2) - 200);
		ViewUtils.centerSprite(descSprite, Math.round(screen.width / 2), Math.round(screen.height / 2));
		ViewUtils.centerSprite(battleButton, Math.round(screen.width / 2), Math.round(screen.height / 2) + 100);
		ViewUtils.centerSprite(exitButton, Math.round(screen.width / 2), Math.round(screen.height / 2) + 200);
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
		FlxMouseEventManager.add(screen, null, null, null, null, false);

		titleSprite = new FlxText(0, 0, 0, 'title');
		titleSprite.setFormat(AssetPaths.DOSWin__ttf, 32);
		add(titleSprite);

		descSprite = new FlxText(0, 0, 0, 'this is a sample desc. You should not see this in a real game');
		descSprite.setFormat(AssetPaths.DOSWin__ttf, 24);
		add(descSprite);

		battleButton = new FlxButton(0, 0, 'Battle');
		exitButton = new FlxButton(0, 0, 'Exit');

		add(battleButton);
		add(exitButton);
		FlxMouseEventManager.add(exitButton, null, null, null, null, false);
		FlxMouseEventManager.setMouseClickCallback(exitButton, onClickExit);
		FlxMouseEventManager.add(battleButton, null, null, null, null, false);
		FlxMouseEventManager.setMouseClickCallback(battleButton, onClickBattle);

		centerSprites();
		visible = false;
		active = false;
	}
}
