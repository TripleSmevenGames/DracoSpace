package ui.header;

import constants.Colors;
import constants.Fonts;
import constants.UIMeasurements;
import flixel.addons.ui.FlxUIBar;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.player.Player;

using utils.ViewUtils;

class ExpBar extends FlxUIBar
{
	var text:FlxText;

	public function new(text:FlxText, w:Int = 200, h:Int = 24)
	{
		super(0, 0, LEFT_TO_RIGHT, w, h);

		this.text = text;

		this.parent = Player;
		this.parentVariable = 'exp';
		this.setRange(0, Player.toNextLevel);

		var emptyColor = FlxColor.BLACK;
		var fillColor = Colors.KNOWLEDGE_BLUE;
		this.createFilledBar(emptyColor, fillColor, true);
	}

	override public function updateBar()
	{
		if (this.parent != null)
			this.text.text = '${this.value}/${this.max}';

		super.updateBar();
	}
}

/** Shows your level and exp. Centered on the level number display. **/
class ExpBarDisplay extends FlxSpriteGroup
{
	var levelDisplay:FlxText;
	var expBar:ExpBar;
	var expBarText:FlxText;

	public function refresh()
	{
		levelDisplay.text = Std.string(Player.level);
		expBar.setRange(0, Player.toNextLevel);
	}

	public function new()
	{
		super(0, 0);

		this.levelDisplay = new FlxText(0, 0, 0, '1');
		levelDisplay.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE_LG, Colors.WISDOM_PURPLE, FlxTextAlign.CENTER);
		levelDisplay.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 3);
		levelDisplay.centerSprite();

		this.expBarText = new FlxText(0, 0, 0);
		expBarText.setFormat(Fonts.NUMBERS_FONT, UIMeasurements.MAP_UI_FONT_SIZE_MED, FlxColor.WHITE, FlxTextAlign.CENTER);

		this.expBar = new ExpBar(expBarText);
		expBar.centerSprite(levelDisplay.width + expBar.width / 2, 0);
		// exp bar is a tiny bit off from the numbers, no idea why. So just manually adjust it.
		expBar.y -= 2;

		expBarText.centerSprite(levelDisplay.width + expBar.width / 2, 0);

		add(levelDisplay);
		add(expBar);
		add(expBarText);
	}
}
