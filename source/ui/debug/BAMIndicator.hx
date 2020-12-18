package ui.debug;

import flixel.text.FlxText;
import openfl.system.System;
import utils.BattleAnimationManager;

@:access(utils.BattleAnimationManager)
class BAMIndicator extends FlxText
{
	var BAM:BattleAnimationManager;

	public function new(BAM:BattleAnimationManager)
	{
		super(0, 30, 0, 'BAM:', 12);
		this.BAM = BAM;
		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float)
	{
		text = 'BAM: in Q: ${BAM.animQueue.length}, anim: ${BAM.animating}';
		super.update(elapsed / 2);
	}
}
