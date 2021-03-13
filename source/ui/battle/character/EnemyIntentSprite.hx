package ui.battle.character;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.ai.BaseAI.Intent;

using utils.ViewUtils;

class EnemyIntentSprite extends FlxSpriteGroup
{
	public function new(intent:Intent)
	{
		super();

		var skillTile = new SkillTile(intent.skill.skill);
		if (intent.targets.length == 0)
		{
			add(skillTile);
			return;
		}
		var arrow = new FlxSprite(0, 0, AssetPaths.YellowArrow3R__png);
		arrow.scale3x();
		var targetSprites = new TargetSprites(intent.targets);

		// put the arrow in the middle
		arrow.centerSprite();

		// put the skillTile on the left.
		skillTile.setPosition(-(arrow.width / 2 + skillTile.width / 2 + 4), 0);

		// put the targets on the right.
		targetSprites.setPosition(arrow.width / 2 + targetSprites.width / 2 + 4, 0);

		add(arrow);
		add(skillTile);
		add(targetSprites);
	}
}

/** centered **/
class TargetSprites extends FlxSpriteGroup
{
	public function new(targets:Array<CharacterSprite>)
	{
		super();
		var avatarSprites = targets.map((char:CharacterSprite) -> new FlxSprite(0, 0, char.info.avatarPath));
		for (i in 0...avatarSprites.length)
		{
			var sprite = avatarSprites[i];
			sprite.scale3x();
			var xPos = ViewUtils.getXCoordForCenteringLR(i, avatarSprites.length, sprite.width, 2);
			sprite.centerSprite(xPos, 0);
			add(sprite);
		}
	}
}
