package ui.battle;

import constants.Constants.Colors;
import constants.Constants.UIMeasurements;
import flixel.addons.ui.FlxUIBar;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.ViewUtils;

/** A FlxUIBar but with a callback when it gets updated. Also changes color based on the value.**/
class HpBarSprite extends FlxUIBar
{
	var text:FlxText;

	public function new(x:Float, y:Float, text:FlxText)
	{
		super(x, y);
		this.text = text;
	}

	override public function updateBar()
	{
		var emptyColor = Colors.BACKGROUND_BLUE;
		var fillColor = Colors.DARK_GREEN;
		if (this.percent < 25)
			fillColor = Colors.DARK_RED;
		else if (this.percent < 75)
			fillColor = Colors.DARK_YELLOW;

		this.createFilledBar(emptyColor, fillColor);

		if (this.parent != null)
			this.text.text = '${this.value}/${this.max}';

		super.updateBar();
	}
}

/** Character HP and block indicator during a battle. **/
class CharacterHpBar extends FlxSpriteGroup
{
	var bar:HpBarSprite;
	var numbers:FlxText;
	var blockIndicator:BattleIndicatorIcon;
	var character:CharacterSprite;

	static inline final BAR_WIDTH = 100;
	static inline final BAR_HEIGHT = 32;
	static inline final NUM_FONT_SIZE = 16;

	public function updateBlockIndicator(val:Int)
	{
		blockIndicator.updateDisplay(Std.string(val));
	}

	public function new(character:CharacterSprite)
	{
		super(0, character.sprite.height);

		this.character = character;

		numbers = new FlxText(0, 0, BAR_WIDTH, '0/0');
		numbers.setFormat(AssetPaths.DOSWin__ttf, NUM_FONT_SIZE, FlxColor.WHITE, FlxTextAlign.CENTER);
		ViewUtils.centerSprite(numbers, BAR_WIDTH / 2, BAR_HEIGHT / 2);

		bar = new HpBarSprite(0, 0, numbers);

		// let the bar watch the character's hp
		bar.parent = character;
		bar.parentVariable = 'currHp';

		bar.width = 100;
		bar.height = 32;
		bar.setRange(0, character.maxHp);

		// set up the colors for the bar
		var emptyColor = Colors.BACKGROUND_BLUE;
		var fillColor = Colors.DARK_GREEN;
		bar.createFilledBar(emptyColor, fillColor, true);

		// block indicator must be explicitly updaated.
		blockIndicator = new BattleIndicatorIcon(AssetPaths.Block__png, 2, 16, Colors.BACKGROUND_BLUE, null, 'Block prevents damage until your next turn.');
		blockIndicator.setPosition(bar.width, 0 - blockIndicator.icon.height / 2);

		add(bar);
		add(numbers);
		add(blockIndicator);
	}
}
