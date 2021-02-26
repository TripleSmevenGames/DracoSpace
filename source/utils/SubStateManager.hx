package utils;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import models.events.BattleEvent;
import models.events.GameEvent;
import substates.BattleSubState;
import substates.EventSubState;
import substates.InventorySubState;
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
	var iss:InventorySubState;

	var returnHereFromInv:FlxSubState;

	/** if you pass in null, we "return" to the ess, instead of init'ing a new event.**/
	public function initEvent(?event:GameEvent)
	{
		var onFadeComplete = () ->
		{
			cleanupAll();
			ess.revive();
			// the substate's sprites are not ready yet until the its opened.
			// so whatever want to happen once the state is ready, put in its openCallback.
			ess.openCallback = function()
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.25, true);
				if (event != null)
					ess.showEvent(event);
			}
			playState.openSubState(ess);
		}
		FlxG.camera.fade(FlxColor.BLACK, 0.25, false, onFadeComplete);
	}

	public function initBattle(event:BattleEvent)
	{
		var onFadeComplete = () ->
		{
			cleanupAll();
			bss.revive();
			bss.openCallback = function()
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.25, true);
				bss.initBattle(event);
			};
			playState.openSubState(bss);
		};

		FlxG.camera.fade(FlxColor.BLACK, 0.25, false, onFadeComplete);
	}

	public function openInventory()
	{
		if (playState.subState == bss)
			throw new haxe.Exception('Tried to open inventory from bss');

		returnHereFromInv = playState.subState;

		var onFadeComplete = () ->
		{
			cleanupAll();
			iss.revive();
			iss.openCallback = () -> FlxG.camera.fade(FlxColor.BLACK, 0.25, true);
			playState.openSubState(iss);
		};
		FlxG.camera.fade(FlxColor.BLACK, 0.25, false, onFadeComplete);
	}

	public function returnToMap()
	{
		var onFadeComplete = () ->
		{
			cleanupAll();
			mss.revive();
			mss.openCallback = function()
			{
				mss.onSwitch();
				FlxG.camera.fade(FlxColor.BLACK, 0.25, true);
			}
			GameController.battleAnimationManager.reset();
			playState.openSubState(mss);
		};

		FlxG.camera.fade(FlxColor.BLACK, 0.25, false, onFadeComplete);
	}

	public function returnToPreviousFromInv()
	{
		if (returnHereFromInv == mss)
			returnToMap();
		else if (returnHereFromInv == ess)
			initEvent(null);
		else
			throw new haxe.Exception('tried to return to previous from inv, but returnHere was wack');
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
		iss.kill();
		bss.cleanup();
		iss.cleanup();
	}

	public function new(playState:PlayState)
	{
		this.playState = playState;
		mss = new MapSubState();
		ess = new EventSubState();
		bss = new BattleSubState();
		iss = new InventorySubState();
	}
}
