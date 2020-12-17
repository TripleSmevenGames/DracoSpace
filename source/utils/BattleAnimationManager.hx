package utils;

import flixel.FlxBasic;
import flixel.tweens.FlxTween;

/** This is just an FlxTween with a "holder" for the original onComplete. The animation
	manager will set the FlxTWeen's actual onComplete with its own.
**/
typedef BattleAnimation =
{
	var tween:FlxTween;
	var onComplete:Void->Void;
}

@:access(flixel.tweens)
class BattleAnimationManager extends FlxBasic
{
	var animQueue:Array<BattleAnimation> = new Array<BattleAnimation>();

	// if are in the middle of an animation.
	var animating:Bool = false;

	// reference to the current animation that is animating.
	var currAnim:FlxTween;

	/** Reset the BAM for a new battle **/
	public function reset()
	{
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

	/** Add an animation (a tween) to the queue to be animated. **/
	public function addAnim(tween:FlxTween, onComplete:Void->Void)
	{
		tween.active = false;
		var anim:BattleAnimation = {tween: tween, onComplete: onComplete};
		animQueue.push(anim);
	}

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		if (animating || isQueueEmpty())
		{
			return;
		}
		else
		{
			var anim = animQueue[0];
			animating = true;
			anim.tween.onComplete = (_) ->
			{
				anim.onComplete();
				this.animating = false;
				this.animQueue.shift();
			};
			try
			{
				anim.tween.active = true;
			}
			catch (err)
			{
				trace('the error is here: ${err.details}');
			}
		}
		super.update(elapsed);
	}
}
