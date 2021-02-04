package utils;

import flixel.FlxBasic;
import flixel.addons.nape.FlxNapeSprite;
import flixel.animation.FlxAnimation;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;

enum BattleAnimationGroupState
{
	WAITING;
	ACTIVE;
	DONE;
}

typedef BattleAnimationGroupOptions =
{
	?onStartAll:Void->Void,
	?onCompleteAll:Void->Void,
	?effect:Void->Void,
	?effectFrame:Int,
}

/** An animation group holds an array of FlxTweens or FlxAnimations, collectively known here as "animations".
 *
 * When it's this groups turn in the BAM's queue, all the flxanimations and tweens will play.
**/
class BattleAnimationGroup
{
	public var tweens:Array<FlxTween> = [];
	public var spriteAnims:Array<FlxAnimation> = [];
	public var onStartAll:Void->Void;
	public var onCompleteAll:Void->Void;
	// You may want to run some code at certain point in time of the animation.
	// E.g. on the 5th frame of this attack animation, run the dealDamage() function.
	// Assumes you are referring to the first flxAnimation in the array.
	public var effect:Void->Void;
	public var effectFrame:Int = 0;

	var effectPlayed:Bool = false;
	var state:BattleAnimationGroupState = WAITING;

	/** Fire off all the animations and tweens**/
	public function play()
	{
		for (tween in tweens)
			tween.active = true;
		for (spriteAnim in spriteAnims)
			spriteAnim.parent.play(spriteAnim.name);

		// if there's no sprite animation, then there's no effect to play. Assume it's been played then.
		if (spriteAnims.length == 0)
			effectPlayed = true;

		onStartAll();
		state = ACTIVE;
	}

	public function update()
	{
		if (state != ACTIVE)
			return;

		if (!effectPlayed && spriteAnims.length > 0 && spriteAnims[0].curFrame >= effectFrame)
		{
			effect();
			effectPlayed = true;
		}

		for (tween in tweens)
		{
			if (tween.finished)
			{
				tweens.remove(tween);
				tween.destroy();
			}
		}

		for (spriteAnim in spriteAnims)
		{
			if (spriteAnim.finished)
				spriteAnims.remove(spriteAnim);
		}

		if (tweens.length == 0 && spriteAnims.length == 0)
		{
			onCompleteAll();
			state = DONE;
			if (!effectPlayed)
			{
				trace('uh oh, anim group finished without the effect playing.');
			}
		}
	}

	function getDefaultOptions(options:BattleAnimationGroupOptions)
	{
		if (options == null)
		{
			options = {};
		}
		if (options.onStartAll == null)
			options.onStartAll = () -> {};
		if (options.onCompleteAll == null)
			options.onCompleteAll = () -> {};
		if (options.effect == null)
			options.effect = () -> {};
		if (options.effectFrame == null)
			options.effectFrame = 0;

		return options;
	}

	public function new(tweens:Array<FlxTween>, spriteAnims:Array<FlxAnimation>, ?options:BattleAnimationGroupOptions)
	{
		options = getDefaultOptions(options);

		// cancel all the tweens, as they will be played as soon as they are created.
		for (tween in tweens)
			tween.active = false;

		this.tweens = tweens;
		this.spriteAnims = spriteAnims;
		this.onStartAll = options.onStartAll;
		this.onCompleteAll = options.onCompleteAll;
		this.effect = options.effect;
		this.effectFrame = options.effectFrame;

		this.state = WAITING;
		this.effectPlayed = false;
	}
}

/** Allows you to put groups of animations in a queue.
 *
 * Each group is played at the same time. The next group in line is played after all the animations in the current group are done.
**/
@:access(utils.BattleAnimationGroup)
class BattleAnimationManager extends FlxBasic
{
	var queue:Array<BattleAnimationGroup> = [];

	/** Reset the BAM for a new battle. Make sure you add() this after the battle view has been set up. **/
	public function reset()
	{
		this.revive();

		// possible memory leak area
		queue = [];
	}

	/** Use this function to check if there are no more animations to come. **/
	public function isQueueEmpty()
	{
		return queue.length == 0;
	}

	/** Create a new BAG with only tweens and add it to the queue. **/
	public function addTweens(tweens:Array<FlxTween>, ?options:BattleAnimationGroupOptions)
	{
		var bag = new BattleAnimationGroup(tweens, [], options);
		queue.push(bag);
	}

	/** Create a new BAG with only FlxAnimations and add it to the queue. **/
	public function addAnimations(spriteAnims:Array<FlxAnimation>, ?options:BattleAnimationGroupOptions)
	{
		var bag = new BattleAnimationGroup([], spriteAnims, options);
		queue.push(bag);
	}

	/** Create a new BattleAnimationGroup and add it to the BAM's queue. **/
	public function addGroup(tweens:Array<FlxTween>, spriteAnims:Array<FlxAnimation>, ?options:BattleAnimationGroupOptions)
	{
		var bag = new BattleAnimationGroup(tweens, spriteAnims, options);
		queue.push(bag);
	}

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		if (isQueueEmpty())
			return;

		var next = queue[0];
		if (next.state == WAITING)
		{
			next.play();
		}
		else if (next.state == ACTIVE)
		{
			next.update();
		}
		else if (next.state == DONE)
		{
			queue.shift();
		}
		super.update(elapsed);
	}
}
