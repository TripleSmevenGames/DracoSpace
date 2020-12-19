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
		super(0, 25, 0, 'BAM:', 12);
		this.BAM = BAM;
		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float)
	{
		var firstItemLength = null;
		if (BAM.animQueue.length != 0 ){
			firstItemLength = BAM.animQueue[0].anims.length;
		}
		text = 'BAM: in Q: ${BAM.animQueue.length}, anim: ${BAM.animating}, length: ${firstItemLength}';
		super.update(elapsed / 2);
	}
}
