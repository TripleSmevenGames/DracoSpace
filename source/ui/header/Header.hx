package ui.header;

import constants.Colors;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import models.player.Player;

using utils.ViewUtils;

class Header extends FlxSpriteGroup
{
	var body:FlxSprite;
	var displays:Array<CharacterDisplay> = [];

	/** Refresh the HP numbers so that they are accurate. **/
	public function refresh()
	{
		for (display in displays)
			display.refresh();
	}

	public function new()
	{
		super(0, 0);

		body = new FlxSprite(0, 0);
		body.makeGraphic(FlxG.width, 100, FlxColor.fromRGB(200, 200, 200, 150));
		add(body);

		var charDisplay1 = new CharacterDisplay(Player.chars[0]);
		charDisplay1.setPosition(100, body.height / 2);
		add(charDisplay1);

		displays.push(charDisplay1);

		var charDisplay2 = new CharacterDisplay(Player.chars[1]);
		charDisplay2.setPosition(300, body.height / 2);
		add(charDisplay2);

		displays.push(charDisplay1);
		displays.push(charDisplay2);
	}
}
