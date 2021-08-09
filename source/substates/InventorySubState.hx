package substates;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import managers.GameController;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.IndicatorIcon;
import ui.buttons.BasicWhiteButton;
import ui.header.Header;
import ui.inventory.equipmentMenu.EquipmentMenu;
import ui.inventory.shopMenu.ShopMenu;

using utils.ViewUtils;

enum InvScreenType
{
	EQUIP;
	SHOP;
}

// a substate containing the event view
class InventorySubState extends FlxSubState
{
	var header:Header;

	var equipmentMenu:EquipmentMenu;
	var shopMenu:ShopMenu;

	/** button to toggle betwen shop or party screen**/
	var toggleButton:BasicWhiteButton;

	/** Which screen of the inv we are looking at, either Shop or party (aka equip). **/
	public var screenType:InvScreenType;

	public function cleanup()
	{
		if (equipmentMenu != null)
			equipmentMenu.destroy();
		if (shopMenu != null)
			shopMenu.destroy();

		remove(equipmentMenu);
		remove(shopMenu);
		equipmentMenu = null;
		shopMenu = null;
	}

	/** Call this when we switch to this state. We cleanup tooltips (to prevent memory leaks), so make sure to re-init tooltips. **/
	public function init(screenType:InvScreenType = EQUIP)
	{
		GameController.invTooltipLayer.cleanUpTooltips();

		initEquipment();
		initShop();

		if (header == null)
			this.header = GameController.header;

		add(header);
		// not sure why, but the FIRST time init is called, the header is invisible. So just call revive() on it.
		header.revive();
		header.refresh();

		// create the tooltip layer, which is where all tooltips will be added to.
		// remove then add it, to ensure it is at the top of the render stack.
		remove(GameController.invTooltipLayer);
		add(GameController.invTooltipLayer);

		FlxG.camera.scroll.x = 0;

		switchToScreen(screenType);
	}

	/** Destroys the old menu and makes a new one. Might be a bit expensive, so only call this when we switch to this state. 
	 * Don't call this while the user is in the iss, probably too expensive.
	**/
	public function initEquipment()
	{
		if (this.equipmentMenu != null)
		{
			remove(this.equipmentMenu);
			this.equipmentMenu.destroy();
		}
		this.equipmentMenu = new EquipmentMenu(header.height);
		this.equipmentMenu.scrollFactor.set(0, 0);
		add(equipmentMenu);
		equipmentMenu.kill(); // turn off at first
	}

	/** Destroys the old shop and makes a new one. Might be a bit expensive, so only call this when we switch to this state. 
	 * Don't call this while the user is in the iss, probably too expensive.
	**/
	public function initShop()
	{
		if (shopMenu != null)
		{
			remove(shopMenu);
			shopMenu.destroy();
		}
		shopMenu = new ShopMenu(header.height);
		shopMenu.scrollFactor.set(0, 0);
		add(shopMenu);
		shopMenu.kill(); // turn off at first
	}

	public function switchToScreen(type:InvScreenType = EQUIP)
	{
		this.screenType = type;
		if (type == EQUIP)
		{
			equipmentMenu.revive();
			shopMenu.kill();
			toggleButton.label.text = 'Shop';
		}
		else if (type == SHOP)
		{
			equipmentMenu.kill();
			shopMenu.revive();
			toggleButton.label.text = 'Party';
		}
	}

	/** Switch to the other screen.**/
	public function toggleScreens()
	{
		// you must refresh the menu first. If you refresh after calling menu.kill(),
		// the menu group will be killed, but refereshing will create and add new members to it, which are not killed.
		// so they will still receive mouse events (but wont be visible, b/c the parent group is killed, I think).
		equipmentMenu.refresh();
		shopMenu.refresh();

		if (!equipmentMenu.alive)
		{
			switchToScreen(EQUIP);
		}
		else
		{
			switchToScreen(SHOP);
		}
	}

	override public function create()
	{
		super.create();

		var backgroundGradient = [Colors.INVENTORY_GRADIENT_TOP, Colors.INVENTORY_GRADIENT_BOT];
		var background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, backgroundGradient, 8);
		background.scrollFactor.set(0, 0);
		this.add(background);

		this.header = GameController.header;

		var backBtn = new BasicWhiteButton('Back (ESC)', () -> GameController.subStateManager.toggleInventory(null), 150, 50);
		backBtn.centerSprite(FlxG.width - 200, FlxG.height - 175);
		add(backBtn);

		this.toggleButton = new BasicWhiteButton('Shop', toggleScreens, 150, 50);
		toggleButton.centerSprite(FlxG.width - 200, FlxG.height - 100);
		add(toggleButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			GameController.subStateManager.toggleInventory(null);

		if (FlxG.keys.justPressed.SPACE)
			toggleScreens();
	}
}
