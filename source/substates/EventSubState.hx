package substates;

import constants.Colors;
import constants.Fonts;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import managers.GameController;
import managers.SubStateManager;
import models.events.GameEvent;
import ui.buttons.EventChoiceButton;
import ui.header.Header;
import utils.ViewUtils;

using utils.ViewUtils;

/** The screen to show during an Event. Not centered. Place at 0, 0
 * This shows and stores one event at a time. The ESS manages the event stack for multi-part events.
**/
class EventView extends FlxSpriteGroup
{
	// reference to global sub state manager
	var ssm:SubStateManager;

	var titleSprite:FlxText;
	var descSprite:FlxText;
	var windowSprite:FlxUI9SliceSprite;
	var buttonsGroup:FlxSpriteGroup;
	var header:Header;

	public var event:GameEvent;

	static inline final TITLE_FONT_SIZE = 32;
	static inline final DESC_FONT_SIZE = 24;

	function centerSprites()
	{
		var centerX = FlxG.width / 2;
		var centerY = FlxG.height / 2;
		titleSprite.centerSprite(centerX, centerY - 200);
		descSprite.centerSprite(centerX, centerY);
		windowSprite.centerSprite(centerX, centerY);
	}

	/** Get a group of choice buttons to place on the screen. NOT centered.**/
	function getButtons():FlxSpriteGroup
	{
		var group = new FlxSpriteGroup();
		var cursorY:Float = 0;
		if (event != null)
		{
			for (choice in event.choices)
			{
				var button = new EventChoiceButton(choice);
				button.setPosition(0, cursorY);
				if (choice.disabled)
					button.alpha = .5;

				group.add(button);
				cursorY += button.height + 4;
			}
		}

		return group;
	}

	public function showEvent(event:GameEvent)
	{
		this.event = event;
		titleSprite.text = '${event.name}';
		descSprite.text = event.desc;

		centerSprites();

		if (buttonsGroup != null)
		{
			remove(buttonsGroup);
			buttonsGroup.destroy();
		}
		buttonsGroup = getButtons();
		// place the buttons so they'll all fit at the bottom of the window.
		var yPos = windowSprite.y + windowSprite.height - buttonsGroup.height - 16;
		buttonsGroup.setPosition(0, yPos);
		buttonsGroup.centerX(FlxG.width / 2);
		add(buttonsGroup);

		// update the header
		header.refresh();

		event.onEventShown();
	}

	public function new()
	{
		super();

		this.ssm = GameController.subStateManager;

		var backgroundGradient = [Colors.BACKGROUND_BLUE, Colors.BACKGROUND_LIGHT_BLUE];
		var background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, backgroundGradient, 8);
		add(background);

		this.header = new Header();
		add(header);

		var windowWidth = FlxG.width * (3 / 5);
		var windowHeight = FlxG.height / 2;
		windowSprite = ViewUtils.newSlice9(AssetPaths.eventBackground__png, windowWidth, windowHeight, [8, 8, 40, 40]);
		add(windowSprite);

		titleSprite = new FlxText(0, 0, 0, 'title');
		titleSprite.setFormat(Fonts.STANDARD_FONT, TITLE_FONT_SIZE);
		add(titleSprite);

		descSprite = new FlxText(0, 0, windowWidth * (3 / 4), 'this is a sample desc. You should not see this in a real game');
		descSprite.setFormat(Fonts.STANDARD_FONT, DESC_FONT_SIZE, FlxColor.WHITE, 'center');
		add(descSprite);
	}
}

// a substate containing the event view
class EventSubState extends FlxSubState
{
	public var view:EventView;
	public var eventStack:Array<GameEvent>;

	/** Shows the GameEvent on the screen, along with choices for the player to choose. **/
	public function showEvent(event:GameEvent)
	{
		FlxG.camera.scroll.x = 0;
		view.showEvent(event);
	}

	/** Init a new root game event. Remember to show it afterwards with showEvent. **/
	public function newRoot(event:GameEvent)
	{
		eventStack = [event];
	}

	/** Proceed into a new sub event. Usually you will call this in an event Choice's effect. **/
	public function goToSubEvent(event:GameEvent)
	{
		eventStack.push(event);
		showEvent(event);
	}

	/** go back to the previous event in the chain (ie. stack)**/
	public function goBack()
	{
		if (eventStack.length > 1)
		{
			eventStack.pop();
			showEvent(eventStack[eventStack.length - 1]);
		}
		else
		{
			trace('tried to go back on an event that had no parent. ${eventStack[0].name}');
		}
	}

	/** Reset the event stack back to the root and show it**/
	public function goToRoot()
	{
		if (eventStack.length != 0)
		{
			eventStack = eventStack.slice(0, 1);
			showEvent(eventStack[0]);
		}
		else
		{
			trace('tried to go back to event root, but there was no root.');
		}
	}

	override public function create()
	{
		super.create();
		this.view = new EventView();
		this.view.scrollFactor.set(0, 0);
		add(view);
	}
}
