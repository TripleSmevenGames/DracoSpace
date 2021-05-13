package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.CharacterInfo;
import ui.battle.SkillTile.SkillTileBlank;
import ui.battle.SkillTile.SkillTileLocked;
import ui.battle.SkillTile;
import ui.battle.character.CharacterSprite;
import ui.header.CharacterDisplay.HpDisplay;

using utils.ViewUtils;

/** Not centered. **/
class CharacterProfile3 extends FlxSpriteGroup
{
	public var char:CharacterInfo;
	public var skillTiles:Array<SkillTile>;
	public var blankSkillTiles:Array<SkillTileBlank>;
	public var lockedSkillTiles:Array<SkillTileLocked>;

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

	function getCharSkillList(fontSize:Int = 24)
	{
		var group = new FlxSpriteGroup();

		var titleText = new FlxText(0, 0, 0, 'Skills:');
		titleText.setFormat(Fonts.STANDARD_FONT, fontSize, FlxColor.BLACK);
		group.add(titleText);

		// create the tiles. There are skill tiles, open slot tiles, and locked slot tiles.
		var tiles = new Array<FlxSprite>();
		final slots = 6;
		for (i in 0...slots)
		{
			var numSkills = char.skills.length;
			var numOpen = char.numSkillSlots - numSkills;

			if (i < numSkills)
			{
				var skillTile = new SkillTile(char.skills[i]);
				tiles.push(skillTile);
				skillTiles.push(skillTile);
				skillTile.setupHover(INV);
			}
			else if (i >= numSkills && i < numSkills + numOpen)
			{
				var blankSkillTile = new SkillTileBlank();
				tiles.push(blankSkillTile);
				blankSkillTiles.push(blankSkillTile);
			}
			else
			{
				var lockedSkillTile = new SkillTileLocked();
				tiles.push(lockedSkillTile);
				lockedSkillTiles.push(lockedSkillTile);
				lockedSkillTile.setupHover(INV);
			}
		}

		// put the tiles in a 2x3 grid.
		for (i in 0...tiles.length)
		{
			var tile = tiles[i];
			var coords = tile.getCoordsForPlacingInGrid(3, i, 8);
			tile.setPosition(coords.x + titleText.width, coords.y);

			group.add(tile);
		}

		return group;
	}

	public function new(char:CharacterInfo)
	{
		super();
		this.char = char;
		this.skillTiles = [];
		this.blankSkillTiles = [];
		this.lockedSkillTiles = [];

		var background = new FlxSprite();
		background.makeGraphic(64 * 3, 80 * 3, FlxColor.fromRGB(0, 0, 0, 100));

		var characterSprite = CharacterSprite.loadSpriteSheetInfo(char.spriteSheetInfo);
		characterSprite.matchBottomCenter(background);
		characterSprite.y -= 8; // bump it upwards just a bit

		add(background);
		add(characterSprite);
		characterSprite.animation.play('idle');

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
		var skillList = getCharSkillList();
		skillList.setPosition(cursor.x, cursor.y);
		add(skillList);
	}
}
