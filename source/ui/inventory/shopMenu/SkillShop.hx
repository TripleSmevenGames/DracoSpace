package ui.inventory.shopMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.player.Player;
import models.skills.Skill;
import ui.battle.IndicatorIcon;
import ui.battle.win.SkillCard;
import utils.GameUtils;

using utils.ViewUtils;

/***************************
 * This file has 3 components.
 * The parent component is the SkillShop, which holds several SkillShopChoiceSprites. And each
 * SkillShopChoiceSprite has a SkillShopChoiceCover.
******************************/
//

/** The parent group that represents the entire skill shop UI. Centered X only. **/
class SkillShop extends FlxSpriteGroup
{
	// array of the skill card SPRITES themselves. Not the skill object themselves.
	var skillShopChoiceSprites:Array<SkillShopChoiceSprite>;

	var infoIcon:IndicatorIcon;
	var titleText:FlxText;
	var refreshShopMenu:Void->Void;

	static var random:FlxRandom = new FlxRandom();

	// "hard-code" the height because of the FlxSpriteGroup dimension measurement bug.
	override public function get_height()
	{
		return titleText.height + SkillCard.bodyHeight;
	}

	// rerender everything according to current state
	public function refresh()
	{
		for (skillShopChoiceSprite in skillShopChoiceSprites)
			skillShopChoiceSprite.refresh();

		// refresh the header because it shows the XP, which can change if the player spends XP.
		GameController.subStateManager.refreshISSHeader();
	}

	/** define what happens when you click a choice in the shop **/
	function onClick(skillShopChoiceSprite:SkillShopChoiceSprite)
	{
		if (Player.exp >= skillShopChoiceSprite.price && Player.inventory.unequippedSkills.length < Player.MAX_UNEQUIPPED_SKILLS)
		{
			Player.exp -= skillShopChoiceSprite.price;
			Player.gainSkill(skillShopChoiceSprite.skill);
			remove(skillShopChoiceSprite);

			var sound = FlxG.sound.load(AssetPaths.purchase__wav);
			sound.play();

			Player.rerollSkillShopChoices();
			renderSkillShopChoiceSprites();

			// trigger a refresh of the entire ShopMenu (almost like a React state change)
			refreshShopMenu();
		}
		else
		{
			var sound = FlxG.sound.load(AssetPaths.error__wav);
			sound.play();
		}
	}

	/** Looks directly at the Player's saved skillshop choices, and renders the sprites for each. **/
	function renderSkillShopChoiceSprites()
	{
		// remove the existing sprites first, before rendering the new ones.
		for (sprite in skillShopChoiceSprites)
		{
			remove(sprite);
			sprite.destroy();
		}

		skillShopChoiceSprites = [];

		// array of SKILL objects, not the sprite representation of them in the shop!!
		// the sprite representation of them in the shop is SkillShopChoiceSprite.
		// These skills are grabbed from the saved static variable in Player.
		var skillChoices = Player.getCurrentSkillShopChoices();

		// render the row of shop choices, which are skills the player can buy.
		var centerY = titleText.height + 4 + SkillCard.bodyHeight / 2;
		for (i in 0...skillChoices.length)
		{
			// create the skillcard with the shop cover.
			var skill = skillChoices[i];
			var skillShopChoiceSprite = new SkillShopChoiceSprite(skill);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, skillChoices.length, SkillCard.bodyWidth, 4);
			skillShopChoiceSprite.setPosition(xPos, centerY);
			skillShopChoiceSprites.push(skillShopChoiceSprite);
			skillShopChoiceSprite.setOnClick(onClick);
			add(skillShopChoiceSprite);
		}
	}

	public function new(refreshShopMenu:Void->Void)
	{
		super();
		this.refreshShopMenu = refreshShopMenu;
		skillShopChoiceSprites = [];

		this.titleText = new FlxText(0, 0, 0, 'SKILL SHOP');
		titleText.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		titleText.centerX();
		add(titleText);

		renderSkillShopChoiceSprites();

		// small help tooltip icon in the corner.
		var infoText = 'Spend XP earned from battles to buy new skills. Remember to equip them. ' + 'When you buy a skill, the shop refreshes. Choose wisely!';
		this.infoIcon = IndicatorIcon.createInfoIndicator('Skill Shop', infoText);
		infoIcon.setPosition(titleText.width / 2 + 16, titleText.height / 2);
		add(infoIcon);
		infoIcon.registerTooltip();

		var background = ViewUtils.newSlice9(AssetPaths.shopBg__png, 20, 20, [8, 8, 40, 40]);
	}
}

