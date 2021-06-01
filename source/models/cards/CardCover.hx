package models.cards;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.ViewUtils;

class CardCover extends FlxSpriteGroup
{
	public function new()
	{
		super(0, 0);
		var body = new FlxSprite(0, 0);
		body.makeGraphic(UIMeasurements.CARD_WIDTH, UIMeasurements.CARD_HEIGHT, Colors.DARK_GRAY);
		add(body);

		var mark = new FlxText(0, 0, body.width, '?');
		mark.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG, FlxColor.WHITE, 'center');
		ViewUtils.centerSprite(mark, body.width / 2, body.height / 2);
		add(mark);
	}
}
