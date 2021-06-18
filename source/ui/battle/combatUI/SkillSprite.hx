package ui.battle.combatUI;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.cards.Card;
import models.skills.Skill;
import ui.battle.character.CharacterSprite;
import ui.skillTile.SkillTile;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** A sprite representing a skill during battle. This is not the Skill itself, but it should always have a reference to
	the Skill it represents. This should not exist outside the context of a battle.
	*
	* During battle, you should pretty much ALWAYS be interacting and modifying the SkillSprite, not the Skill itself.
	*
	* This has a special way of handling mouse callbacks. Use its callback setting methods, DONT call FlxMouseEventManager on it.
 */
class SkillSprite extends FlxSpriteGroup
{
	public var skill:Skill;
	public var tile:SkillTile;
	public var cooldownCountdownSprite:FlxText;
	public var disabledFilter:FlxSprite;
	public var priority:Int = 0;
	public var owner:CharacterSprite;

	// cooldown of x means the you must wait x turns before it can be used again.
	// cooldown of 0 means this skill can be used this turn.
	public var cooldownTimer(default, set):Int = 1;
	public var currentCharges(default, set):Int = 1;
	public var disabled(default, set):Bool;

	var mouseOverCallbacks:Array<FlxSprite->Void> = [];
	var mouseOutCallbacks:Array<FlxSprite->Void> = [];
	var leftClickCallbacks:Array<FlxSprite->Void> = [];
	var rightClickCallbacks:Array<FlxSprite->Void> = [];

	public function set_cooldownTimer(val:Int)
	{
		if (val == 0) // refund charges on this skill when cooldown hits 0;
		{
			currentCharges += skill.chargesPerCD;
			if (currentCharges < skill.maxCharges) // and if there are still charges to restore, put the skill on cooldown again.
				return cooldownTimer = skill.cooldown;
		}

		if (val < 0)
			val = 0;

		this.cooldownCountdownSprite.text = Std.string(val);
		return cooldownTimer = val;
	}

	public function set_currentCharges(val:Int)
	{
		if (val > skill.maxCharges)
			val = skill.maxCharges;

		if (val < 0)
			val = 0;

		currentCharges = val;
		checkDisabled();

		return currentCharges;
	}

	/** Disable this skill, greying it out and stopping all click handlers. 
		Happens if it goes on cooldown, is disabled by an affect, or owner dies
	**/
	public function set_disabled(val:Bool)
	{
		if (owner != null && owner.dead)
			this.disabled = true;

		// depending on why we are disabling the skill, we might show a number (cooldown),
		// or just a slash (stunned/dead);
		if (val)
		{
			this.cooldownCountdownSprite.visible = true;
			disabledFilter.visible = true;

			if (owner.getStatus(STUN) > 0 || owner.dead || (currentCharges == 0 && skill.chargesPerCD == 0))
				this.cooldownCountdownSprite.text = '/';
			else
				this.cooldownCountdownSprite.text = Std.string(cooldownTimer);
		}
		else // if we are enabling it, reset everything
		{
			this.cooldownCountdownSprite.visible = false;
			disabledFilter.visible = false;
		}
		return this.disabled = val;
	}

	/** Returns true if any subset these cards COULD pay for the skill. **/
	public function couldPayWithCards(cards:Array<Card>)
	{
		return skill.couldPayWithCards(cards);
	}

	/** From the passed in cards, pick cards which can pay for this skill. 
	 * Tries to pay for the first cost. If not, tries to pay for the second, and so on.
	 * Returns null if we can't play the skill with these cards.
	**/
	public function pickCardsForPay(cards:Array<Card>)
	{
		return skill.pickCardsForPay(cards);
	}

	/** Check if this skill should be disabled, and disable it if so.
	 * Is automatically called at certain points, but can be manually called too.
	**/
	public function checkDisabled()
	{
		disabled = (currentCharges == 0) || owner.getStatus(STUN) != 0 || owner.dead;
	}

