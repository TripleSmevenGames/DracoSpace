package ui.inventory.equipmentMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import openfl.geom.Rectangle;
import ui.battle.win.SkillCard;
import ui.skillTile.InventorySkillTile;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered on the body**/
class UnequippedSkillsList3 extends FlxSpriteGroup
{
	public var skillTiles:Array<SkillTile> = [];
	public final bodyHeight = 120;
	public final bodyWidth = 600; // about 10 tiles?

	var blankTiles:Array<SkillTileBlank> = [];
	var body:FlxSprite;

	/** A trigger zone for dropping artifacts and skills into, which will unequip them. 
	 * The parent of this component will control that.
	**/
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
			// dont destroy the blank tiles, just remove them because we can reuse them.
			remove(blankTile);
		}
		skillTiles = [];

		// then, re render them again according to the current data.
		// the ypos positions them so the are near the bottom of the body.
		var numSkills = Player.inventory.unequippedSkills.length;
		var maxTiles = Player.MAX_UNEQUIPPED_SKILLS;
		var yPos = body.height / 2 - 40;
		for (i in 0...maxTiles)
		{
			if (i < numSkills)
			{
				var skill = Player.inventory.unequippedSkills[i];
				var skillTile = new InventorySkillTile(skill, 'Equip');
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, skillTile.width, 4);
				skillTile.setPosition(xPos, yPos);
				skillTiles.push(skillTile);
				add(skillTile);
				skillTile.setupHover(INV);
			}
			else
			{
				var skillTileBlank = blankTiles[i]; // take a blank tile from the store
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, skillTileBlank.width, 4);
				skillTileBlank.setPosition(xPos, yPos);
				add(skillTileBlank);
			}
		}
	}

	public function new()
	{
		super();

		this.body = ViewUtils.newSlice9(AssetPaths.greyBlue_dark__png, bodyWidth, bodyHeight, [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED SKILLS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		title.centerSprite();
		title.y -= (body.height - title.height) / 2; // position it inside the body at the top.
		add(title);

		// create the store of blank tiles to use.
		for (i in 0...Player.MAX_UNEQUIPPED_SKILLS)
		{
			var blankTile = new SkillTileBlank();
			blankTiles.push(blankTile);
		}

		// call this to initially render the unequipped skill tiles.
		refresh();
	}
}
