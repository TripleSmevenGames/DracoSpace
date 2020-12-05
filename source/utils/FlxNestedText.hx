package utils;

import flixel.addons.display.FlxNestedSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class FlxNestedText extends FlxNestedSprite
{
	private var text:FlxText;
	private var fontPath:String;

	public var message:String;

	private var textBoxAlign:String;
	private var size:Int;
	private var textColor:FlxColor;

	public function new(message:String, fontPath:String, size:Int = 10, textColor:FlxColor = FlxColor.WHITE, textBoxAlign:String = "left")
	{
		super();

		this.message = message;
		this.fontPath = fontPath;
		this.size = size;
		this.textColor = textColor;
		this.textBoxAlign = textBoxAlign;

		text = new FlxText(0, 0, 0, message);
		text.setFormat(fontPath, size, textColor, textBoxAlign);

		// copy pixels over to this sprite from the FlxText
		text.drawFrame(true);
		this.loadGraphicFromSprite(text);
	}
}
