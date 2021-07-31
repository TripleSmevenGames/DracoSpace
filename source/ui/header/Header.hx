package ui.header;

import constants.Colors;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import managers.GameController;
import models.player.Player;

using utils.ViewUtils;

/** Header that appears on the map, inv, and event states.
 * Allows player to see their hp, xp, and acess party/shop menus.
 * Not centered.
**/
class Header extends FlxSpriteGroup
{
	var body:FlxSprite;
	var displays:Array<CharacterDisplay> = [];
	var xpDisplay:XPDisplay;
	var moneyDisplay:MoneyDisplay;

	var cursor:Float = 100;

	static inline final padding = 50;
	static inline final HEIGHT = 100;

	/** Refresh the HP numbers so that they are accurate. **/
	public function refresh()
	{
		for (display in displays)
			display.refresh();

		moneyDisplay.refresh();
		xpDisplay.refresh();
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
		body.makeGraphic(FlxG.width, HEIGHT, FlxColor.fromRGB(200, 200, 200, 150));
		add(body);

		var charDisplay1 = new CharacterDisplay(Player.chars[0]);
		addToView(charDisplay1);

		var charDisplay2 = new CharacterDisplay(Player.chars[1]);
		addToView(charDisplay2);

		displays.push(charDisplay1);
		displays.push(charDisplay2);

		this.xpDisplay = new XPDisplay();
		addToView(xpDisplay);

		this.moneyDisplay = new MoneyDisplay();
		addToView(moneyDisplay);

		// var inventoryIcon = new InventoryIcon();
		// addToView(inventoryIcon);

		var partyIcon = new PartyIcon();
		addToView(partyIcon);

		var shopIcon = new ShopIcon();
		addToView(shopIcon);
	}
}
