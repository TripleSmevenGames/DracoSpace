package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import ui.battle.SkillTile;
import ui.battle.win.SkillCard;

using utils.ViewUtils;

/** Shows the player's unequipped skills in the Inventory menu. Centered on the body**/
class UnequippedSkillsList3 extends FlxSpriteGroup
{
	public var skillTiles:Array<SkillTile> = [];
	public var bodyHeight = 60;

	public function new()
	{
		super();

		var bodyWidth = FlxG.width / 2;
		var body = new FlxUI9SliceSprite(0, 0, AssetPaths.brown__png, new Rectangle(0, 0, bodyWidth, bodyHeight), [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var title = new FlxText(0, 0, 0, 'UNEQUIPPED SKILLS');
		title.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		title.centerSprite();
		title.y -= (body.height + title.height) / 2;
		add(title);

		var numSkills = Player.inventory.unequippedSkills.length;
		for (i in 0...numSkills)
		{
			var skill = Player.inventory.unequippedSkills[i];
			var skillTile = new SkillTile(skill);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, numSkills, skillTile.width, 4);
			skillTile.setPosition(xPos, 0);
			skillTiles.push(skillTile);
			add(skillTile);
			skillTile.setupHover(INV);
		}
	}
}
