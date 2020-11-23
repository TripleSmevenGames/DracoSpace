package;

import flixel.FlxG;
import flixel.FlxState;
import models.GameMap;
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
		var map = new GameMap();
		#if debug
		map.print();
		#end
		var mapView = new GameMapView(map);
		add(mapView);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.wheel != 0)
		{
			// Mouse wheel logic goes here, for example zooming in / out:
			FlxG.camera.scroll.x += (FlxG.mouse.wheel * 50);
		}
	}
}
