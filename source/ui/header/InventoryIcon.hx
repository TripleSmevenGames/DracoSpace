package ui.header;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import utils.GameController;

using utils.ViewUtils;

/** The header icon. Click on it to access the inventory. Centered on the icon.**/
class InventoryIcon extends FlxSpriteGroup
{
	var openSprite:FlxSprite;
	var closeSprite:FlxSprite;

	public function new()
	{
		super();
		var closeSprite = new FlxSprite(0, 0, AssetPaths.inventoryIcon__png);
		closeSprite.scale.set(3, 3);
		closeSprite.updateHitbox();
		closeSprite.centerSprite();

		var openSprite = new FlxSprite(0, 0, AssetPaths.inventoryIconOpen__png);
		openSprite.scale.set(3, 3);
		openSprite.updateHitbox();
		openSprite.matchBottomCenter(closeSprite);
		openSprite.alpha = 0;

		FlxMouseEventManager.add(closeSprite, null, null, null, null, false, true, false);

		// set the onclick to move to the inventory state.
		var inventoryClick = (sprite:FlxSprite) -> GameController.subStateManager.toggleInventory();
		FlxMouseEventManager.setMouseClickCallback(closeSprite, inventoryClick);

		// set the onhover to show the open sprite.
		// we're not using visible = true/false, because visible = false counts as a mouseOut
		FlxMouseEventManager.setMouseOverCallback(closeSprite, (_) ->
		{
			openSprite.alpha = 1;
			closeSprite.alpha = 0;
		});
		FlxMouseEventManager.setMouseOutCallback(closeSprite, (_) ->
		{
			openSprite.alpha = 0;
			closeSprite.alpha = 1;
		});

		add(closeSprite);
		add(openSprite);
	}
}
