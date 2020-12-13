package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import models.GameMap;
import utils.GameUtils;
import views.BattleView;
import views.EventView;
import views.GameMapView;

class PlayState extends FlxState
{
	override public function create()
	{
		#if debug
		trace('debug activated');
		#else
		trace('normal mode');
		#end

		super.create();

		// you must set up the rng before anything other views.
		var seed:Null<Int> = GameUtils.save.data.seed;
		GameUtils.rng = new FlxRandom(seed);

		var battleView = new BattleView();
		var eventView = new EventView(battleView);
		var mapView = new GameMapView(50, 100, eventView);
		add(mapView);
		add(eventView);
		add(battleView);
		// keeps views in view of the camera;
		eventView.scrollFactor.set(0, 0);
		battleView.scrollFactor.set(0, 0);

		FlxG.camera.minScrollX = 0;
		FlxG.camera.maxScrollX = 5000; // arbitrary
		FlxG.camera.minScrollY = 0;
		FlxG.camera.maxScrollY = 1000;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.anyPressed([ESCAPE]))
			FlxG.switchState(new MenuState());
	}
}
