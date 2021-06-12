package ui.header;

import flixel.input.mouse.FlxMouseEventManager;
import managers.GameController;
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
class ShopIcon extends FlxSpriteGroup
{
	var text:FlxText;

	public function new()
	{
		super();
		this.text = new FlxText(0, 0, 0, 'SHOP');
		text.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE_MED, Colors.XP_PURPLE, FlxTextAlign.CENTER);
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);
		text.centerY();
		add(text);

		text.addScaledToMouseManager();
		var onClick = (sprite:FlxSprite) -> GameController.subStateManager.toggleInventory(SHOP);
		FlxMouseEventManager.setMouseClickCallback(text, onClick);
	}
}
