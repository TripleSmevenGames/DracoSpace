package ui.battle.character;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.ai.EnemyIntentMaker.Intent;

using utils.ViewUtils;

/** Centered around middle intent sprite (this is a group of them)**/
class EnemyIntentSprites extends FlxSpriteGroup
{
	var intentSprites:Array<EnemyIntentSprite>;

	public function addIntent(intent:Intent)
	{
		intentSprites.push(new EnemyIntentSprite(intent));
		rerender();
	}

	public function resetIntents()
	{
		for (sprite in intentSprites)
		{
			remove(sprite);
			sprite.destroy();
		}

		intentSprites = [];
		rerender();
	}

	function rerender()
	{
		for (sprite in intentSprites)
			remove(sprite);

		for (i in 0...intentSprites.length)
		{
			var sprite = intentSprites[i];
			var yPos = ViewUtils.getXCoordForCenteringLR(i, intentSprites.length, sprite.height, 8);
			sprite.setPosition(0, yPos);
			add(sprite);
		}
	}

	public function new()
	{
		super();
		intentSprites = [];
	}
}

/** Centered around the pointing arrow **/
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
		var arrow = new FlxSprite(0, 0, AssetPaths.YellowArrow3L__png);
		arrow.scale3x();
		var targetSprites = new TargetSprites(intent.targets);

		// put the arrow in the middle
		arrow.centerSprite();

		// put the skillTile on the right.
		skillTile.setPosition((arrow.width / 2 + skillTile.width / 2 + 4), 0);

		// put the targets on the left.
		targetSprites.setPosition(-arrow.width / 2 - targetSprites.width / 2 - 4, 0);

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
