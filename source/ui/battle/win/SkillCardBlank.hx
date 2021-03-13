package ui.battle.win;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

using utils.ViewUtils;

/** Place holder for a skill card. Centered.**/
class SkillCardBlank extends FlxSpriteGroup
{
	public function new()
	{
		super();
		var body = new FlxSprite();
		body.makeGraphic(200, 280, FlxColor.GRAY);
		body.centerSprite();
		add(body);

		var frame = new FlxUI9SliceSprite(0, 0, AssetPaths.cardFrameGeneric__png, new Rectangle(0, 0, body.width, body.height), [5, 5, 15, 15]);
		frame.centerSprite();
		add(frame);

		var questionMark = new FlxText(0, 0, 0, '?');
		questionMark.setFormat(Fonts.STANDARD_FONT2, 50);
		questionMark.color = 0;
		questionMark.centerSprite();
		add(questionMark);
	}
}