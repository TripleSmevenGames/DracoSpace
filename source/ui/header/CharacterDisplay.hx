package ui.header;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.CharacterInfo;

using utils.ViewUtils;

/** Centered on Y only, x starts at the left side.
 * Shows something like 20/30, coloring the numbers based on % hp.
**/
class HpDisplay extends FlxSpriteGroup
{
	var valText:FlxText;
	var slashText:FlxText;
	var maxText:FlxText;

	var shouldRefresh:Bool = false;

	public function refresh(val:Int, max:Int)
	{
		if (valText == null || slashText == null || maxText == null)
			return;

		// set the text and color.
		valText.text = Std.string(val);
		valText.color = FlxColor.GREEN;
		var percent = val / max;
		if (percent < .25)
			valText.color = FlxColor.RED;
		else if (percent < .75)
			valText.color = FlxColor.ORANGE;

		maxText.text = Std.string(max);

		// set position.
		var cursor = this.x; // we are not in global coords since these texts are added already.

		valText.setPosition(cursor, this.y);
		valText.centerY(this.y);
		cursor += Std.int(valText.width);

		slashText.setPosition(cursor, this.y);
		slashText.centerY(this.y);
		cursor += Std.int(slashText.width);

		maxText.setPosition(cursor, this.y);
		maxText.centerY(this.y);
	}

	public function new(val:Int, max:Int, ?fontSize = 24)
	{
		super(0, 0);

		valText = new FlxText(0, 0, 0, 'abcde');
		valText.setFormat(Fonts.NUMBERS_FONT, fontSize);
		valText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);

		slashText = new FlxText(0, 0, 0, '/');
		slashText.setFormat(Fonts.NUMBERS_FONT, fontSize, FlxColor.BLACK, 'center');
		slashText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);

		maxText = new FlxText(0, 0, 0, 'abcde');
		maxText.setFormat(Fonts.NUMBERS_FONT, fontSize, FlxColor.GREEN, 'center');
		maxText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);

		add(valText);
		add(slashText);
		add(maxText);

		refresh(val, max);
	}
}

/** Shows chibi icon and hp. Centered on the chibi icon. **/
class CharacterDisplay extends FlxSpriteGroup
{
	var char:CharacterInfo;
	var hpDisplay:HpDisplay;

	public function refresh()
	{
		hpDisplay.refresh(char.currHp, char.maxHp);
	}

	public function new(char:CharacterInfo)
	{
		super(0, 0);

		this.char = char;

		var avatar = new FlxSprite(0, 0, char.avatarPath);
		avatar.scale3x();
		avatar.centerSprite();

		hpDisplay = new HpDisplay(char.currHp, char.maxHp);
		hpDisplay.setPosition(avatar.width / 2, 0); // don't center Y cuz the sprites are already centered.

		add(avatar);
		add(hpDisplay);

		refresh();
	}
}
