package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import models.GameMap;
import views.GameMapView;

class PlayState extends FlxState
{
	static inline var SCROLL_SPEED = 25;

	private function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up)
			FlxG.camera.scroll.y -= SCROLL_SPEED;
		if (down)
			FlxG.camera.scroll.y += SCROLL_SPEED;
		if (left)
			FlxG.camera.scroll.x -= SCROLL_SPEED;
		if (right)
			FlxG.camera.scroll.x += SCROLL_SPEED;
	}

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

		var mapView = new GameMapView(map, 50, 0);
		add(mapView);

		// add some stuff to see border
		add(new FlxSprite(0, 0).makeGraphic(100, 10, FlxColor.GRAY));
		add(new FlxSprite(FlxG.width, FlxG.height - 100).makeGraphic(10, 100, FlxColor.GRAY));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.wheel != 0)
		{
			// Mouse wheel logic goes here, for example zooming in / out:
			FlxG.camera.scroll.x += (FlxG.mouse.wheel * 50);
		}
		updateMovement();
	}
}
