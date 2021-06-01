package ui;

import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;

class CardHighlight extends FlxUI9SliceSprite
{
	public function new(body:FlxSprite)
	{
		super(0, 0, AssetPaths.cardFrameHighlight__png, new Rectangle(0, 0, body.width + 16, body.height + 16), [24, 24, 36, 36]);
	}
}
