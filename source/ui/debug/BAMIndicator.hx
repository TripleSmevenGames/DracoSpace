package ui.debug;

import flixel.text.FlxText;
import managers.BattleAnimationManager;
import openfl.system.System;

@:access(managers.BattleAnimationManager)
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
		var groupState = 'null';
		if (!BAM.isQueueEmpty())
		{
			firstItemLength = BAM.queue[0].tweens.length + BAM.queue[0].spriteAnims.length;
			groupState = BAM.queue[0].state.getName();
		}
		text = 'BAM: in Q: ${BAM.queue.length}, itemsInCurrentGroup: ${firstItemLength}, groupState: ${groupState}';
		super.update(elapsed / 2);
	}
}
