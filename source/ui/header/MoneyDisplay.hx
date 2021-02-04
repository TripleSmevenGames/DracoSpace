package ui.header;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;

using utils.ViewUtils;

/** Centered around the icon **/
class MoneyDisplay extends FlxSpriteGroup
{
	var moneyIcon:FlxSprite;
	var text:FlxText;

	public function refresh()
	{
		text.text = Std.string(Player.money);
	}

	public function new()
	{
		super();
		this.moneyIcon = new FlxSprite(0, 0, AssetPaths.Coin__png);
		moneyIcon.scale.set(3, 3);
		moneyIcon.updateHitbox();
		moneyIcon.centerSprite();
		add(moneyIcon);

		this.text = new FlxText(0, 0, 0, '0');
		text.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE_MED, FlxColor.YELLOW, FlxTextAlign.CENTER);
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		text.setPosition(moneyIcon.width / 2, 0);
		text.centerY();
		add(text);
	}
}
