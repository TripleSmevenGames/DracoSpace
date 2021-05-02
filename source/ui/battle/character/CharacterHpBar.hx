package ui.battle.character;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.addons.ui.FlxUIBar;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utils.ViewUtils;

/** A FlxUIBar but with a callback when it gets updated. Also changes color based on the value.**/
class HpBarSprite extends FlxUIBar
{
	var text:FlxText;

	public function new(x:Float, y:Float, width, height, text:FlxText)
	{
		super(x, y, LEFT_TO_RIGHT, width, height);
		this.text = text;
	}

	override public function updateBar()
	{
		var emptyColor = Colors.BACKGROUND_BLUE;
		var fillColor = FlxColor.GREEN;
		if (this.percent < 25)
			fillColor = FlxColor.RED;
		else if (this.percent < 75)
			fillColor = FlxColor.ORANGE;

		this.createFilledBar(emptyColor, fillColor, true);

		if (this.parent != null)
			this.text.text = '${this.value}/${this.max}';

		super.updateBar();
	}
}

/** Character HP and block indicator during a battle or on the header. **/
class CharacterHpBar extends FlxSpriteGroup
{
	var bar:HpBarSprite;
	var numbers:FlxText;
	var blockIndicator:BattleIndicatorIcon;
	var character:CharacterSprite;

	public function updateBlockIndicator(val:Int)
	{
		blockIndicator.updateDisplay(Std.string(val));
	}

	public function new(character:CharacterSprite, w:Int = 100, h:Int = 12, block:Bool = true)
	{
		super(0, 0);

		this.character = character;

		numbers = new FlxText(0, 0, w, '0/0');
		numbers.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_MED, FlxColor.WHITE, FlxTextAlign.CENTER);
		numbers.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		ViewUtils.centerSprite(numbers, 0, 0);

		bar = new HpBarSprite(0, 0, w, h, numbers);
		ViewUtils.centerSprite(bar);

		// let the bar watch the character's hp
		bar.parent = character;
		bar.parentVariable = 'currHp';
		bar.setRange(0, character.maxHp);

		// set up the colors for the bar
		var emptyColor = Colors.BACKGROUND_BLUE;
		var fillColor = Colors.CONSTITUTION_GREEN;
		bar.createFilledBar(emptyColor, fillColor, true);

		add(bar);
		add(numbers);
		if (block)
		{
			var options = {
				centered: true,
				color: FlxColor.BLACK,
			}
			blockIndicator = new BattleIndicatorIcon(AssetPaths.Block__png, null, 'Block prevents damage until your next turn.', options);
			blockIndicator.setPosition(bar.width / 2 + blockIndicator.icon.width / 2, 0);
			add(blockIndicator);
		}
	}
}
