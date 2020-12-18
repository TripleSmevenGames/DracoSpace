package ui.debug;

import flixel.text.FlxText;
import openfl.system.System;

class MemIndicator extends FlxText
{
	public function new()
	{
		super(0, 10, 0, 'MEM:', 12);
		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float)
	{
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		text = 'MEM: ${mem}MB';

		super.update(elapsed / 4);
	}
}
