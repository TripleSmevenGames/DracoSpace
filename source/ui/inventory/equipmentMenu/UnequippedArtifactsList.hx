package ui.inventory.equipmentMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import ui.artifact.ArtifactTileInv;
import ui.inventory.equipmentMenu.DragLayer.DropZone;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered on the body**/
class UnequippedArtifactsList extends FlxSpriteGroup
{
	public var artifactTiles:Array<ArtifactTileInv> = [];
	public final bodyHeight = 120;
	public final bodyWidth = 600; // about 10 tiles?

	// save the blank tiles so we can reuse them when we refresh
	var blankTiles:Array<TileBlank> = [];

	var body:FlxSprite;

	/** A trigger zone for dropping artifacts and skills into, which will unequip them. 
	 * The parent of this component will control that.
	**/
	public var dropZone:DropZone;

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
		// the ypos positions them so the are near the bottom of the body.
		var numArtifacts = Player.inventory.unequippedArtifacts.length;
		var maxTiles = Player.MAX_UNEQUIPPED_ARTIFACTS;
		var yPos = body.height / 2 - 40;
		for (i in 0...maxTiles)
		{
			// first, render a blank tile
			var blankTile = blankTiles[i]; // take a blank tile from the store
			var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, blankTile.width, 4);
			blankTile.setPosition(xPos, yPos);
			add(blankTile);

			// then, if we have an artifact, render the artifact ontop of that blank tile.
			if (i < numArtifacts)
			{
				var artifact = Player.inventory.unequippedArtifacts[i];
				var artifactTile = new ArtifactTileInv(artifact);
				var xPos = ViewUtils.getXCoordForCenteringLR(i, maxTiles, artifactTile.width, 4);
				artifactTile.setPosition(xPos, yPos);
				artifactTiles.push(artifactTile);
				add(artifactTile);
				artifactTile.setupHover();
			}
		}
	}

	public function new(onDrop:FlxSprite->Void)
	{
		super();

		this.body = ViewUtils.newSlice9(AssetPaths.greyTeal__png, bodyWidth, bodyHeight, [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED ARTIFACTS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		title.centerSprite();
		title.y -= (body.height - title.height) / 2;
		add(title);

		// create the store of blank tiles to use.
		for (i in 0...Player.MAX_UNEQUIPPED_ARTIFACTS)
		{
			var blankTile = new TileBlank();
			blankTiles.push(blankTile);
		}

		var message = '';
		dropZone = new DropZone(onDrop, message, body.width, body.height);
		dropZone.centerSprite();
		add(dropZone);

		// call this to initially render the unequipped artifact tiles.
		refresh();
	}
}
