package ui.battle;

import constants.Fonts;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import utils.ViewUtils;

/**refer to https://github.com/HaxeFlixel/flixel-demos/tree/master/Features/FlxNape 
 * A single "damage number", or thing that pops out of a character when something happens to them.
 * Doesn't have to be a number, could be a status like "STUN".
**/
class DamageNumber extends FlxSpriteGroup
{
	// the text object which follows the nape sprite
	var referenceText:FlxText;

	// the sprite which will be invisible, but affected by physics.
	var napeSprite:FlxNapeSprite;

	static inline final BASE_FONT_SIZE = 50;

	public function init(val:String, color:FlxColor = FlxColor.WHITE, usePhysics:Bool = true)
	{
		referenceText.text = val;
		referenceText.alpha = 1;
		referenceText.color = color;
		referenceText.size = BASE_FONT_SIZE - (val.length * 3);
		ViewUtils.centerSprite(referenceText, this.x, this.y);

		napeSprite.physicsEnabled = usePhysics;
		// ViewUtils.centerSprite(napeSprite, this.x, this.y);
		napeSprite.setPosition(this.x, this.y);
	}

	public function setVelocity(x:Float, y:Float)
	{
		napeSprite.body.velocity.setxy(x, y);
	}

	public function fadeOut(seconds:Float = 1.5)
	{
		FlxTween.tween(referenceText, {alpha: 0}, seconds, {ease: FlxEase.quintIn}); // fade out very quickly near the end of the tween.
	}

	// call this after setting the initial position
	public function slowMoveUp(seconds:Float = 1.5)
	{
		FlxTween.tween(referenceText, {y: referenceText.y - 50}, seconds);
	}

	public function new()
	{
		super(0, 0);
		referenceText = new FlxText(0, 0, 0, '');
		referenceText.setFormat(Fonts.NUMBERS_FONT, BASE_FONT_SIZE);
		referenceText.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.fromRGB(0, 0, 0, 200), 3);

		napeSprite = new FlxNapeSprite(0, 0);
		napeSprite.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		napeSprite.createRectangularBody(1, 1);
		napeSprite.body.allowRotation = false;

		add(referenceText);
		add(napeSprite);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (napeSprite.physicsEnabled)
			referenceText.setPosition(napeSprite.x, napeSprite.y);
		if (!referenceText.isOnScreen() || referenceText.alpha == 0)
			kill();
	}
}

class DamageNumbers extends FlxTypedSpriteGroup<DamageNumber>
{
	static inline final POOL_SIZE = 5;
	static var instance:DamageNumbers;

	var random:FlxRandom;

	public function spawnDamageNumber(x:Float, y:Float, val:String, color:FlxColor = FlxColor.WHITE, usePhysics:Bool = true)
	{
		var damageNum = recycle(DamageNumber);
		damageNum.revive();
		damageNum.setPosition(x, y);
		damageNum.init(val, color, usePhysics);
		if (usePhysics)
			damageNum.setVelocity(random.int(-200, 200), -500);
		else
			damageNum.slowMoveUp();
		damageNum.fadeOut();
	}

	public function new()
	{
		super(0, 0);
		random = new FlxRandom();
		maxSize = POOL_SIZE;
		for (i in 0...POOL_SIZE)
		{
			var damageNum = new DamageNumber();
			damageNum.kill();
			add(damageNum);
		}
	}
}
