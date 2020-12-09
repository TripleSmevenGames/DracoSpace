package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState
{
    function clickNew()
    {
        FlxG.switchState(new PlayState());
    }

    function clickContinue() 
    {
        FlxG.switchState(new PlayState());    
    }

    function clickExit()
    {
        Sys.exit(0);
    }

    override public function create() 
    {
        var titleText:FlxText;

        var newGameButton:FlxButton;
        var contButton:FlxButton;
        var exitButton:FlxButton;

        titleText = new FlxText(20, 0, 0, "DrakoSpace", 100);
        contButton = new FlxButton(0, 0, "Continue", clickContinue);
        newGameButton = new FlxButton(0, 0, "New Game", clickNew);
        exitButton = new FlxButton(0, 0, "Exit", clickExit);

        titleText.alignment = CENTER;
        titleText.screenCenter(X);
        add(titleText);

        newGameButton.x = (FlxG.width/2) - (newGameButton.width / 2);
        newGameButton.y = FlxG.height - newGameButton.height - contButton.height - exitButton.height - 30;
        add(newGameButton);

        contButton.x = (FlxG.width/2) - (contButton.width / 2);
        contButton.y = FlxG.height - exitButton.height - contButton.height - 20;
        add(contButton);

        exitButton.x = (FlxG.width/2) - (exitButton.width / 2); 
        exitButton.y =  FlxG.height - exitButton.height - 10;      
        add(exitButton);
    }
}