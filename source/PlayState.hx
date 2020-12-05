package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.GameMap;
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

		#if debug
		#end

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
	}
}
