package ui.battle.combatUI;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/** A simple text that says "Choose a target". Should show up during the target phase to prompt
	the player to select a target for that skill. Automatically scales size according to resolution.
	  *
	  * Not centered. Extends from FlxText.
**/
class ChooseTargetText extends FlxText
{
	public function new()
	{
		var string = 'CHOOSE A TARGET';
		var color = Colors.TARGET_BLUE;
		var font = Fonts.STANDARD_FONT2;

		// the font size scales according to the screen size. This way it's noticeable, but doesnt take up the whole screen.
		var fontSize = Std.int(FlxG.width / 50) + 10;

		super(0, 0, 0, string);
		this.setFormat(font, fontSize, color);
		this.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4);
	}
}
