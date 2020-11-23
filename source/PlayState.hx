package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
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

		var mapView = new GameMapView(map, 50, FlxG.height / 2);
		add(mapView);

		// add some stuff to see border
		add(new FlxSprite(0, 0).makeGraphic(100, 10, FlxColor.GRAY));
		add(new FlxSprite(0, FlxG.height).makeGraphic(100, 10, FlxColor.GRAY));
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
