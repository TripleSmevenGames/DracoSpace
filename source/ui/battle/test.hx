package ui.battle;

import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.misc.VarTween;

@:access(flixel.tweens)
@:access(flixel.tweens.FlxTween)
class MyTweenManager extends FlxTweenManager
{
	public function new()
	{
		super();
		var tween = new VarTween();
	}
}
