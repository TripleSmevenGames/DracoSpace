package utils;

import models.events.BattleEvent;
import models.events.GameEvent;
import substates.BattleSubState;
import substates.EventSubState;
import substates.MapSubState;

// handles sub state swaps in playState
@:access(substates.BattleSubState)
@:access(substates.BattleSubState.BattleView)
class SubStateManager
{
	var playState:PlayState;

	var mss:MapSubState;
	var ess:EventSubState;
	var bss:BattleSubState;

	public function initEvent(event:GameEvent)
	{
		cleanupAll();
		ess.revive();
		playState.openSubState(ess);
		// the substate's sprites are not ready yet until the its opened.
		// so whatever want to happen once the state is ready, put in its openCallback.
		ess.openCallback = function()
		{
			ess.showEvent(event);
		}
	}

	public function initBattle(event:BattleEvent)
	{
		cleanupAll();
		bss.revive();
		playState.openSubState(bss);
		bss.openCallback = function()
		{
			bss.initBattle(event);
		}
	}

	public function returnToMap()
	{
		cleanupAll();
		mss.revive();
		playState.openSubState(mss);
		mss.openCallback = function()
		{
			mss.onSwitch();
		}
		GameController.battleAnimationManager.reset();
	}

	// paranoid function to free up memory. Might be un-needed.
	public function destroyAll()
	{
		trace('destroyAll in ssm was called');
		mss.destroy();
		ess.destroy();
		bss.destroy();
	}

	// killing the state prevents it from recieving click events
	public function cleanupAll()
	{
		mss.kill();
		ess.kill();
		bss.kill();
		bss.cleanup();
	}

	public function new(playState:PlayState)
	{
		this.playState = playState;
		mss = new MapSubState();
		ess = new EventSubState();
		bss = new BattleSubState();
	}
}
