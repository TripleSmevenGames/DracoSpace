package ui.buttons;

import constants.Fonts;
import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import models.events.Choice;
import models.events.GameEvent;

/** based on http://coinflipstudios.com/devblog/?p=243 
 * Create a button from a Choice for the event sub state Not centered.
**/
class EventChoiceButton extends FlxUIButton
{
	public var choice:Choice;
	public var disabled(default, set):Bool = false;

	static inline final WIDTH = 500;
	static inline final HEIGHT = 60;

	public function set_disabled(val:Bool)
	{
		if (val)
			this.color = FlxColor.GRAY;
		else
			this.color = FlxColor.WHITE;

		return disabled = val;
	}

	public function new(choice:Choice)
	{
		this.choice = choice;
		this.disabled = choice.disabled;
		var actualOnClick = () ->
		{
			if (!this.disabled)
				choice.effect(choice);
		};

		super(0, 0, choice.text, actualOnClick);

		var fontSize = 24;
		if (choice.text.length > 30)
			fontSize = 22;

		var upSprite = AssetPaths.greyBlue_light__png;
		var hoverSprite = AssetPaths.greyBlue__png;
		var downSprite = AssetPaths.greyBlue_pressed__png;
		var graphicArray:Array<FlxGraphicAsset> = [upSprite, hoverSprite, downSprite];

		var slice9 = [8, 8, 40, 40];
		var slice9Array = [slice9, slice9, slice9];
		loadGraphicSlice9(graphicArray, WIDTH, HEIGHT, slice9Array);

		setLabelFormat(Fonts.STANDARD_FONT, fontSize, FlxColor.WHITE);
		autoCenterLabel();
	}
}
