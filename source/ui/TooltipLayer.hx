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
import ui.battle.SkillTile;
import ui.battle.win.SkillCard;
import utils.ViewUtils;

// if all these tooltips cause a performance issue, make this one tooltip that "teleports" around instead.

typedef TooltipOptions =
{
	?pos:TooltipPos,
	?width:Float,
	// if the text in the tooltip is centered, like the Draw and Discard pile tooltips
	?centered:Bool,
	// font size for the desc
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

	/**  use this if both the parent and the hover sprite is not centered. **/
	function centerAboveParent()
	{
		ViewUtils.centerSprite(this, parent.x + parent.width / 2, parent.y - this.height / 2 - 8);
	}

	function centerBelowParent()
	{
		ViewUtils.centerSprite(this, parent.x + parent.width / 2, parent.y + this.height / 2 + 8);
	}

	// use these functions if the parent is centered (like a centered FlxSpriteGroup), and the tooltipSprite is not centered (so we have to center it)
	function centerAboveCenteredParent()
	{
		ViewUtils.centerSprite(this, parent.x, parent.y - parent.height / 2 - this.height / 2 - 8);
	}

	function centerBelowCenteredParent()
	{
		ViewUtils.centerSprite(this, parent.x, parent.y + parent.height / 2 + this.height / 2 + 8);
	}

	// use these functions if the parent is centered, and the tooltip is centered.
	function putAboveParent()
	{
		this.setPosition(parent.x, parent.y - this.height / 2 - parent.height / 2 - 8);
	}

	function putBelowParent()
	{
		this.setPosition(parent.x, parent.y + this.height / 2 + parent.height / 2 + 8);
	}

	/** Uses the mouseEventManager to set mouse in/out callbacks on the parent. Assumes you added the parent to the manager already. **/
	function bindTo(parent:FlxObject, parentCentered:Bool = false)
	{
		this.parent = parent;
		FlxMouseEventManager.setMouseOverCallback(parent, (_) ->
		{
			var canFit = parent.y > this.height + 16; // padding;
			if (options.pos == TOP && canFit)
				if (parentCentered)
					centerAboveCenteredParent();
				else
					centerAboveParent();
			else if (options.pos == BOTTOM || !canFit)
				if (parentCentered)
					centerBelowCenteredParent();
				else
					centerBelowParent();
			else
				trace('buggah, options.POS was nothing');

			this.visible = true;
		});
		FlxMouseEventManager.setMouseOutCallback(parent, (_) -> this.visible = false);
	}

	function bindToPut(parent:FlxObject)
	{
		this.parent = parent;
		var canFit = parent.y > this.height + 16; // padding;
		FlxMouseEventManager.setMouseOverCallback(parent, (_) ->
		{
			if (options.pos == TOP && canFit)
				putAboveParent();
			else if (options.pos == BOTTOM || !canFit)
				putBelowParent();
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

	/** Create a generic tooltip sprite group. You must register it ontop of an object by calling TooltipLayer.registerTooltip().
	 * default width is 200. If width is 0, we are "auto width" and will make it match the title length if there's no desc.
	 * It's not centered, so we have to call centerAboveParent() or similar when registering it.
	**/
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

		var nameText = null;
		var descText = null;
		if (name != null)
		{
			nameText = new FlxText(paddingSide, paddingVertical, options.width, name);

			nameText.setFormat(font, UIMeasurements.BATTLE_UI_FONT_SIZE_LG, FlxColor.WHITE, 'center');
			bodyHeight += nameText.height;
			group.add(nameText);
		}
		if (desc != null)
		{
			var options = {bodyWidth: options.width, centered: options.centered, fontSize: options.fontSize};
			descText = new FlxTextWithReplacements(desc, null, null, options);
			descText.setPosition(paddingSide, bodyHeight + spaceBetweenNameAndDesc);

			bodyHeight += descText.height + spaceBetweenNameAndDesc;
			group.add(descText);
		}
		// now that we have the content, we can set the body (ie. background's) width and height
		var bodyWidth:Int;

		// if the options width is 0, we auto calculate the width if there's just a name and no desc.
		if (options.width == 0 && nameText != null && descText == null)
		{
			bodyWidth = Std.int(nameText.width + paddingSide * 2);
		}
		else
		{
			bodyWidth = Std.int(options.width + paddingSide * 2);
		}
		body.makeGraphic(bodyWidth, Std.int(bodyHeight + paddingVertical), Colors.BACKGROUND_BLUE);
		// then make it slightly see-through
		body.alpha = .7;

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
	 * use Tooltip.genericTooltip to create the tooltip.
	 * DON'T add() the tooltip yourself in a group.
	 * Make sure you added the parent to the mouse manager already.
	**/
	public function registerTooltip(tooltip:Tooltip, parent:FlxObject, parentCentered:Bool = false)
	{
		tooltip.bindTo(parent, parentCentered);

		add(tooltip);
		tooltips.push(tooltip);
	}

	/** Creates and reigsters tooltip for a skillSprite. **/
	public function createTooltipForSkill(skillSprite:SkillSprite)
	{
		var tooltip = Tooltip.skillTooltip(skillSprite.skill);
		tooltip.bindToSkill(skillSprite);
		add(tooltip);
		tooltips.push(tooltip);
	}

	/** Creates and reigsters tooltip for a skillTile. **/
	public function createTooltipForSkillTile(skillTile:SkillTile)
	{
		var tooltip = Tooltip.skillTooltip(skillTile.skill);
		// we use bindToPut because the skillCard hover is centered already, so we dont want to call centerOverParent. Instead we want putOverParent.
		tooltip.bindToPut(skillTile);
		add(tooltip);
		tooltips.push(tooltip);
	}

	public function new()
	{
		super(0, 0);
	}
}
