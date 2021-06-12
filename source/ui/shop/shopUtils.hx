package ui.shop;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using utils.ViewUtils;

class ShopUtils
{
	static function getItemPriceSprite(price:Int, sale:Bool = false)
	{
		var group = new FlxSpriteGroup();

		var textSprite = new FlxText(0, 0, 0, Std.string(price));
		textSprite.setFormat(Fonts.STANDARD_FONT, 32, sale ? FlxColor.YELLOW : FlxColor.WHITE);
		textSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		group.add(textSprite);

		var coinSprite = new FlxSprite(0, 0, AssetPaths.Coin__png);
		coinSprite.scale2x();
		coinSprite.setPosition(textSprite.width + 4, 0);
		group.add(coinSprite);

		return group;
	}
}
