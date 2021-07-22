package ui.shop;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.player.Player;

using utils.ViewUtils;

class ShopUtils
{
	public static function getItemPriceSprite(price:Int, sale:Bool = false)
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

	/** Get the int price for a skill, which is based off how many skills have already been bought this run. **/
	public static function getSkillPrice(sale = false):Int
	{
		var basePrice = 10;
		// each bought skill increases the price by about third the base price.
		// sales give half off.
		var multiplier = (Player.skillsBought / 3 + 1) * (sale ? 1 / 2 : 1);
		var modifier = GameController.rng.int(-3, 3);
		var finalPrice = (basePrice * multiplier) + modifier;

		if (finalPrice < 5)
			finalPrice = 5;

		return Std.int(finalPrice);
	}
}
