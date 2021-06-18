package ui.inventory.equipmentMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.CharacterInfo;
import models.player.Player;
import ui.artifact.ArtifactTile;
import ui.artifact.ArtifactTileInv;
import ui.battle.character.CharacterSprite;
import ui.header.CharacterDisplay.HpDisplay;
import ui.inventory.equipmentMenu.DragLayer.DropZone;
import ui.skillTile.InventorySkillTile;
import ui.skillTile.SkillTile.SkillTileBlank;
import ui.skillTile.SkillTile.SkillTileLocked;
import ui.skillTile.SkillTile;

using utils.ViewUtils;

/** A component showing the character's sprite, their HP, their equipped skills, and equipped artifacts. Not centered. **/
class CharacterProfile3 extends FlxSpriteGroup
{
	public var char:CharacterInfo;

	// these 2 need to be exposed so the parent can set up listeners/handlers on them
	public var skillTiles:Array<SkillTile>;
	public var artifactTiles:Array<ArtifactTile>;

	var skillList:FlxSprite;
	var artifactList:FlxSprite;

	/** A trigger zone for dropping artifacts and skills into, which will equip them onto the character. **/
	public var dropZone:DropZone;

	// not centered
	function getCharHpSprite(fontSize:Int = 24)
	{
		var group = new FlxSpriteGroup();

		var hpText = new FlxText(0, 0, 0, 'HP:');
		hpText.setFormat(Fonts.STANDARD_FONT, fontSize);
		group.add(hpText);

		var hpDisplay = new HpDisplay(char.currHp, char.maxHp, fontSize);
		hpDisplay.setPosition(hpText.width + 4, hpText.height / 2);
		group.add(hpDisplay);

		return group;
	}

	/** Not centered. **/
	function getCharSkillList(fontSize:Int = 24)
	{
		var group = new FlxSpriteGroup();

		var titleText = new FlxText(0, 0, 0, 'Skills:');
		titleText.setFormat(Fonts.STANDARD_FONT, fontSize, FlxColor.WHITE);
		group.add(titleText);

		// create the tiles. There are skill tiles, open slot tiles, and locked slot tiles.
		var tiles = new Array<FlxSprite>();
		final slots = Player.MAX_SKILL_SLOTS;
		for (i in 0...slots)
		{
			var numSkills = char.skills.length;
			var numOpen = char.numSkillSlots - numSkills;

			if (i < numSkills)
			{
				var skillTile = new InventorySkillTile(char.skills[i], 'Unequip');
				tiles.push(skillTile);
				skillTiles.push(skillTile);
				skillTile.setupHover(INV);
			}
			else if (i >= numSkills && i < numSkills + numOpen)
			{
				var blankSkillTile = new SkillTileBlank();
				tiles.push(blankSkillTile);
			}
			else
			{
				var lockedSkillTile = new SkillTileLocked();
				tiles.push(lockedSkillTile);
				lockedSkillTile.setupHover(INV);
			}
		}

		// put the tiles in a 2x3 grid.
		for (i in 0...tiles.length)
		{
			var tile = tiles[i];
			var coords = tile.getCoordsForPlacingInGrid(3, i, 4);
			tile.setPosition(coords.x + titleText.width, coords.y);

			group.add(tile);
		}

		return group;
	}

	/** Very similar to getCharSkillList. **/
	function getCharArtifactList(fontSize:Int = 24)
	{
		var group = new FlxSpriteGroup();

		var titleText = new FlxText(0, 0, 0, 'Artifacts:');
		titleText.setFormat(Fonts.STANDARD_FONT, fontSize, FlxColor.WHITE);
		group.add(titleText);

		// create the tiles. There are artifact tiles and open slot tiles.
		var tiles = new Array<FlxSprite>();
		final slots = Player.MAX_ARTIFACT_SLOTS;
		for (i in 0...slots)
		{
			var numArtifacts = char.artifacts.length;

			if (i < numArtifacts)
			{
				var skillTile = new InventorySkillTile(char.skills[i], 'Unequip');
				tiles.push(skillTile);
				skillTiles.push(skillTile);
				skillTile.setupHover(INV);
			}
			else
			{
				var blankSkillTile = new SkillTileBlank(); // the blank artifact slot is the same as the blank skill slot :)
				tiles.push(blankSkillTile);
			}
		}

		// put the tiles in a 1x3 grid.
		for (i in 0...tiles.length)
		{
			var tile = tiles[i];
			var coords = tile.getCoordsForPlacingInGrid(3, i, 4);
			tile.setPosition(coords.x + titleText.width, coords.y);

			group.add(tile);
		}

		return group;
	}

	/** Rerender the profile to reflect current data. 
	 * It removes and destroys the old skillList, and creates a new one in the same spot.
	 * Maybe slow? Could be more efficient with less destroying. E.g. save locked and blank skill slots in memory.
	**/
	public function refresh()
	{
		if (skillList == null)
			return;

		var xPos = skillList.x;
		var yPos = skillList.y;
		remove(skillList);
		skillList.destroy();

		// because this calls setupHover on the tiles, and we aren't cleaning up old tooltips,
		// technically this is causing a memory leak.
		// We'll cleanup the tooltips when we switch states though.
		skillList = getCharSkillList();
		add(skillList);
		skillList.setPosition(xPos, yPos);

		// now do the same thing for the artifact list.
		xPos = artifactList.x;
		yPos = artifactList.y;
		remove(artifactList);
		artifactList.destroy();

		artifactList = getCharArtifactList();
		add(artifactList);
		artifactList.setPosition(xPos, yPos);
	}

	public function new(char:CharacterInfo, onDrop:FlxSprite->Void)
	{
		super();
		this.char = char;
		this.skillTiles = [];

		// create a grey-ish background for the character's sprite.
		var background = new FlxSprite();
		background.makeGraphic(64 * 3, 80 * 3, FlxColor.fromRGB(0, 0, 0, 100));

		// create the character sprite, which is animated and play's the "idle" animation.
		var characterSprite = CharacterSprite.loadSpriteSheetInfo(char.spriteSheetInfo);
		characterSprite.matchBottomCenter(background);
		characterSprite.y -= 8; // bump it upwards just a bit

		add(background);
		add(characterSprite);
		characterSprite.animation.play('idle');

		// render the character's name
		var charName = new FlxText(0, 0, 0, char.name);
		charName.setFormat(Fonts.STANDARD_FONT, 24, FlxColor.YELLOW);
		charName.centerSprite(background.width / 2, 0);
		add(charName);

		// render the char's stats. Their hp, skills, and items
		var cursor = new FlxPoint(background.width + 4, 0);
		var charHpSprite = getCharHpSprite();
		charHpSprite.setPosition(cursor.x, cursor.y);
		add(charHpSprite);

		cursor.y += charHpSprite.height + 4;
		this.skillList = getCharSkillList();
		skillList.setPosition(cursor.x, cursor.y);
		add(skillList);

		cursor.y += skillList.height + 4;
		this.artifactList = getCharArtifactList();
		artifactList.setPosition(cursor.x, cursor.y);
		add(artifactList);

		// render the dropZone
		dropZone = new DropZone(onDrop, this.width, this.height);
		add(dropZone);
	}
}
