package ui.battle.combatUI;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import models.CharacterInfo;
import models.player.Player;
import ui.artifact.ArtifactTileBattle;
import ui.skillTile.SkillTile.TileBlank;

using utils.ViewUtils;

class BattleHeader extends FlxSpriteGroup
{
	var body:FlxSprite;

	static inline final HEIGHT = 90;

	public function new()
	{
		super();

		body = new FlxSprite(0, 0);
		body.makeGraphic(FlxG.width, HEIGHT, FlxColor.fromRGB(0, 0, 0, 50));
		add(body);

		// start rendering 100 pixels from the very left of the screen
		var xCoord = 100.0;
		var yCoord = body.height / 2;

		for (char in Player.chars)
		{
			var charArtifacts = new CharArtifacts(char);
			charArtifacts.setPosition(xCoord, yCoord);
			add(charArtifacts);

			xCoord += charArtifacts.width; // might be off b/c of the FlxSpriteGroup width glitch
		}
	}
}

/** Holder for a char's artifact tiles during battle.
 * It will render on the battle header so the user can see what artifacts each character has.
 * Centered Y only. X starts at left most side.
**/
class CharArtifacts extends FlxSpriteGroup
{
	public function new(char:CharacterInfo)
	{
		super();
		var avatar = new FlxSprite(0, 0, char.avatarPath);
		avatar.scale3x();
		avatar.centerY();
		add(avatar);

		// next to the avatar, add the artifacts in a line, just like in the equipment menu
		var xCoord = avatar.width + 40;
		for (i in 0...3)
		{
			var tile:FlxSprite;
			if (i < char.artifacts.length)
			{
				var artifact = char.artifacts[i];
				var artifactTile = new ArtifactTileBattle(artifact);
				artifactTile.setupHover();

				tile = artifactTile;
			}
			else
			{
				tile = new TileBlank();
			}
			tile.setPosition(xCoord, 0);
			xCoord += tile.width + 2;
			add(tile);
		}
	}
}
