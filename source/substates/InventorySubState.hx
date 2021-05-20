package substates;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.IndicatorIcon;
import ui.buttons.BasicWhiteButton;
import ui.header.Header;
import ui.inventory.InventoryMenu2;
import ui.inventory.InventoryMenu3;
import ui.inventory.SkillShop;
import utils.GameController;

using utils.ViewUtils;

// a substate containing the event view
class InventorySubState extends FlxSubState
{
	var header:Header;

	var menu:InventoryMenu3;
	var shop:SkillShop;
	var shopButton:BasicWhiteButton;

	public function cleanup()
	{
		if (menu != null)
			menu.destroy();
		if (shop != null)
			shop.destroy();

		remove(menu);
		remove(shop);
		shop = null;
		menu = null;
	}

	/** Call this when we switch to this state. We cleanup tooltips (to prevent memory leaks), so make sure to re-init tooltips. **/
	public function init()
	{
		GameController.invTooltipLayer.cleanUpTooltips();

		initMenu();
		initShop();
		header.refresh();
		menu.revive();

		// create the tooltip layer, which is where all tooltips will be added to.
		// remove then add it, to ensure it is at the top of the render stack.
		remove(GameController.invTooltipLayer);
		add(GameController.invTooltipLayer);

		FlxG.camera.scroll.x = 0;
		if (shopButton != null)
			shopButton.label.text = 'Shop';
	}

	/** Destroys the old menu and makes a new one. Might be a bit expensive, so only call this when we switch to this state. 
	 * Don't call this while the user is in the iss, probably too expensive.
	**/
	public function initMenu()
	{
		if (this.menu != null)
		{
			remove(this.menu);
			this.menu.destroy();
		}
		this.menu = new InventoryMenu3(header.height);
		this.menu.scrollFactor.set(0, 0);
		add(menu);
		menu.kill(); // turn off at first
	}

	/** Destroys the old shop and makes a new one. Might be a bit expensive, so only call this when we switch to this state. 
	 * Don't call this while the user is in the iss, probably too expensive.
	**/
	public function initShop()
	{
		if (shop != null)
		{
			remove(shop);
			shop.destroy();
		}
		shop = new SkillShop();
		shop.setPosition(FlxG.width / 2, header.height + 64);
		shop.scrollFactor.set(0, 0);
		add(shop);
		shop.kill(); // turn off at first
	}

	public function toggleScreens()
	{
		// you must refresh the menu first. If you refresh after calling menu.kill(),
		// the menu group will be killed, but refereshing will create and add new members to it, which are not killed.
		// so they will still receive mouse events (but wont be visible, b/c the parent group is killed, I think).
		menu.refresh();
		shop.refresh();

		if (!menu.alive)
		{
			menu.revive();
			shop.kill();
			shopButton.label.text = 'Shop';
		}
		else
		{
			menu.kill();
			shop.revive();
			shopButton.label.text = 'Party';
		}
	}

	public function refreshHeader()
	{
		header.refresh();
	}

	override public function create()
	{
		super.create();

		var backgroundGradient = [Colors.INVENTORY_GRADIENT_TOP, Colors.INVENTORY_GRADIENT_BOT];
		var background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, backgroundGradient, 8);
		background.scrollFactor.set(0, 0);
		this.add(background);

		this.header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);

		var backBtn = new BasicWhiteButton('Back', () -> GameController.subStateManager.toggleInventory());
		backBtn.centerSprite(FlxG.width - 200, FlxG.height - 100);
		add(backBtn);

		this.shopButton = new BasicWhiteButton('Shop', toggleScreens);
		shopButton.centerSprite(FlxG.width - 200, FlxG.height - 50);
		add(shopButton);
	}
}
