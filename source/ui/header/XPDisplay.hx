package ui.header;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;

using utils.ViewUtils;

/** Centered Y, but not X. **/
class XPDisplay extends FlxSpriteGroup
{
	var text:FlxText;

	public function refresh()
	{
		text.text = 'XP: ${Std.string(Player.exp)}';
	}

	public function new()
	{
		super();
		this.text = new FlxText(0, 0, 0, 'XP: 0');
		text.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE_MED, Colors.XP_PURPLE, FlxTextAlign.CENTER);
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);
		text.centerY();
		add(text);
	}
}
