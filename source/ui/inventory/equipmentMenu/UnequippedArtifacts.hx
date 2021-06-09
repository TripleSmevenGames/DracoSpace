package ui.inventory.equipmentMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import openfl.geom.Rectangle;
import ui.artifact.ArtifactTileInv;
import ui.battle.win.SkillCard;
import ui.skillTile.InventorySkillTile;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered on the body**/
class UnequippedArtifacts extends FlxSpriteGroup
{
	public var artifactTiles:Array<ArtifactTileInv> = [];
	public final bodyHeight = 72;
	public final bodyWidth = 180; // about 10 tiles?

	// save the blank tiles so we can reuse them when we refresh
	var blankTiles:Array<SkillTileBlank> = [];

	/** rerender the list to show the current unequipped skills.
	 * Because we are removing the old tiles and calling setupHover() on the new tiles
	 * without cleaning up the old tooltips, this is technically a memory leak.
	 * We'll cleanup the tooltips when we switch states though.
	 * Maybe slow because lots of destroying and creating.
	**/
	public function refresh()
	{
		// first, remove all the skill tiles
		// maybe slow?
		for (tile in artifactTiles)
		{
			remove(tile);
			tile.destroy();
		}
		for (blankTile in blankTiles)
		{
			// dont destroy the blank tiles, just remove them because we can reuse them.
			remove(blankTile);
		}
		artifactTiles = [];

		// then, re render them again according to the current data.
		var numSkills = Player.inventory.unequippedSkills.length;
		var maxTiles = Player.MAX_UNEQUIPPED_ARTIFACTS;
		for (i in 0...maxTiles)
		{
			if (i < numSkills)
			{
				var artifact = Player.inventory.unequippedArtifacts[i];
				var artifactTile = new ArtifactTileInv(artifact);
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, artifactTile.width, 4);
				artifactTile.setPosition(xPos, 0);
				artifactTiles.push(artifactTile);
				add(artifactTile);
				artifactTile.setupHover();
			}
			else
			{
				var blankTile = blankTiles[i]; // take a blank tile from the store
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, blankTile.width, 4);
				blankTile.setPosition(xPos, 0);
				add(blankTile);
			}
		}
	}

	public function new()
	{
		super();

		var bodyWidth = FlxG.width / 2;
		var body = ViewUtils.newSlice9(AssetPaths.greyTeal__png, bodyWidth, bodyHeight, [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED ARTIFACTS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		title.centerSprite();
		title.y -= (body.height + title.height) / 2;
		add(title);

		// create the store of blank tiles to use.
		for (i in 0...Player.MAX_UNEQUIPPED_ARTIFACTS)
		{
			var blankTile = new SkillTileBlank();
			blankTiles.push(blankTile);
		}

		// call this to initially render the unequipped artifact tiles.
		refresh();
	}
}
