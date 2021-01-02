package ui.header;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.CharacterInfo;

using utils.ViewUtils;

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
			valText.color = FlxColor.YELLOW;

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

		/*
			valText.drawFrame(true);
			slashText.drawFrame(true);
			maxText.drawFrame(true);
		 */
	}

	public function new(val:Int, max:Int)
	{
		super(0, 0);

		valText = new FlxText(0, 0, 0, 'abcde');
		valText.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE);
		valText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 3);

		slashText = new FlxText(0, 0, 0, '/');
		slashText.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE, FlxColor.BLACK, 'center');
		slashText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 3);

		maxText = new FlxText(0, 0, 0, 'abcde');
		maxText.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE, FlxColor.GREEN, 'center');
		maxText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 3);

		add(valText);
		add(slashText);
		add(maxText);

		refresh(val, max);
	}
}

/** Shows chibi icon and hp. **/
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
		avatar.scale.set(3, 3);
		avatar.updateHitbox();
		avatar.centerSprite();

		hpDisplay = new HpDisplay(char.currHp, char.maxHp);
		hpDisplay.setPosition(avatar.width / 2, 0); // don't center cuz the sprites will be centered.

		add(avatar);
		add(hpDisplay);

		refresh();
	}
}