/** A group representing a skill to buy in the shop. Really just a SkillCard and a FlxText for the price. Centered on the SkillCard. **/
class SkillShopChoiceSprite extends FlxSpriteGroup
{
	public var price:Int;
	public var skill:Skill;
	public var sale:Bool;

	var priceSprite:FlxText;
	var skillCard:SkillCard;

	static var random:FlxRandom = new FlxRandom();

	/** Get the sprite showing this price. Basically a number + 'XP' sprite. Not centered **/
	static function getSkillPriceSprite(price:Int = 0, sale:Bool = false)
	{
		var string:String;
		if (sale)
			string = 'Sale: ${Std.string(price)} XP';
		else
			string = '${Std.string(price)} XP';

		var priceSprite = new FlxText(0, 0, 0, string);
		var color = ViewUtils.getPriceColor(price, sale);

		priceSprite.setFormat(Fonts.STANDARD_FONT, 32, color);
		return priceSprite;
	}

	public function setOnClick(onClick:SkillShopChoiceSprite->Void)
	{
		// the skill card part is already added to the mouse manager, so dont need to do it again here.
		FlxMouseEventManager.setMouseClickCallback(this.skillCard, (_) -> onClick(this));
	}

	/** rerender the price sprite to reflect the player's current XP.**/
	public function refresh()
	{
		var color = ViewUtils.getPriceColor(price, sale);
		priceSprite.setFormat(Fonts.STANDARD_FONT, 32, color);

		var canAfford = Player.exp >= price;
		skillCard.setCanAfford(canAfford);
	}

	public function new(skill:Skill)
	{
		super();
		this.skill = skill;

		// create the skillcard with the shop cover.
		this.skillCard = new SkillCard(skill, SHOPCOVER);
		add(skillCard);

		// now create the price sprite underneath. 20% chance to be on sale.
		this.sale = random.int(1, 5) == 1;
		this.price = GameUtils.getSkillPrice(sale);
		this.priceSprite = getSkillPriceSprite(price, sale);
		priceSprite.centerSprite(0, SkillCard.bodyHeight / 2 + 16);
		add(priceSprite);
	}
}

/** A highlight cover that shows either "LMB to buy" or "Not enough XP" over a skill card choice in the shop. Centered.
 *
 * Go to SkillCard.hx to see how this is attached on top of a skillcard.
**/
class SkillShopChoiceCover extends FlxSpriteGroup
{
	var clickToBuyText:FlxSprite;
	var notEnoughXpText:FlxSprite;

	/** Set this variable to change the cover text. **/
	public var canAfford(default, set):Bool;

	public function set_canAfford(val:Bool)
	{
		if (val)
		{
			clickToBuyText.revive();
			notEnoughXpText.kill();
		}
		else
		{
			clickToBuyText.kill();
			notEnoughXpText.revive();
		}
		return canAfford = val;
	}

	/** Says 'Not enough XP'. Not centered. **/
	static function getNotEnoughXpText()
	{
		var text = new FlxText(0, 0, 0, 'Not enough XP');
		text.setFormat(Fonts.STANDARD_FONT, 24, FlxColor.RED);
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);
		return text;
	}

	public function new(canAfford:Bool = true, w:Int = 200, h:Int = 270)
	{
		super();

		var body = new FlxSprite(0, 0);
		body.makeGraphic(w, h, FlxColor.fromRGB(0, 0, 0, 128));
		body.centerSprite();
		add(body);

		this.clickToBuyText = ViewUtils.getClickToSomethingText('Buy');
		this.notEnoughXpText = getNotEnoughXpText();
		clickToBuyText.centerSprite();
		notEnoughXpText.centerSprite();
		add(clickToBuyText);
		add(notEnoughXpText);

		this.canAfford = canAfford;
	}
}
