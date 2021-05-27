package managers;

import flixel.FlxG;
import flixel.system.FlxSound;

/** Global manager for handling all switching and playing of music. **/
class MusicManager
{
	static var battleMusic:FlxSound;
	static var mapMusic:FlxSound;
	static var currentMusic:FlxSound;

	static var VOLUME = .25;

	static function fadeOutCurrentMusic()
	{
		// the currentMusic variable might be assigned to another music (the one fading in). So let's
		// keep a reference to the music that is fading out.
		var fadingOutMusic = currentMusic;
		if (fadingOutMusic != null)
		{
			// fade out, and remember to actually pause it after the fade completes.
			fadingOutMusic.fadeOut(1, 0, (_) -> fadingOutMusic.pause());
		}
	}

	static function fadeInNewMusic(music:FlxSound)
	{
		currentMusic = music;

		// if we're playing the map music, fade in from where we left off.
		if (currentMusic == mapMusic)
			music.play(false)
		else
			music.play(true);

		music.fadeIn(1, 0, VOLUME);
	}

	static function switchMusic(music:FlxSound)
	{
		if (currentMusic != music)
		{
			fadeOutCurrentMusic();
			fadeInNewMusic(music);
		}
	}

	public static function switchToBattle()
	{
		switchMusic(battleMusic);
	}

	public static function switchToMap()
	{
		switchMusic(mapMusic);
	}

	/** You need to call this every time the state (not substate) changes, because switching states destroys loaded sounds. **/
	public static function init()
	{
		battleMusic = FlxG.sound.load(AssetPaths.PennyArcade3Battle__ogg, VOLUME, true);
		mapMusic = FlxG.sound.load(AssetPaths.PennyArcade3Space__ogg, VOLUME, true);
	}
}
