package ui.buttons;

import constants.Fonts;
import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

// based on http://coinflipstudios.com/devblog/?p=243
// implements look only. Parent should handle mouse events.

/** not centered.**/
class BasicWhiteButton extends FlxUIButton
{
	public var disabled(default, set):Bool = false;
	public var buttonWidth:Int;
	public var buttonHeight:Int;

	public function set_disabled(val:Bool)
	{
		if (val)
			this.color = FlxColor.GRAY;
		else
			this.color = FlxColor.WHITE;

		return disabled = val;
	}

	public function new(text:String, ?onClick:Void->Void, w:Int = 100, h:Int = 32, fontSize:Int = 18)
	{
		var actualOnClick = () ->
		{
			if (!this.disabled)
				onClick();
		};
		super(0, 0, text, actualOnClick);

		var upSprite = AssetPaths.white__png;
		var hoverSprite = AssetPaths.white__png;
		var downSprite = AssetPaths.white_pressed__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		loadGraphicSlice9(graphicArray, w, h, slice9Array);

		setLabelFormat(Fonts.STANDARD_FONT, fontSize, FlxColor.BLACK);
		autoCenterLabel();

		this.buttonWidth = w;
		this.buttonHeight = h;
	}
}
