package ui.battle;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import ui.TooltipLayer;
import utils.GameController;
import utils.ViewUtils;

typedef BattleIndicatorIconOptions =
{
	?scale:Float,
	?fontSize:Int,
	?color:FlxColor,
	?centered:Bool,
	?outlined:Bool,
	?tooltipPos:TooltipPos
}

/** Use to generate an icon with a number and tooltip on hover. Use for battles. It's centered. **/
class BattleIndicatorIcon extends FlxSpriteGroup
{
	public var icon:FlxSprite;

	var display:FlxText;
	var tooltip:Tooltip;

	function getDefaultOptions(options:BattleIndicatorIconOptions)
	{
		if (options.scale == null)
			options.scale = 2;
		if (options.fontSize == null)
			options.fontSize = UIMeasurements.BATTLE_UI_FONT_SIZE_MED;
		if (options.color == null)
			options.color = FlxColor.WHITE;
		if (options.centered == null)
			options.centered = false;
		if (options.outlined == null)
			options.outlined = false;
		if (options.tooltipPos == null)
			options.tooltipPos = TOP;

		return options;
	}

	public function updateDisplay(val:String)
	{
		display.text = val;
	}

	public function new(spritePath:FlxGraphicAsset, ?name:String, ?desc:String, options:BattleIndicatorIconOptions)
	{
		super(0, 0);

		options = getDefaultOptions(options);

		icon = new FlxSprite(0, 0, spritePath);
		icon.scale.set(options.scale, options.scale);
		icon.updateHitbox();
		ViewUtils.centerSprite(icon);
		add(icon);

		display = new FlxText(0, 0, icon.width, '0');
		display.setFormat(Fonts.NUMBERS_FONT, options.fontSize, options.color, 'center');
		if (options.centered)
			ViewUtils.centerSprite(display);
		if (options.outlined)
			display.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);

		add(display);

		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		FlxMouseEventManager.add(icon, null, null, null, null, false, true, false);

		tooltip = Tooltip.genericTooltip(name, desc, options.tooltipPos);
		GameController.battleTooltipLayer.registerTooltip(tooltip, icon);
	}
}
