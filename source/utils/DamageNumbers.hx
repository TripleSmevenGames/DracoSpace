package utils;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

// refer to https://github.com/HaxeFlixel/flixel-demos/tree/master/Features/FlxNape
class DamageNumber extends FlxSpriteGroup
{
	// the text object which follows the nape sprite
	var referenceText:FlxText;

	// the sprite which will be invisible, but affected by physics.
	var napeSprite:FlxNapeSprite;

	public function init(val:String)
	{
		referenceText.text = val;
		referenceText.alpha = 1;
		referenceText.setPosition(this.x, this.y);
		napeSprite.setPosition(this.x, this.y);
	}

	public function setVelocity(x:Float, y:Float)
	{
		napeSprite.body.velocity.setxy(x, y);
	}

	public function fadeOut(seconds:Float = 2)
	{
		FlxTween.tween(referenceText, {alpha: 0}, seconds, {ease: FlxEase.quintIn}); // fade out very quickly near the end of the tween.
	}

	public function new()
	{
		super(0, 0);
		referenceText = new FlxText(0, 0, 0, 'null');
		referenceText.setFormat(AssetPaths.ka1__ttf, 32);

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
		referenceText.setPosition(napeSprite.x, napeSprite.y);
		if (!referenceText.isOnScreen())
			kill();
	}
}

class DamageNumbers extends FlxTypedSpriteGroup<DamageNumber>
{
	static inline final POOL_SIZE = 10;
	static var instance:DamageNumbers;

	var random:FlxRandom;

	public static function spawnDamageNumber(x:Float, y:Float, val:String)
	{
		instance._spawnDamageNumber(x, y, val);
	}

	function _spawnDamageNumber(x:Float, y:Float, val:String)
	{
		var damageNum = recycle(DamageNumber);
		damageNum.revive();
		damageNum.setPosition(x, y);
		damageNum.init(val);
		damageNum.setVelocity(random.int(-200, 200), random.int(-500, -400));
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

		instance = this;
	}
}
