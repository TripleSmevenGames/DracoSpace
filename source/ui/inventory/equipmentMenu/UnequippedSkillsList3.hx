package ui.inventory.equipmentMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import ui.battle.win.SkillCard;
import ui.skillTile.InventorySkillTile;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered on the body**/
class UnequippedSkillsList3 extends FlxSpriteGroup
{
	public var skillTiles:Array<SkillTile> = [];
	public final bodyHeight = 72;
	public final bodyWidth = 180; // about 10 tiles?
	public final maxTiles = 8;

	var blankTiles:Array<SkillTileBlank> = [];

	/** rerender the list to show the current unequipped skills.
	 * Because we are removing the old tiles and calling setupHover() on the new tiles
	 * without cleaning up the old tooltips, this is technically a memory leak.
	 * We'll cleanup the tooltips when we switch states though.
	**/
	public function refresh()
	{
		// first, remove all the skill tiles
		// maybe slow?
		for (skillTile in skillTiles)
		{
			remove(skillTile);
			skillTile.destroy();
		}
		for (blankTile in blankTiles)
		{
			remove(blankTile);
			blankTile.destroy();
		}
		skillTiles = [];
		blankTiles = [];

		// then, re render them again according to the current data.
		var numSkills = Player.inventory.unequippedSkills.length;
		for (i in 0...maxTiles)
		{
			if (i < numSkills)
			{
				var skill = Player.inventory.unequippedSkills[i];
				var skillTile = new InventorySkillTile(skill, 'Equip');
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, skillTile.width, 4);
				skillTile.setPosition(xPos, 0);
				skillTiles.push(skillTile);
				add(skillTile);
				skillTile.setupHover(INV);
			}
			else
			{
				var skillTileBlank = new SkillTileBlank();
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, skillTileBlank.width, 4);
				skillTileBlank.setPosition(xPos, 0);
				blankTiles.push(skillTileBlank);
				add(skillTileBlank);
			}
		}
	}

	public function new()
	{
		super();

		var bodyWidth = FlxG.width / 2;
		var body = ViewUtils.newSlice9(AssetPaths.greyBlue_dark__png, bodyWidth, bodyHeight, [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED SKILLS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		title.centerSprite();
		title.y -= (body.height + title.height) / 2;
		add(title);

		// call this to initially render the unequipped skill tiles.
		refresh();
	}
}
