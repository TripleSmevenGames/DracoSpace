package utils;

import flixel.FlxBasic;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;

/** This is just an FlxTween with a "holder" for the original onComplete. The animation
	manager will set the FlxTWeen's actual onComplete with its own.
**/
typedef BattleAnimation =
{
	var tween:FlxTween; // the tween to play
	var ?onComplete:Void->Void; // the function to run once it's complete
}

typedef BattleAnimGroup =
{
	var anims:Array<BattleAnimation>;
	var ?onStartAll:Void->Void;
	var ?onCompleteAll:Void->Void;
}

/** Allows you to put groups of animations in a queue.
 *
 * Each group is played at the same time. The next group in line is played after all the animations in the current group are done.
**/
@:access(flixel.tweens)
class BattleAnimationManager extends FlxBasic
{
	var animQueue:Array<BattleAnimGroup> = new Array<BattleAnimGroup>();

	// if are in the middle of an animation.
	var animating:Bool = false;

	/** reference to the current animation that is animating. */
	var currAnim:FlxTween;

	var damageNumbersPool:FlxTypedGroup<FlxNapeSprite>;

	/** Reset the BAM for a new battle. Make sure you add() this after the battle view has been set up. **/
	public function reset()
	{
		this.revive();

		// possible memory leak area
		animQueue = [];
		animating = false;
		currAnim = null;
	}

	/** Use this function to check if there are no more animations to come. **/
	public function isQueueEmpty()
	{
		if (animQueue.length > 0)
			return false;
		else
			return true;
	}

	/** Add a single animation to the queue to be animated. Returns the animation. **/
	public function addAnim(tween:FlxTween, ?onComplete:Void->Void)
	{
		var anim:BattleAnimation = {tween: tween, onComplete: onComplete};
		this.addAnims([anim]);
		return anim;
	}

	/** Add a multiple animations as a single group to the queue.
	 *
	 * This means they will all be played at the same time when their turn comes in the queue.
	 *
	 * Each individual animation has its own onComplete. Or you can use onStartAll and onCompleteAll.
	**/
	public function addAnims(anims:Array<BattleAnimation>, ?onStartAll:Void->Void, ?onCompleteAll:Void->Void)
	{
		for (anim in anims)
		{
			anim.tween.active = false;
		}
		var animGroup:BattleAnimGroup = {
			anims: anims,
			onStartAll: onStartAll,
			onCompleteAll: onCompleteAll,
		}

		animQueue.push(animGroup);
		return anims;
	}

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		if (isQueueEmpty())
			return;

		var animGroup = animQueue[0];
		var anims = animGroup.anims;
		if (animating)
		{
			if (anims.length != 0)
			{
				return;
			}
			else
			{
				animating = false;

				if (animGroup.onCompleteAll != null)
					animGroup.onCompleteAll();

				animQueue.shift();
			}
		}
		else
		{
			animating = true;

			if (animGroup.onStartAll != null)
				animGroup.onStartAll();

			for (anim in anims)
			{
				anim.tween.onComplete = (_) ->
				{
					if (anim.onComplete != null)
						anim.onComplete();

					anims.remove(anim);
				};
				anim.tween.active = true;
			}
		}
		super.update(elapsed);
	}
}
