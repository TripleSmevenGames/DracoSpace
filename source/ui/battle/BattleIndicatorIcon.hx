package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.ViewUtils;

/** Use to generate an icon with a number and tooltip on hover. Use for battles. **/
class BattleIndicatorIcon extends FlxSpriteGroup
{
	public var icon:FlxSprite;

	var display:FlxText;
	var tooltip:Tooltip;

	public function updateDisplay(val:String)
	{
		display.text = val;
	}

	public function new(spritePath:FlxGraphicAsset, scale:Float = 2, fontSize = 16, color:FlxColor = FlxColor.WHITE, ?name:String, ?desc:String)
	{
		super(0, 0);
		icon = new FlxSprite(0, 0, spritePath);
		icon.scale.set(scale, scale);
		icon.updateHitbox();
		add(icon);

		display = new FlxText(0, 0, icon.width, '0');
		display.setFormat(AssetPaths.DOSWin__ttf, fontSize, color, 'center');
		ViewUtils.centerSprite(display, icon.width / 2, icon.height / 2);
		add(display);

		tooltip = new Tooltip(name, desc);
		tooltip.centerAboveParent(icon);
		add(tooltip);

		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		FlxMouseEventManager.add(icon, null, null, null, null, null, null, false);
		tooltip.bindTo(icon);
	}
}
