package ui.settings;

import flixel.FlxSprite;
import flixel.FlxG;

class settingsMenu extend FlxSpriteGroup
{
    var titleText:FlxText;
	var volumeBar:FlxBar;
	var volumeText:FlxText;
	var volumeAmountText:FlxText;
	var volumeDownButton:FlxButton;
	var volumeUpButton:FlxButton;
	var clearDataButton:FlxButton;
	var backButton:FlxButton;
	#if desktop
	var fullscreenButton:FlxButton;
	#end

	// a save object for saving settings
	var save:FlxSave;

    public function new() 
    {
        titleText = new FlxText(0, 20, 0, "Options", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

        muteButton = new FlxButton(FlxG.width - 28, 8, "Mute?", toggleMute);
        add(muteButton);

        super();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    function toggleMute{
        if (FlxG.keys.justPressed.M)
            {
                if (FlxG.sound.volume == 0)
                {
                    FlxG.sound.volume = originalVolume;
                }
                else
                {
                    originalVolume = FlxG.sound.volume;
                    FlxG.sound.volume = 0;
                }
            }
    }
}  