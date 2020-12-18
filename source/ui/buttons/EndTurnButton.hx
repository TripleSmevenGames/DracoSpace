package ui.buttons;

import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

// based on http://coinflipstudios.com/devblog/?p=243
class EndTurnButton extends FlxUIButton
{
	public function new(text:String, ?onClick:Void->Void)
	{
		super(0, 0, text, onClick);

		var upSprite = AssetPaths.white__png;
		var hoverSprite = AssetPaths.white__png;
		var downSprite = AssetPaths.white_pressed__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		loadGraphicSlice9(graphicArray, 100, 32, slice9Array);

		setLabelFormat(AssetPaths.DOSWin__ttf, 18, FlxColor.BLACK);
		autoCenterLabel();
	}
}
