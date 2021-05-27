package ui.battle;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.skills.Skill;
import ui.TooltipLayer.Tooltip;
import ui.battle.IndicatorIcon.TooltipPlace;
import utils.ViewUtils;

using utils.ViewUtils;

/** Combines the skill art and its border. Centered by default.
 * After add()'ing it, you may call setupHover() to setup the skillCard hover.
**/
class SkillTile extends FlxSpriteGroup
{
	public var skill:Skill;

	// because of a bug with get_width and spriteGroups, we'll just "hardcode" it to be correct.
	// https://github.com/HaxeFlixel/flixel/issues/2305
	var realWidth:Float;
	var realHeight:Float;

	/** Art width and height (the icon inside the border)**/
	public var artWAndH = 16 * 3;

	var equipCover:SkillTileEquipCover;

	override public function get_width()
	{
		return realWidth;
	}

	override public function get_height()
	{
		return realHeight;
	}

	public function setupHover(?place:TooltipPlace)
	{
		// set mouseChildren to true so that we can trigger the skillcard hover and the equip hover
		// this means that the hover's mousChildren MUST be true also!
		this.addScaledToMouseManager(true);
		if (place == BATTLE || place == null)
			GameController.battleTooltipLayer.createTooltipForSkillTile(this);
		else if (place == INV)
			GameController.invTooltipLayer.createTooltipForSkillTile(this);
	}

	public function new(skill:Null<Skill>, centered:Bool = true, ?equipCoverText:Null<String>)
	{
		super();
		this.skill = skill;

		var spritePath = skill != null ? skill.spritePath : AssetPaths.unknownSkill__png;
		var type = skill != null ? skill.type : ANY;

		var art = new FlxSprite(0, 0, spritePath);
		var border = ViewUtils.getBorderForType(type);

		art.scale3x();
		if (centered)
			art.centerSprite();
		else
			art.setPosition(3, 3); // shift 1 pixels times the 3x scaling
		add(art);

		border.scale3x();
		if (centered)
			border.centerSprite();
		add(border);

		realWidth = border.width;
		realHeight = border.height;

		if (equipCoverText != null)
		{
			equipCover = new SkillTileEquipCover(equipCoverText);
			add(equipCover);
		}
	}
}

class SkillTileBlank extends FlxSpriteGroup
{
	public function new(centered:Bool = true)
	{
		super();

		var sprite = new FlxSprite(0, 0, AssetPaths.blankSkill__png);
		sprite.scale3x();

		if (centered)
			sprite.centerSprite();

		add(sprite);
	}
}

class SkillTileLocked extends FlxSpriteGroup
{
	public function setupHover(?place:TooltipPlace)
	{
		this.addScaledToMouseManager();
		var tooltip = Tooltip.genericTooltip('Locked', null, {width: 0});
		if (place == BATTLE || place == null)
			GameController.battleTooltipLayer.registerTooltip(tooltip, this, true);
		else if (place == INV)
			GameController.invTooltipLayer.registerTooltip(tooltip, this, true);
	}

	public function new(centered:Bool = true)
	{
		super();

		var sprite = new FlxSprite(0, 0, AssetPaths.lockedSkill__png);
		sprite.scale3x();

		if (centered)
			sprite.centerSprite();

		add(sprite);
	}
}

/** Render this ontop of a skillTile. It's really just an invisible sprite that shows a "LMB (Un)equip" hint on top of itself when hovered. **/
class SkillTileEquipCover extends FlxSpriteGroup
{
	static final w = 18 * 3;
	static final h = 18 * 3;

	// might say "LMB to equip" or "LMB to unequip"
	var equipHint:FlxSprite;
	var equip:Bool;

	/** modified version of ViewUtils.getClickToSomethingText to be vertical and centered. **/
	public static function getClickToSomethingText(something:String = '')
	{
		var group = new FlxSpriteGroup();

		var lmbIcon = new FlxSprite(0, 0, AssetPaths.LMB__png);
		lmbIcon.scale2x();
		lmbIcon.centerSprite(0, -(lmbIcon.height / 2) + 4);
		group.add(lmbIcon);

		var buyText = new FlxText(0, 0, 0, something);
		buyText.setFormat(Fonts.STANDARD_FONT2, 18);
		buyText.centerSprite(0, lmbIcon.height / 2);
		group.add(buyText);

		return group;
	}

	/** Centered. **/
	function getHoverGroup(equipCoverText = 'Equip')
	{
		// make the actual hover part;
		var hoverGroup = new FlxSpriteGroup();
		var bg = new FlxSprite();
		bg.makeGraphic(w, h, FlxColor.fromRGB(0, 0, 0, 128), true);
		bg.centerSprite();
		hoverGroup.add(bg);

		equipHint = getClickToSomethingText(equipCoverText);
		hoverGroup.add(equipHint);

		return hoverGroup;
	}

	public function new(equipCoverText = 'Equip')
	{
		super();
		// this will be a dummy sprite that is just used as a trigger area for the hover.
		var body = new FlxSprite();
		body.makeGraphic(w, h, FlxColor.TRANSPARENT, true);
		// make mouseChildren true, so that you can trigger this hover AND the skillTile's hover at the same time.
		// this means that the skillTiles mousChildren MUST be true also!
		body.addScaledToMouseManager(true);
		body.centerSprite();
		add(body);

		// make the actual hover part;
		var hoverGroup = getHoverGroup(equipCoverText);
		hoverGroup.visible = false;
		add(hoverGroup);

		FlxMouseEventManager.setMouseOverCallback(body, (_) ->
		{
			hoverGroup.visible = true;
		});
		FlxMouseEventManager.setMouseOutCallback(body, (_) -> hoverGroup.visible = false);
	}
}
