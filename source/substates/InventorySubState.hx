package substates;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import ui.buttons.BasicWhiteButton;
import ui.header.Header;
import ui.inventory.InventoryMenu2;
import utils.GameController;

using utils.ViewUtils;

// a substate containing the event view
class InventorySubState extends FlxSubState
{
	var menu:InventoryMenu2;

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

		var header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);

		this.menu = new InventoryMenu2(header.height);
		this.menu.scrollFactor.set(0, 0);
		add(menu);

		var infoText = new FlxText(0, 0, 400);
		infoText.text = 'Click on skills to equip or unequip them on your characters.
			Only equipped skills can be used during battle. Most skills, but not all, can only be used by certain characters.';
		infoText.setFormat(Fonts.STANDARD_FONT2, 18, FlxColor.WHITE, 'center');
		infoText.centerSprite(FlxG.width - 250, FlxG.height - 200);
		add(infoText);

		var backBtn = new BasicWhiteButton('Back', () -> GameController.subStateManager.returnToPreviousFromInv());
		backBtn.centerSprite(FlxG.width - 200, FlxG.height - 50);
		add(backBtn);
	}
}
