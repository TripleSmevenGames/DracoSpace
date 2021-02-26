package ui.battle.win;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import ui.battle.win.SkillRewardCard;

using utils.ViewUtils;

/** Represents 1 reward item (money, exp, an item) */
class RewardItemSprite extends FlxSpriteGroup
{
	static inline final fontSize = 24;

	public function new(width:Float = 100, height:Int = 32, text:String)
	{
		super();

		var body = new FlxUI9SliceSprite(0, 0, AssetPaths.eventBackgroundLight__png, new Rectangle(0, 0, width, height), [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var textSprite = new FlxText(0, 0, 0, text);
		textSprite.setFormat(Fonts.STANDARD_FONT, fontSize);
		textSprite.centerSprite();
		add(textSprite);
	}
}

/** Represents the reward portion of the win screen. Money/exp gained, and possible level up reward. **/
class RewardsSprite extends FlxSpriteGroup
{
	static inline final titleFontSize = 36;

	public function new(leveledUp:Bool = false, expReward:Int, moneyReward:Int)
	{
		super();

		var bodyWidth = FlxG.width * .3;
		var bodyHeight = FlxG.height * .5;
		var body = new FlxUI9SliceSprite(0, 0, AssetPaths.eventBackground__png, new Rectangle(0, 0, bodyWidth, bodyHeight), [8, 8, 40, 40]);
		body.centerSprite();
		add(body);

		var titleSprite = new FlxText(0, 0, 0, 'YOUR REWARDS');
		titleSprite.setFormat(Fonts.STANDARD_FONT2, titleFontSize);
		titleSprite.setBorderStyle(FlxTextBorderStyle.SHADOW, 0, 3);
		// first, align the title with the body's top left corner, and move it down a bit.
		titleSprite.y = body.y + 16;
		// then, center it horizontally
		titleSprite.centerX();
		add(titleSprite);

		var itemWidth = Std.int(bodyWidth / 2);
		var itemHeight = 32;
		var items = new Array<FlxSprite>();
		var cursor = titleSprite.y + titleSprite.height + 32;

		// show the exp reward
		var expItem = new RewardItemSprite(itemWidth, itemHeight, '+$expReward EXP');
		items.push(expItem);

		// show the money reward
		var moneyItem = new RewardItemSprite(itemWidth, itemHeight, '+$moneyReward Dracocoins');
		items.push(moneyItem);

		// if you leveled up, show a button letting them claim a new skill.
		// clicking it will open a sub screen showing a choice of 3 skills to choose.
		// When they choose a skill, close the subscreen.
		if (leveledUp)
		{
			var onFinish = () -> {};
			var skillRewardButton = new SkillRewardButton(itemWidth, itemHeight, onFinish);
			items.push(skillRewardButton);
		}

		for (item in items)
		{
			item.y = cursor;
			add(item);
			cursor += item.height + 8;
		}
	}
}
