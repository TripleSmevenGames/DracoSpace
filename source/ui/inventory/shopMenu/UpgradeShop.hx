package ui.inventory.shopMenu;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.GameController;
import models.CharacterInfo;
import models.player.Player;
import ui.inventory.shopMenu.SkillShop.SkillShopChoiceCover;
import utils.ViewUtils;

using utils.ViewUtils;

/** The portion of the shop that shows the upgrades. Centered on X only. **/
class UpgradeShop extends FlxSpriteGroup
{
	public static var skillSlotUpgradePrice = [0, 10, 20, 30, 40];
	public static var drawUpgradePrice = [0, 0, 10, 25, 40, 60];

	var items:Array<UpgradeShopItem>;
	var refreshShopMenu:Void->Void;

	public function refresh()
	{
		for (item in items)
			item.refresh();

		// refresh the header because it shows the XP, which can change if the player spends XP.
		GameController.header.refresh();
	}

	static function getSkillSlotUpgradePrice(char:CharacterInfo)
	{
		if (char.numSkillSlots < skillSlotUpgradePrice.length)
			return skillSlotUpgradePrice[char.numSkillSlots];
		else
			return skillSlotUpgradePrice[skillSlotUpgradePrice.length - 1];
	}

	static function getDrawUpgradePrice()
	{
		if (Player.deck.draw < drawUpgradePrice.length)
			return drawUpgradePrice[Player.deck.draw];
		else
			return drawUpgradePrice[drawUpgradePrice.length - 1];
	}

	function createSkillSlotUpgradeItem(char:CharacterInfo)
	{
		var avatar = new FlxSprite(char.avatarPath);
		avatar.scale3x();
		var title = 'Upgrade Skill Slots';
		var subtitle = '${char.numSkillSlots}/${Player.MAX_SKILL_SLOTS}';
		var price = getSkillSlotUpgradePrice(char);
		var onClick = (item:UpgradeShopItem) ->
		{
			if (Player.exp >= item.price && char.numSkillSlots < Player.MAX_SKILL_SLOTS)
			{
				Player.exp -= item.price;
				char.numSkillSlots += 1;

				var sound = FlxG.sound.load(AssetPaths.purchase__wav);
				sound.play();

				var newPrice = getSkillSlotUpgradePrice(char);
				var newSubtitle = '${char.numSkillSlots}/${Player.MAX_SKILL_SLOTS}';
				item.updatePriceAndSubtitle(newPrice, newSubtitle);
				// trigger a refresh of the entire ShopMenu (almost like a React state change)
				refreshShopMenu();
			}
			else
			{
				var sound = FlxG.sound.load(AssetPaths.error__wav);
				sound.play();
			}
		}
		return new UpgradeShopItem(avatar, title, subtitle, price, onClick);
	}

	function createDrawUpgradeItem()
	{
		var icon = new FlxSprite(AssetPaths.plusDraw__png);
		icon.scale3x();
		var title = 'Upgrade Deck Draw';
		var subtitle = '${Player.deck.draw}';
		var price = getDrawUpgradePrice();

		var onClick = (item:UpgradeShopItem) ->
		{
			if (Player.exp >= item.price && Player.deck.draw < 8)
			{
				Player.exp -= price;
				Player.deck.draw += 1;

				var sound = FlxG.sound.load(AssetPaths.purchase__wav);
				sound.play();

				var newPrice = getDrawUpgradePrice();
				var newSubtitle = '${Player.deck.draw}';
				item.updatePriceAndSubtitle(newPrice, newSubtitle);
				// trigger a refresh of the entire ShopMenu (almost like a React state change)
				refreshShopMenu();
			}
			else
			{
				var sound = FlxG.sound.load(AssetPaths.error__wav);
				sound.play();
			}
		}
		return new UpgradeShopItem(icon, title, subtitle, price, onClick);
	}

