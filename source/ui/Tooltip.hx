package ui;

import constants.Constants.Colors;
import constants.Constants.UIMeasurements;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.ViewUtils;

// TODO: might need a global tooltip layer, to let all tooltips overlap every thing else on the screen;

/** The tooltip you see when you hover over a skill tile **/
class Tooltip extends FlxSpriteGroup
{
	static inline final WIDTH = 150;

	/**
	 * If you call this before adding the tooltip to your group, make sure you are passing in local coords.
	 *
	 * Else, pass in global coords.
	 */
	public function centerAboveParent(parent:FlxObject)
	{
		ViewUtils.centerSprite(this, parent.x + parent.width / 2, parent.y - this.height / 2 - 8);
	}

	/** Uses the mouseEventManager to set mouse in/out callbacks on the parent. Assumes you added the parent to the manager already. **/
	public function bindTo(parent:FlxObject)
	{
		FlxMouseEventManager.setMouseOverCallback(parent, (_) -> this.visible = true);
		FlxMouseEventManager.setMouseOutCallback(parent, (_) -> this.visible = false);
	}

	public function new(name:Null<String>, desc:Null<String>)
	{
		super(0, 0);

		var fontSize = UIMeasurements.BATTLE_UI_FONT_SIZE_SM;
		var paddingVertical = 6;
		var paddingSide = 4;

		var body = new FlxSprite(0, 0);
		add(body);

		var bodyHeight:Float = 0;

		if (name != null)
		{
			var nameText = new FlxText(paddingSide, paddingVertical, WIDTH, name);
			nameText.setFormat(AssetPaths.DOSWin__ttf, fontSize + 1, FlxColor.WHITE, 'center');
			bodyHeight += nameText.height;
			add(nameText);
		}

		if (desc != null)
		{
			var descText = new FlxText(paddingSide, bodyHeight + paddingVertical, WIDTH, desc);
			descText.setFormat(AssetPaths.DOSWin__ttf, fontSize);
			bodyHeight += descText.height;
			add(descText);
		}

		// adjust the body based on the height its content
		body.makeGraphic(WIDTH + paddingSide * 2, Std.int(bodyHeight + paddingVertical), Colors.BACKGROUND_BLUE);
		// then make it slightly see-through
		body.alpha = .75;

		this.visible = false;
	}
}
