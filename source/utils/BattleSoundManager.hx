package utils;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;

enum SoundType
{
	FLESH;
	SLIME;
	ROCK;
	GHOST;
	PLANT;
}

/** Instead of each sprite creating/saving its own sound files to play, have this manager hold and play them instead.
 * You must create an instance of the manager everytime you start the battle.
 * And destroy the instance (to free up memory held by the sounds) at the end.
**/
class BattleSoundManager extends FlxGroup
{
	public static var fleshHit1 = AssetPaths.standardHit4__wav;
	public static var fleshHit2 = AssetPaths.standardHit5__wav;
	public static var slimeHit1 = AssetPaths.slimeHit1__wav;
	public static var slimeHit2 = AssetPaths.slimeHit2__wav;
	public static var rockHit = AssetPaths.rockHit1__wav;
	public static var ghostHit = AssetPaths.ghostHit1__wav;
	public static var woodHit = AssetPaths.woodHit1__wav;
	public static var plantHit = AssetPaths.plantHit1__wav;
	public static var blocked = AssetPaths.blockedHit1__wav;
	public static var gainBlock = AssetPaths.gainBlock1__wav;
	public static var miss = AssetPaths.miss1__wav;
	public static var heal = AssetPaths.heal1__wav;

	static var map:Map<SoundType, Array<FlxSoundAsset>> = [
		FLESH => [fleshHit1, fleshHit2],
		SLIME => [slimeHit1, slimeHit2],
		ROCK => [rockHit],
		GHOST => [ghostHit],
		PLANT => [plantHit],
	];

	public static function getHitSoundArrayForType(type:SoundType)
	{
		if (type != null && map.exists(type))
			return map.get(type);
		else
			return map.get(FLESH);
	}

	/** store a cache of FlxSounds so we dont have to reload them every time.**/
	var cache:Map<String, FlxSound>;

	/** Play a sound from a cache, or creates then caches the sound if its not in there already. **/
	public function playSound(assetPath:String)
	{
		// if the cache doesn't have this sound, create it and store it.
		if (!cache.exists(assetPath))
		{
			var sound = FlxG.sound.load(assetPath);
			cache.set(assetPath, sound);
			add(sound); // adding this sound means it will be destroyed when the group is destroyed, freeing up memory.
		}

		// finally, play the sound
		cache.get(assetPath).play(true);
	}

	public function new()
	{
		super();
		this.cache = new Map<String, FlxSound>();
	}
}
