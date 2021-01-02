package ui;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import ui.battle.SkillSprite;
import utils.ViewUtils;

// if all these tooltips cause a performance issue, make this one tooltip that "teleports" around instead.

enum TooltipPos
{
	TOP;
	BOTTOM;
}

/** The tooltip you see when you hover over something. **/
class Tooltip extends FlxSpriteGroup
{
	static inline final WIDTH = 200;

	var parent:FlxObject;
	var pos:TooltipPos;

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

	/** Uses the mouseEventManager to set mouse in/out callbacks on the parent. Assumes you added the parent to the manager already. **/
	function bindTo(parent:FlxObject)
	{
		this.parent = parent;
		FlxMouseEventManager.setMouseOverCallback(parent, (_) ->
		{
			if (pos == TOP)
				centerAboveParent();
			else if (pos == BOTTOM)
				centerBelowParent();
			this.visible = true;
		});
		FlxMouseEventManager.setMouseOutCallback(parent, (_) -> this.visible = false);
	}

	function bindToSkill(skillSprite:SkillSprite)
	{
		this.parent = skillSprite.tile;
		var over = (_) ->
		{
			if (pos == TOP)
				centerAboveParent();
			else if (pos == BOTTOM)
				centerBelowParent();
			this.visible = true;
		};
		var out = (_) -> this.visible = false;
		skillSprite.addHoverCallback(over, out);
	}

	public function new(name:Null<String>, desc:Null<String>, pos:TooltipPos = TOP, ?font:String)
	{
		super(0, 0);

		this.pos = pos;

		var fontSize = UIMeasurements.BATTLE_UI_FONT_SIZE_MED;
		var spaceBetweenNameAndDesc = 12;
		var paddingVertical = 6;
		var paddingSide = 4;

		var body = new FlxSprite(0, 0);
		add(body);

		var bodyHeight:Float = 0;

		if (font == null)
			font = Fonts.STANDARD_FONT;

		if (name != null)
		{
			var nameText = new FlxText(paddingSide, paddingVertical, WIDTH, name);
			nameText.setFormat(font, UIMeasurements.BATTLE_UI_FONT_SIZE_MED, FlxColor.WHITE, 'center');
			bodyHeight += nameText.height;
			add(nameText);
		}

		if (desc != null)
		{
			var descText = new FlxText(paddingSide, bodyHeight + spaceBetweenNameAndDesc, WIDTH, desc);
			descText.setFormat(font, fontSize);
			bodyHeight += descText.height + spaceBetweenNameAndDesc;
			add(descText);
		}

		// adjust the body based on the height its content
		body.makeGraphic(WIDTH + paddingSide * 2, Std.int(bodyHeight + paddingVertical), Colors.BACKGROUND_BLUE);
		// then make it slightly see-through
		body.alpha = .5;

		this.visible = false;
	}
}

@:access(ui.Tooltip)
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

	public function registerTooltipForSkill(tooltip:Tooltip, skillSprite:SkillSprite)
	{
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
