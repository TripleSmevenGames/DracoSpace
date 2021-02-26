package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import models.player.Player;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered. **/
class UnequippedSkillsList extends FlxSpriteGroup
{
	public var skillTiles:Array<SkillTile>;

	public function new()
	{
		super();
		skillTiles = [];

		var bodyWidth = FlxG.width / 2;
		var bodyHeight = 72;
		var body = new FlxUI9SliceSprite(0, 0, AssetPaths.brown__png, new Rectangle(0, 0, bodyWidth, bodyHeight), [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var numSkills = Player.inventory.unequippedSkills.length;
		for (i in 0...numSkills)
		{
			var skill = Player.inventory.unequippedSkills[i];
			var skillTile = new SkillTile(0, 0, skill);
			skillTile.scale3x();
			var xPos = ViewUtils.getXCoordForCenteringLR(i, numSkills, skillTile.width, 8);
			skillTile.centerSprite(xPos, 0);
			skillTiles.push(skillTile);
			add(skillTile);
		}

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED SKILLS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE);
		title.centerSprite();
		title.y -= body.height;
	}
}
