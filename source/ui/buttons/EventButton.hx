package ui.buttons;

import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;

// based on http://coinflipstudios.com/devblog/?p=243
class EventButton extends FlxUIButton
{
	public function new(text:String, ?onClick:Void->Void)
	{
		super(0, 0, text, onClick);

		var upSprite = AssetPaths.grey_light__png;
		var hoverSprite = AssetPaths.grey__png;
		var downSprite = AssetPaths.grey_pressed__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		loadGraphicSlice9(graphicArray, 500, 32, slice9Array);

		setLabelFormat(AssetPaths.DOSWin__ttf, 24, FlxColor.WHITE);
		autoCenterLabel();
	}
}
