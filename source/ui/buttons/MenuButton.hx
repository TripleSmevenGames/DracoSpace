package ui.buttons;

import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

// based on http://coinflipstudios.com/devblog/?p=243
class MenuButton extends FlxUIButton
{
	public function new(text:String, onClick:Void->Void)
	{
		super(0, 0, text, onClick);

		final FONT_SIZE = 30;

		var upSprite = AssetPaths.blue_outline__png;
		var hoverSprite = AssetPaths.green_outline__png;
		var downSprite = AssetPaths.green_pressed_outline__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		loadGraphicSlice9(graphicArray, 350, 50, slice9Array);

		setLabelFormat(AssetPaths.DOSWin__ttf, FONT_SIZE, FlxColor.BLACK);
		autoCenterLabel();
	}
}
