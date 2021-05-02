package substates;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.BattleIndicatorIcon;
import ui.buttons.BasicWhiteButton;
import ui.header.Header;
import ui.inventory.InventoryMenu2;
import utils.GameController;

using utils.ViewUtils;

// a substate containing the event view
class InventorySubState extends FlxSubState
{
	var header:Header;
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

	public function initMenu()
	{
		if (this.menu != null)
		{
			remove(this.menu);
			this.menu.destroy();
		}
		this.menu = new InventoryMenu2(header.height);
		this.menu.scrollFactor.set(0, 0);
		add(menu);
	}

	override public function create()
	{
		super.create();

		var backgroundGradient = [Colors.INVENTORY_GRADIENT_TOP, Colors.INVENTORY_GRADIENT_BOT];
		var background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, backgroundGradient, 8);
		this.add(background);

		this.header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);

		initMenu();

		var infoText = 'Click on skills to equip or unequip them on your characters. '
			+ 'Only equipped skills can be used during battle. Most skills, but not all, are character-specific.';
		var options:BattleIndicatorIconOptions = {
			width: 400,
			display: false,
			place: INV,
		};

		var infoTextIcon = new BattleIndicatorIcon(AssetPaths.info__png, 'Skill Equipment Menu', infoText, options);
		infoTextIcon.setPosition(FlxG.width - 200, FlxG.height - 100);
		add(infoTextIcon);
		var backBtn = new BasicWhiteButton('Back', () -> GameController.subStateManager.toggleInventory());
		backBtn.centerSprite(FlxG.width - 200, FlxG.height - 50);
		add(backBtn);

		// create the tooltip layer, which is where all tooltips will be added to.
		// this lets them be rendered on top of the inv view.
		add(GameController.invTooltipLayer);
	}
}
