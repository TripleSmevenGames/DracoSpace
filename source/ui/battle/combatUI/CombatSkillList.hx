package ui.battle.combatUI;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.player.CharacterInfo.CharacterType;
import ui.battle.character.CharacterSprite;

using utils.ViewUtils;

/** Shows the character's skills in a horizontal line during battles.
 * Centered on the Avatar!!
**/
class CombatSkillList extends FlxSpriteGroup
{
	var char:CharacterSprite;

	static final PLACE_HOLDER_AVATAR = AssetPaths.trainingDummyAvatar__png;

	public function new(char:CharacterSprite)
	{
		super();
		this.char = char;
		var type = char.info.type;

		// setup the avatar in the center;
		var avatarPath = char.info.avatarPath != null ? char.info.avatarPath : PLACE_HOLDER_AVATAR;
		var avatarSprite = new FlxSprite(0, 0, avatarPath);
		avatarSprite.scale3x();
		avatarSprite.centerSprite();
		add(avatarSprite);

		// setup the skills next to it
		var cursor:Float = 0;
		var addToCursor = (x:Float) -> cursor += type == ENEMY ? -x : x;

		addToCursor(avatarSprite.width + 8);

		for (skillSprite in char.skillSprites)
		{
			skillSprite.setPosition(cursor, 0);
			add(skillSprite);
			addToCursor(skillSprite.tile.width); // no padding cuz sprite has padding inside lmao
		}
	}
}
