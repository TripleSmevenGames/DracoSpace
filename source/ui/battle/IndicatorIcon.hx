package ui.battle;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import ui.TooltipLayer;
import utils.ViewUtils;

using utils.ViewUtils;

enum TooltipPlace
{
	BATTLE;
	INV;
}

typedef IndicatorIconOptions =
{
	?scale:Int,
	?fontSize:Int,
	?color:FlxColor,
	?centered:Bool,
	?outlined:Bool,
	?display:Bool,
	?place:TooltipPlace,
	?tooltipOptions:TooltipOptions,
}

/** Use to generate an icon with optional number and tooltip on hover. It's centered. **/
class IndicatorIcon extends FlxSpriteGroup
{
	public var icon:FlxSprite;
	public var name:Null<String>;
	public var desc:Null<String>;

	var display:FlxText;
	var tooltip:Tooltip;
	var options:IndicatorIconOptions;

	function getDefaultOptions(?options:IndicatorIconOptions)
	{
		if (options == null)
			options = {};

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
		if (options.display == null)
			options.display = true;
		if (options.place == null)
			options.place = BATTLE;
		if (options.tooltipOptions == null)
			options.tooltipOptions = {};

		return options;
	}

	public function updateDisplay(val:String)
	{
		if (display != null)
			display.text = val;
	}

	public function updateTooltipDesc(val:String)
	{
		if (tooltip != null)
			tooltip.updateDesc(val);
	}

	/** Register the tooltip after its made, re-register the tooltip if it got destroyed (by say a cleanup function of a state). 
	 * Keep in mind this makes a new tooltip sprite every time, so calling this many times is going to create a memory leak.
	**/
	public function registerTooltip()
	{
		icon.addScaledToMouseManager();
		tooltip = Tooltip.genericTooltip(name, desc, options.tooltipOptions);
		if (options.place == BATTLE || options.place == null)
			GameController.battleTooltipLayer.registerTooltip(tooltip, icon);
		else if (options.place == INV)
			GameController.invTooltipLayer.registerTooltip(tooltip, icon);
		else
			trace('invalid options.place');
	}

	public function new(spritePath:FlxGraphicAsset, ?name:String, ?desc:String, options:IndicatorIconOptions)
	{
		super(0, 0);

		this.name = name;
		this.desc = desc;
		this.options = getDefaultOptions(options);

		icon = new FlxSprite(0, 0, spritePath);
		icon.scale.set(options.scale, options.scale);
		icon.updateHitbox();
		ViewUtils.centerSprite(icon);
		add(icon);

		if (options.display)
		{
			display = new FlxText(0, 0, icon.width, '0');
			display.setFormat(Fonts.NUMBERS_FONT, options.fontSize, options.color, 'center');
			if (options.centered)
				ViewUtils.centerSprite(display);
			if (options.outlined)
				display.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);

			add(display);
		}
	}

	/* helper functions below */
	//
	//

	/** Create an small info indicator. It has a blue sprite with an 'i', and is good for showing a small hint. **/
	public static function createInfoIndicator(infoTitle = '', infoText = '', place:TooltipPlace = INV, width = 350)
	{
		var options:IndicatorIconOptions = {
			tooltipOptions: {width: width},
			display: false,
			place: place,
		};

		var infoTextIcon = new IndicatorIcon(AssetPaths.info__png, infoTitle, infoText, options);
		return infoTextIcon;
	}
}
