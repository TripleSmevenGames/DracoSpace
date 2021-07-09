package ui.battle.combatUI;

import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import managers.GameController;

using utils.ViewUtils;

/** A banner that spans the whole screen, which will fade in when player/enemy turn starts. Centered. **/
class TurnBanner extends FlxSpriteGroup
{
	var body:FlxSprite;
	var text:FlxText;

	static inline final HEIGHT = 80;
	static inline final FONT_SIZE = 80;

	/** Adds a fade in then out tween to the BAM. Add in a text for the banner to show**/
	public function queueAnimation(text:String = '')
	{
		this.text.text = text;
		this.text.centerSprite(this.x, this.y);

		// Fade in for .25 seconds, pause for 1 second, then fade out for .25 seconds.
		var tweenIn = FlxTween.tween(this, {alpha: 1}, .25);
		// because this tween uses a .then(), the tween in there won't be queued up by the BAM (but its still queued up by the global tween manager)
		var tweenOut = FlxTween.tween(this, {alpha: 1}, 1).then(FlxTween.tween(this, {alpha: 0}, .25));

		GameController.battleAnimationManager.addTweens([tweenIn]);
		GameController.battleAnimationManager.addTweens([tweenOut]);
	}

	public function new()
	{
		super();

		var gradient = [FlxColor.fromRGB(0, 0, 0, 150), FlxColor.TRANSPARENT];
		this.body = FlxGradient.createGradientFlxSprite(FlxG.width, HEIGHT, gradient, 8);
		body.centerSprite();
		add(body);

		this.text = new FlxText();
		text.setFormat(Fonts.STANDARD_FONT2, FONT_SIZE);
		text.centerSprite();
		add(text);

		this.alpha = 0;
	}
}
