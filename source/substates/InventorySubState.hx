package substates;

import constants.Colors;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import ui.buttons.BasicWhiteButton;
import ui.header.Header;
import ui.inventory.InventoryMenu;
import utils.GameController;

using utils.ViewUtils;

// a substate containing the event view
class InventorySubState extends FlxSubState
{
	var menu:InventoryMenu;

	public function cleanup()
	{
		if (menu != null)
		{
			menu.destroy();
		}
		remove(menu);
		menu = null;
	}

	override public function create()
	{
		super.create();

		var backgroundGradient = [Colors.INVENTORY_GRADIENT_TOP, Colors.INVENTORY_GRADIENT_BOT];
		var background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, backgroundGradient, 8);
		this.add(background);

		this.menu = new InventoryMenu();
		this.menu.scrollFactor.set(0, 0);
		menu.setPosition(FlxG.width / 2, FlxG.height / 2);
		add(menu);

		var header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);

		var backBtn = new BasicWhiteButton('Back', () -> GameController.subStateManager.returnToPreviousFromInv());
		backBtn.centerSprite(FlxG.width - 200, FlxG.height - 200);
		add(backBtn);
	}
}
