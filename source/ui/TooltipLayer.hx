package ui;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.skills.Skill;
import ui.battle.SkillSprite;
import ui.battle.win.SkillCard;
import utils.ViewUtils;

// if all these tooltips cause a performance issue, make this one tooltip that "teleports" around instead.

typedef TooltipOptions =
{
	?pos:TooltipPos,
	?width:Float,
	?centered:Bool,
	?fontSize:Int
}

enum TooltipPos
{
	TOP;
	BOTTOM;
}

/** The tooltip you see when you hover over something. **/
class Tooltip extends FlxSpriteGroup
{
	var sprite:FlxSprite;
	var parent:FlxObject;
	var name:String;

	// these two dont exist if we put in a group directly
	public var descText:Null<FlxTextWithReplacements>;
	public var body:FlxSprite;
	public var options:TooltipOptions;

	static function getDefaultOptions(options:TooltipOptions)
	{
		if (options.pos == null)
			options.pos = TOP;
		if (options.width == null)
			options.width = 200;
		if (options.centered == null)
			options.centered = false;
		if (options.fontSize == null)
			options.fontSize = UIMeasurements.BATTLE_UI_FONT_SIZE_MED;

		return options;
	}

	// functions below are very dirty.
	// If we are creating the tooltip with genericTooltip, its not centered so we have to center it onHover.
	// If we are creating the skill tooltip, it is centered, so dont need to center it again, Just place it.

	/** Pass in global coords. Meaning the parent must be added to its group already.
	 */
	function centerAboveParent()
	{
		ViewUtils.centerSprite(this, parent.x + parent.width / 2, parent.y - this.height / 2 - 8);
	}

	function centerBelowParent()
	{
		ViewUtils.centerSprite(this, parent.x + parent.width / 2, parent.y + this.height / 2 + 8);
	}

	function putAboveParent()
	{
		this.setPosition(parent.x, parent.y - this.height / 2 - parent.height / 2 - 8);
	}

	function putBelowParent()
	{
		this.setPosition(parent.x, parent.y + this.height / 2 + parent.height / 2 + 8);
	}

	/** Uses the mouseEventManager to set mouse in/out callbacks on the parent. Assumes you added the parent to the manager already. **/
	function bindTo(parent:FlxObject)
	{
		this.parent = parent;
		FlxMouseEventManager.setMouseOverCallback(parent, (_) ->
		{
			if (options.pos == TOP)
				centerAboveParent();
			else if (options.pos == BOTTOM)
				centerBelowParent();
			else
				trace('buggah, options.POS was nothing');

			this.visible = true;
		});
		FlxMouseEventManager.setMouseOutCallback(parent, (_) -> this.visible = false);
	}

	function bindToSkill(skillSprite:SkillSprite)
	{
		this.parent = skillSprite.tile;
		var over = (_) ->
		{
			if (options.pos == TOP)
			{
				var canFit = parent.y > this.height + 16; // padding;
				if (canFit)
					putAboveParent();
				else
					putBelowParent();
			}
			else if (options.pos == BOTTOM)
			{
				var canFit = FlxG.height - parent.y > this.height + 16;
				if (canFit)
					putBelowParent();
				else
					putAboveParent();
			}
			else
				trace('buggah, options.pos was nothing');

			this.visible = true;
		};
		var out = (_) -> this.visible = false;
		skillSprite.addHoverCallback(over, out);
	}

	/** Don't change the desc so much that we'd have to recalculate the body's height. I dont want to do that. **/
	public function updateDesc(val:String)
	{
		if (descText != null)
			descText.processAndPlaceInput(val);
		else
			trace('tried to update a descText, but it was null!');
	}

	/** default width is 200. **/
	public static function genericTooltip(name:Null<String>, desc:Null<String>, options:TooltipOptions)
	{
		var group = new FlxSpriteGroup();
		options = getDefaultOptions(options);
		var spaceBetweenNameAndDesc = 12;
		var paddingVertical = 6;
		var paddingSide = 6;
		var font = Fonts.STANDARD_FONT;

		var body = new FlxSprite(0, 0);
		var bodyHeight:Float = 0;
		group.add(body);

		var descText = null;
		if (name != null)
		{
			var nameText = new FlxText(paddingSide, paddingVertical, options.width, name);

			nameText.setFormat(font, UIMeasurements.BATTLE_UI_FONT_SIZE_LG, FlxColor.WHITE, 'center');
			bodyHeight += nameText.height;
			group.add(nameText);
		}
		if (desc != null)
		{
			// descText = new FlxText(paddingSide, bodyHeight + spaceBetweenNameAndDesc, width, desc);
			var options = {bodyWidth: options.width, centered: options.centered, fontSize: options.fontSize};
			descText = new FlxTextWithReplacements(desc, null, null, options);
			descText.setPosition(paddingSide, bodyHeight + spaceBetweenNameAndDesc);

			bodyHeight += descText.height + spaceBetweenNameAndDesc;
			group.add(descText);
		}
		// adjust the body based on the height its content
		body.makeGraphic(Std.int(options.width + paddingSide * 2), Std.int(bodyHeight + paddingVertical), Colors.BACKGROUND_BLUE);
		// then make it slightly see-through
		body.alpha = .5;

		var tooltip = new Tooltip(group, options);
		tooltip.body = body;
		tooltip.descText = descText;
		return tooltip;
	}

	public static function skillTooltip(skill:Skill)
	{
		var sprite = new SkillCard(skill);
		return new Tooltip(sprite, {});
	}

	/* Creates tooltip from a sprite. The sprite probably should be a group that's centered. */
	public function new(sprite:FlxSprite, options:TooltipOptions)
	{
		super();
		this.sprite = sprite;
		add(sprite);
		this.options = getDefaultOptions(options);
		this.visible = false;
	}
}

@:access(ui.Tooltip)
@:access(ui.SkillTooltip)
class TooltipLayer extends FlxSpriteGroup
{
	var tooltips:Array<Tooltip> = [];

	/** Shows the passed in tooltip over the parent when you hover over the parent. Puts it in the global tooltip layer. 
	 *
	 * DON'T add() the tooltip yourself in a group.
	**/
	public function registerTooltip(tooltip:Tooltip, parent:FlxObject)
	{
		tooltip.bindTo(parent);

		add(tooltip);
		tooltips.push(tooltip);
	}

	public function createTooltipForSkill(skillSprite:SkillSprite)
	{
		var tooltip = Tooltip.skillTooltip(skillSprite.skill);
		tooltip.bindToSkill(skillSprite);
		add(tooltip);
		tooltips.push(tooltip);
	}

	public function cleanupTooltips()
	{
		for (tooltip in tooltips)
		{
			remove(tooltip);
			tooltip.destroy();
		}
		tooltips = [];
	}

	public function new()
	{
		super(0, 0);
	}
}
