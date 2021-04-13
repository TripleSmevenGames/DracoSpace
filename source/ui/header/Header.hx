package ui.header;

import constants.Colors;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import models.player.Player;
import utils.GameController;

using utils.ViewUtils;

class Header extends FlxSpriteGroup
{
	var body:FlxSprite;
	var displays:Array<CharacterDisplay> = [];
	// var expBarDisplay:ExpBarDisplay;
	var moneyDisplay:MoneyDisplay;

	var cursor:Float = 100;
	var padding = 50;

	/** Refresh the HP numbers so that they are accurate. **/
	public function refresh()
	{
		for (display in displays)
			display.refresh();

		moneyDisplay.refresh();
	}

	function addToView(sprite:FlxSprite)
	{
		sprite.setPosition(cursor, body.height / 2);
		add(sprite);
		cursor += sprite.width + padding;
	}

	public function new()
	{
		super(0, 0);

		body = new FlxSprite(0, 0);
		body.makeGraphic(FlxG.width, 100, FlxColor.fromRGB(200, 200, 200, 150));
		add(body);

		var charDisplay1 = new CharacterDisplay(Player.chars[0]);
		addToView(charDisplay1);

		var charDisplay2 = new CharacterDisplay(Player.chars[1]);
		addToView(charDisplay2);

		this.moneyDisplay = new MoneyDisplay();
		addToView(moneyDisplay);

		var inventoryIcon = new InventoryIcon();
		addToView(inventoryIcon);

		displays.push(charDisplay1);
		displays.push(charDisplay2);
	}
}
