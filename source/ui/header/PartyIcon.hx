package ui.header;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.player.Player;

using utils.ViewUtils;

/** Centered Y, but not X.
 * Clicking this goes to the Party screen (aka the Equipment screen)
**/
class PartyIcon extends FlxSpriteGroup
{
	var text:FlxText;

	public function new()
	{
		super();
		this.text = new FlxText(0, 0, 0, 'PARTY');
		text.setFormat(Fonts.STANDARD_FONT3, 40, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		text.centerY();
		add(text);

		text.addScaledToMouseManager();
		var onClick = (sprite:FlxSprite) -> GameController.subStateManager.toggleInventory(EQUIP);
		FlxMouseEventManager.setMouseClickCallback(text, onClick);

		// set the hover effect so it slightly fades when you hover
		FlxMouseEventManager.setMouseOverCallback(text, (_) ->
		{
			text.alpha = .5;
		});
		FlxMouseEventManager.setMouseOutCallback(text, (_) ->
		{
			text.alpha = 1;
		});
	}
}