	public function new(refreshShopMenu:Void->Void)
	{
		super();
		this.refreshShopMenu = refreshShopMenu;

		var titleText = new FlxText(0, 0, 0, 'UPGRADE SHOP');
		titleText.setFormat(Fonts.STANDARD_FONT, UIMeasurements.MENU_FONT_SIZE_TITLE, FlxColor.YELLOW);
		titleText.centerX();
		add(titleText);

		this.items = new Array<UpgradeShopItem>();

		// create an "Upgrade skill slots" item for each character
		for (char in Player.chars)
		{
			var item = createSkillSlotUpgradeItem(char);
			items.push(item);
		}

		// create the draw upgrade item
		items.push(createDrawUpgradeItem());

		// now, render them
		var yPos = titleText.height + 16 + items[0].height / 2;
		for (i in 0...items.length)
		{
			var item = items[i];
			var xPos = ViewUtils.getXCoordForCenteringLR(i, items.length, item.width, 16);
			item.setPosition(xPos, yPos);
			add(item);
		}

		var background = ViewUtils.newSlice9(AssetPaths.shopBg__png, 20, 20, [8, 8, 40, 40]);
	}
}

/** Centered. **/
class UpgradeShopItem extends FlxSpriteGroup
{
	var body:FlxSprite;
	var highlight:SkillShopChoiceCover;
	var priceSprite:FlxText;

	public var price:Int;
	public var subtitleText:FlxText;

	override public function get_width()
	{
		return body.width;
	}

	override public function get_height()
	{
		return body.height;
	}

	public function updatePriceAndSubtitle(price:Int, subtitle:String)
	{
		this.price = price;
		this.subtitleText.text = subtitle;
		refresh();
	}

	public function refresh()
	{
		var color = ViewUtils.getPriceColor(price);
		priceSprite.text = '${Std.string(price)} XP';
		priceSprite.setFormat(Fonts.STANDARD_FONT, 32, color);

		var canAfford = Player.exp >= price;
		highlight.canAfford = canAfford;
	}

	/** Stacks the icon, then the title, then the subtitle vertically. centered on X. **/
	function createContent(icon:FlxSprite, title:String, subtitle:String):FlxSpriteGroup
	{
		var group = new FlxSpriteGroup();

		var titleText = new FlxText(0, 0, body.width, title);
		titleText.setFormat(Fonts.STANDARD_FONT, 32, FlxColor.WHITE, 'center');
		this.subtitleText = new FlxText(0, 0, body.width, subtitle);
		subtitleText.setFormat(Fonts.STANDARD_FONT, 28, FlxColor.WHITE, 'center');

		var sprites = [icon, titleText, subtitleText];
		var yCursor:Float = 32;
		for (sprite in sprites)
		{
			sprite.y = yCursor;
			sprite.centerX();
			group.add(sprite);
			yCursor += sprite.height;
		}

		return group;
	}

	/** Get the sprite showing this price. Basically a number + 'XP' sprite. Not centered **/
	static function getPriceSprite(price:Int = 0, sale:Bool = false)
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

	public function new(icon:FlxSprite, title:String, subtitle:String, price:Int, onClick:UpgradeShopItem->Void)
	{
		super();

		// create the background body, which is a grey square.
		var bodyWidth = 230;
		var bodyHeight = 230;
		body = ViewUtils.newSlice9(AssetPaths.upgradeShopItem__png, bodyWidth, bodyHeight, [4, 4, 12, 12]);
		body.centerSprite();
		add(body);

		// add the content inside the box
		var content = createContent(icon, title, subtitle);
		content.setPosition(0, -body.height / 2);
		add(content);

		// add the price under the box
		var color = ViewUtils.getPriceColor(price);
		this.price = price;
		this.priceSprite = getPriceSprite(price);
		priceSprite.setFormat(Fonts.STANDARD_FONT, 32, color);
		priceSprite.centerSprite(0, body.height / 2 + 16);
		add(priceSprite);

		// add the onClick
		body.addScaledToMouseManager(false);
		FlxMouseEventManager.setMouseClickCallback(body, (_) -> onClick(this));

		// add a highlight effect that says "LMB to  buy" or "Not enough xp" on it when you hover over it.
		// this.highlight = new SkillShopChoiceCover(false, bodyWidth, bodyHeight);
		this.highlight = new SkillShopChoiceCover(true, bodyWidth, bodyHeight);
		add(highlight);
		highlight.visible = false;
		FlxMouseEventManager.setMouseOverCallback(body, (_) -> highlight.visible = true);
		FlxMouseEventManager.setMouseOutCallback(body, (_) -> highlight.visible = false);
	}
}
