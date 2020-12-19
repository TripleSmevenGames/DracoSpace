package utils;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;

class BattleSounds
{
	public var startPlayerTurn:FlxSound;
	public var endPlayerTurn:FlxSound;
	public var win:FlxSound;
	public var lose:FlxSound;

	function load(soundAsset:FlxSoundAsset)
	{
		return FlxG.sound.load(soundAsset);
	}

	public function new()
	{
		startPlayerTurn = load(AssetPaths.startTurn1__wav);
		endPlayerTurn = load(AssetPaths.endTurn1__wav);
	}
}
