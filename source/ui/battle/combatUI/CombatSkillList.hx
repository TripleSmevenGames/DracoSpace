package ui.battle.combatUI;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.player.CharacterInfo.CharacterType;
import ui.TooltipLayer.Tooltip;
import ui.battle.character.CharacterAvatar;
import ui.battle.character.CharacterSprite;
import utils.GameController;

using utils.ViewUtils;

/** Shows the character's skills in a horizontal line during battles.
 * Centered on the Avatar!!
**/
class CombatSkillList extends FlxSpriteGroup
{
	var char:CharacterSprite;

	// this red "X" sprite will appear over the avatar if the character dies
	var xCover:FlxSprite;

	/** if a char is dead, put the xCover over it to show that it is dead.
		this will get called by the DeckSprite.
	**/
	public function checkDead()
	{
		xCover.visible = char.dead;
	}

	public function new(char:CharacterSprite)
	{
		super();
		this.char = char;
		var type = char.info.type;

		// setup the avatar in the center;
		var avatarSprite = new CharacterAvatar(char);
		avatarSprite.centerSprite();
		add(avatarSprite);
		avatarSprite.setupHover();

		// create the x-cover
		this.xCover = new FlxSprite(0, 0, AssetPaths.xCover__png);
		xCover.centerSprite();
		add(xCover);
		xCover.visible = false;

		// setup the skills next to it
		var cursor:Float = 0;
		var addToCursor = (x:Float) -> cursor += type == ENEMY ? -x : x;

		addToCursor(avatarSprite.width + 8);

		for (skillSprite in char.skillSprites)
		{
			skillSprite.setPosition(cursor, 0);
			add(skillSprite);
			addToCursor(skillSprite.tile.width); // no padding cuz sprite has padding inside somehow?
		}
	}
}
