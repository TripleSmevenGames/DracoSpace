package ui.battle.character;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.ai.EnemyIntentMaker.Intent;
import models.skills.Skill;
import ui.TooltipLayer.Tooltip;
import utils.GameController;

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

		// stupid hack that prevents the entire group from seemingly disappearing at times.
		// I SUSPECT it's because when I call resetIntents, it removes ever sprite from the group.
		// And when no more sprites exist in the group, it kills itself, or something. SO adding this dummy prevents all sprites from being removed.
		// Looking into the code itself, I actually couldnt find proof if this being true. So idk.
		var anchor = ViewUtils.newAnchor();
		anchor.alpha = 0;
		add(anchor);
	}
}

/** Centered around the pointing arrow **/
class EnemyIntentSprite extends FlxSpriteGroup
{
	/** Generate a string describing this intent **/
	static function generateTooltipString(intent:Intent)
	{
		var skill:Skill = intent.skill.skill;
		var string = '${intent.skill.owner.info.name} wants to use ${skill.name.toUpperCase()} ';
		if (skill.targetMethod == SELF)
		{
			string += 'on itself';
		}
		else if (skill.targetMethod == DECK)
		{
			// no-op;
		}
		else if (intent.targets != null)
		{
			var targets = intent.targets;
			string += 'on ';
			var names = targets.map((target:CharacterSprite) -> target.info.name);
			string += names.join(', ');
		}

		string += '.';

		return string;
	}

	public function new(intent:Intent)
	{
		super();

		var skillTile = new SkillTile(intent.skill.skill);
		if (intent.targets.length == 0)
		{
			add(skillTile);
			skillTile.setupHover();
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

		this.addScaledToMouseManager();
		var tooltip = Tooltip.genericTooltip('Intent', generateTooltipString(intent), {width: 250});
		GameController.battleTooltipLayer.registerTooltip(tooltip, arrow);
	}
}

/** centered **/
class TargetSprites extends FlxSpriteGroup
{
	public function new(targets:Array<CharacterSprite>)
	{
		super();
		var avatarSprites = targets.map((char:CharacterSprite) -> new CharacterAvatar(char));

		for (i in 0...avatarSprites.length)
		{
			var sprite = avatarSprites[i];
			var xPos = ViewUtils.getXCoordForCenteringLR(i, avatarSprites.length, sprite.width, 2);
			sprite.centerSprite(xPos, 0);
			add(sprite);
		}
	}
}
