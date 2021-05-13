package ui.inventory;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;
import models.skills.Skill;
import ui.battle.win.SkillCard;
import utils.battleManagerUtils.RewardHelper;

using utils.ViewUtils;

/** The parent group that represents the entire skill shop UI. Centered X only. **/
class SkillShop extends FlxSpriteGroup
{
	public var skillShopChoices:Array<SkillShopChoice>;

	static var random:FlxRandom = new FlxRandom();

	public function new()
	{
		super();

		var titleText = new FlxText(0, 0, 0, 'SKILL SHOP');
		titleText.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		titleText.centerX();
		add(titleText);

		var skillChoices = RewardHelper.getShopChoices();

		var onClick = (skillShopChoice:SkillShopChoice) ->
		{
			if (Player.exp >= skillShopChoice.price)
			{
				Player.exp -= skillShopChoice.price;
				Player.gainSkill(skillShopChoice.skill);
				remove(skillShopChoice);
				skillShopChoice.destroy();
			}
		}

		// render the row of shop choices, which are skills the player can buy.
		var centerY = titleText.height + 4 + SkillCard.bodyHeight / 2;
		for (i in 0...skillChoices.length)
		{
			// create the skillcard with the shop cover.
			var skill = skillChoices[i];
			var skillShopChoice = new SkillShopChoice(skill);
			var xPos = ViewUtils.getXCoordForCenteringLR(i, skillChoices.length, SkillCard.bodyWidth, 4);
			skillShopChoice.setPosition(xPos, centerY);
			skillShopChoices.push(skillShopChoice);
			skillShopChoice.setOnClick(onClick);
			add(skillShopChoice);
		}
	}
}

/** A group representing an skill to buy in the shop. Really just a SkillCard and a FlxText for the price. Centered on the SkillCard. **/
class SkillShopChoice extends FlxSpriteGroup
{
	public var price:Int;
	public var skill:Skill;

	var skillCard:SkillCard;

	static var random:FlxRandom = new FlxRandom();

	/** Get the actual number price for a skill. **/
	static function getSkillPrice(sale = false):Int
	{
		var basePrice = 10;
		var multiplier = Player.skillsBought * (sale ? 1 / 2 : 1); // sales give half off
		var modifier = random.int(-5, 5);

		return Std.int((basePrice * multiplier) + modifier);
	}

	/** Get the sprite showing this price. Basically a number + 'XP' sprite. Not centered **/
	static function getSkillPriceSprite(price:Int = 0, sale:Bool = false)
	{
		var textSprite = new FlxText(0, 0, 0, Std.string(price) + ' XP');
		textSprite.setFormat(Fonts.STANDARD_FONT, 32, sale ? FlxColor.YELLOW : FlxColor.WHITE);
		textSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		return textSprite;
	}

	public function setOnClick(onClick:SkillShopChoice->Void)
	{
		// the skill card part is already added to the mouse manager, so dont need to do it again here.
		FlxMouseEventManager.setMouseClickCallback(this.skillCard, (_) -> onClick(this));
	}

	public function new(skill:Skill)
	{
		super();
		this.skill = skill;

		// create the skillcard with the shop cover.
		this.skillCard = new SkillCard(skill, SHOPCOVER);
		add(skillCard);

		// now create the price sprite underneath. 20% chance to be on sale.
		var sale = random.int(1, 5) == 1;
		this.price = getSkillPrice(sale);
		var priceSprite = getSkillPriceSprite(price, sale);
		priceSprite.centerSprite(0, SkillCard.bodyHeight / 2 + 4);
		add(priceSprite);
	}
}

/** A highlight cover that shows "click to buy" over a skill card choice in the shop. Centered. **/
class SkillShopChoiceCover extends FlxSpriteGroup
{
	/** Not centered. **/
	static function getClickToBuyText()
	{
		var group = new FlxSpriteGroup();

		var lmbIcon = new FlxSprite(0, 0, AssetPaths.LMB__png);
		lmbIcon.scale2x();
		group.add(lmbIcon);

		var buyText = new FlxText(0, 0, 0, 'Buy');
		buyText.setFormat(Fonts.STANDARD_FONT, 24);
		buyText.setPosition(lmbIcon.width + 4, 0);
		group.add(buyText);

		return group;
	}

	public function new()
	{
		super();

		var body = new FlxSprite(0, 0);
		body.makeGraphic(SkillCard.bodyWidth, SkillCard.bodyHeight, FlxColor.fromRGB(0, 0, 0, 128));
		body.centerSprite();
		add(body);

		var clickToBuyText = getClickToBuyText();
		clickToBuyText.centerSprite();
		add(clickToBuyText);
	}
}
