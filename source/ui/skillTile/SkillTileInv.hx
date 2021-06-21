package ui.skillTile;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.skills.Skill;

using utils.ViewUtils;

/** A modified SkillTile to include a hover effect. Appears in the inventory. **/
class SkillTileInv extends SkillTile
{
	public function new(skill:Skill, equipCoverText = '')
	{
		super(skill, true);
		var equipCover = new SkillTileEquipCover(equipCoverText);
		add(equipCover);
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

		FlxMouseEventManager.setMouseOverCallback(body, (_) -> hoverGroup.visible = true);
		FlxMouseEventManager.setMouseOutCallback(body, (_) -> hoverGroup.visible = false);
	}
}