	/** adds a left click callback, which will fire when clicked if the skill is not disabled. **/
	public function setOnClick(onClick:SkillSprite->Void)
	{
		leftClickCallbacks.push((sprite:FlxSprite) ->
		{
			if (disabled)
				return;
			else
				onClick(this);
		});
	}

	/** adds a right click callback, which will fire when right clicked if the skill is not disabled. **/
	public function setOnRightClick(onClick:SkillSprite->Void)
	{
		rightClickCallbacks.push((sprite:FlxSprite) ->
		{
			if (disabled)
				return;
			else
				onClick(this);
		});
	}

	public function setOnHover(over:FlxSprite->Void, out:FlxSprite->Void)
	{
		mouseOverCallbacks.push(over);
		mouseOutCallbacks.push(out);
	}

	public function play(targets:Array<CharacterSprite>, context:BattleContext)
	{
		if (this.disabled)
			return;

		skill.play(targets, this.owner, context);
		this.currentCharges -= 1;
		this.cooldownTimer += skill.cooldown;
	}

	public function onNewRound()
	{
		this.cooldownTimer -= 1;
		checkDisabled();
	}

	public function new(skill:Skill, owner:CharacterSprite)
	{
		super(0, 0);
		this.skill = skill;
		this.owner = owner;

		tile = new SkillTile(skill);
		add(tile);

		// setup a grey filter, which will be applied over the tile (but under the cooldown counter) when the skill is disabled.
		disabledFilter = new FlxSprite();
		disabledFilter.makeGraphic(Std.int(tile.width), Std.int(tile.height), FlxColor.fromRGB(0, 0, 0, 128));
		disabledFilter.centerSprite();
		add(disabledFilter);
		disabledFilter.visible = false;

		// setup the cooldown counter, which will appear on the tile when its on cooldown.
		cooldownCountdownSprite = new FlxText(0, 0, 0, '/');
		cooldownCountdownSprite.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG);
		cooldownCountdownSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		cooldownCountdownSprite.centerSprite();
		add(cooldownCountdownSprite);
		cooldownCountdownSprite.visible = false;

		this.cooldownTimer = 0;
		this.currentCharges = skill.maxCharges;
		this.priority = skill.priority;

		// setup the cost indicator under the tile.
		var costTextOptions = {bodyWidth: 72.0, fontSize: 12, font: Fonts.STANDARD_FONT2};
		var costTextSprite = new FlxTextWithReplacements(skill.getCostStringCompact(), null, null, costTextOptions);
		costTextSprite.centerSprite(0, tile.height / 2 + 8);
		add(costTextSprite);

		// setup the mouse events
		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		// In order for right click to work, we need to set the mouseButtons arg
		var mouseOver = (sprite:FlxSprite) ->
		{
			for (callback in mouseOverCallbacks)
				callback(sprite);
		};

		var mouseOut = (sprite:FlxSprite) ->
		{
			for (callback in mouseOutCallbacks)
				callback(sprite);
		};

		var mouseClick = (sprite:FlxSprite) ->
		{
			// left click activated this click
			if (FlxG.mouse.justReleased)
			{
				for (callback in leftClickCallbacks)
					callback(sprite);
			}
			// right click activated this click
			else if (FlxG.mouse.justReleasedRight)
			{
				for (callback in rightClickCallbacks)
					callback(sprite);
			}
		};

		// note, for right clicking to work, you MUST add the click handler through add() like this, with the MouseButtons arg.
		// You cannot do .setMouseClickCallback() for right clicks.
		FlxMouseEventManager.add(tile, null, mouseClick, mouseOver, mouseOut, false, true, false, [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT]);

		// setup the default hover effect
		var darken = (_) -> tile.color = FlxColor.fromRGB(200, 200, 200);
		var undarken = (_) -> tile.color = FlxColor.WHITE;
		setOnHover(darken, undarken);

		// setup the tooltip (which is also a hover effect)
		GameController.battleTooltipLayer.createTooltipForSkillSprite(this);

		disabled = false;
	}
}
