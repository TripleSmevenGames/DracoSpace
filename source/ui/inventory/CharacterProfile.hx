package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.CharacterInfo;

using utils.ViewUtils;

/** Represents a character in the inventory menu. Shows their sprite and what skills/items they have.
 *
 * Centered on the character sprite.
**/
class CharacterProfile extends FlxSpriteGroup
{
	public var char:CharacterInfo;
	public var skillTiles:Array<SkillTile>;

	public function new(char:CharacterInfo)
	{
		super();
		skillTiles = [];

		var background = new FlxSprite();
		background.makeGraphic(64 * 3, 80 * 3, FlxColor.fromRGB(0, 0, 0, 128));
		background.centerSprite();
		add(background);

		var characterSprite = new FlxSprite(0, 0, char.spritePath);
		characterSprite.scale3x();
		characterSprite.centerSprite();
		add(characterSprite);

		var title = new FlxText(0, 0, 0, char.name);
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE);
		title.centerSprite(0, -(characterSprite.height / 2 + 16));
		add(title);

		// add the skills underneath the background
		var numSkills = char.skills.length;
		var yPos = background.height / 2 + 32;
		for (i in 0...numSkills)
		{
			var skill = char.skills[i];
			var skillTile = new SkillTile(0, 0, skill);
			skillTile.scale3x();
			var xPos = ViewUtils.getXCoordForCenteringLR(i, numSkills, skillTile.width, 8);
			skillTile.centerSprite(xPos, yPos);
			skillTiles.push(skillTile);
			add(skillTile);
		}
	}
}
