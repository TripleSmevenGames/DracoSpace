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
		var firstItemLength = 0;
		if (!BAM.isQueueEmpty())
		{
			firstItemLength = BAM.queue[0].tweens.length + BAM.queue[0].spriteAnims.length;
		}
		text = 'BAM: in Q: ${BAM.queue.length}, itemsLeft: ${firstItemLength}';
		super.update(elapsed / 2);
	}
}
