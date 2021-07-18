package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import managers.GameController;
import managers.SubStateManager;
import models.GameMap;
import models.events.*;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.*;
import models.events.encounterEvents.EncounterEventFactory;
import models.player.Player;
import ui.MapTile;
import ui.header.Header;
import utils.ViewUtils;

using flixel.util.FlxSpriteUtil;

typedef ColumnSprite = Array<MapTile>;

// the actual sprite representation of the map and its nodes.
class GameMapView extends FlxSpriteGroup
{
	var gameMap:GameMap;
	var columnSprites = new Array<ColumnSprite>();

	// flattened version of columnSprites
	public var mapTiles = new Array<MapTile>();

	public var currentTile:MapTile;

	// large sprite that draws the lines connecting the nodes
	var connectingLinesScreen:FlxSprite;

	// reference to global sub state manager
	var ssm:SubStateManager;

	var footstepSound:FlxSound;

	static inline final COL_WIDTH = 250;
	static inline final COL_HEIGHT = 800;

	public function markHere(mapTile:MapTile)
	{
		for (columnSprite in columnSprites)
		{
			for (mapTile in columnSprite)
			{
				mapTile.here = false;
			}
		}
		mapTile.here = true;
	}

	/** Return an event for given event type.
	 * For event types like Choice and Battle, it will return the next event in that type's randomized queue.
	**/
	function getEventForEventType(type:GameEventType):GameEvent
	{
		switch (type)
		{
			case BATTLE:
				return BattleEventFactory.getNextBattleEvent();
			case ELITE:
				return BattleEventFactory.getNextEliteEvent();
			case BOSS:
				return BossEventFactory.rattle();
			case ENCOUNTER:
				return EncounterEventFactory.getNextEvent();
			case CAMP:
				return new CampEvent();
			case CLEARING:
				return new ClearingEvent();
			case HOME:
				return new HomeEvent();
			case TREASURE:
				return TreasureEvent.getNextTreasureEvent();
			default:
				return GameEvent.getLeaveEvent('Sample', 'Something went wrong and there is no event to show.');
		}
	}

	/** Mark the node (ie the map tile) as visited, and open its event. **/
	public function visit(mapTile:MapTile)
	{
		if (currentTile.connectedNodesId.contains(mapTile.id))
		{
			currentTile = mapTile;
			Player.currentMapTile = mapTile;
			markHere(mapTile);
			footstepSound.play();

			var event = getEventForEventType(mapTile.node.eventType);
			ssm.initEvent(event);
		}
	}

	// draw lines between every node and its connected nodes in the next column
	function drawConnectingLines()
	{
		var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 10};
		var drawStyle:DrawStyle = {smoothing: false};
		connectingLinesScreen.makeGraphic(Math.round(this.width), Math.round(this.height), FlxColor.TRANSPARENT);
		for (mapTile in mapTiles)
		{
			for (id in mapTile.node.connectedNodesId)
			{
				var otherMapTile = mapTiles[id];
				connectingLinesScreen.drawLine(mapTile.x, mapTile.y, otherMapTile.x, otherMapTile.y, lineStyle, drawStyle);
			}
		}
	}

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		this.gameMap = new GameMap(16);
		this.ssm = GameController.subStateManager;

		// add the background
		var bg = new FlxSprite(0, 0, AssetPaths.desertbg__png);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		// add this screen first, so the connecting lines will be under the nodes
		this.connectingLinesScreen = new FlxSprite(0, 0);
		add(connectingLinesScreen);

		var random = new FlxRandom();
		var yOffset = FlxG.height / 2 - (COL_HEIGHT / 2); // offset so the nodes appear in the middle of the screen.
		var xOffset = 100; // give a bit of padding on the left side.
		for (i in 0...gameMap.columns.length)
		{
			var column = gameMap.columns[i];
			var columnSprite = new ColumnSprite();
			for (j in 0...column.length)
			{
				// set the mapTile's node and position on the map
				var node:Node = column[j];
				var xRandom = random.int(-40, 40);
				var yRandom = random.int(-40, 40);
				var xCoord = i * COL_WIDTH + xRandom + xOffset;
				var yCoord = (COL_HEIGHT / (column.length + 1) * (j + 1)) + yRandom + yOffset;
				var mapTile = new MapTile(node, xCoord, Std.int(yCoord));

				mapTile.addClickListener((_) -> visit(mapTile));
				mapTile.addHoverListener((_) -> mapTile.highlighted = true, (_) -> mapTile.highlighted = false);

				columnSprite.push(mapTile);
				mapTiles.push(mapTile);

				add(mapTile);
				var line = new FlxSprite(0, 0).makeGraphic(8, 8, FlxColor.WHITE);
				line.setPosition(xCoord, yCoord);
			}
			columnSprites.push(columnSprite);
		}

		drawConnectingLines();

		currentTile = mapTiles[0];
		markHere(currentTile);

		footstepSound = FlxG.sound.load(AssetPaths.footSteps1__wav);
	}
}

// a substate containing the map view
class MapSubState extends FlxSubState
{
	var view:GameMapView;
	var header:Header;

	/** The amount the user was scrolled on the map. We save this because when we switch from the map state, we scroll the camera back 
	 * to 0 for easer of rendering. But we when switch back to the map, we need to remember where the user was scrolled.
	**/
	var scrollX:Float = 0;

	static inline final SCROLL_SPEED = 25;

	/** Callback when we switch TO the map state.**/
	public function onSwitch()
	{
		if (header != null)
			header.refresh();

		FlxG.camera.scroll.x = scrollX;
	}

	override public function create()
	{
		super.create();
		view = new GameMapView(0, 0);
		add(view);

		this.header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);
	}

	function updateMovement()
	{
		var left:Bool = false;
		var right:Bool = false;

		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		if (left && right)
			left = right = false;

		if (left)
			FlxG.camera.scroll.x -= SCROLL_SPEED;
		if (right)
			FlxG.camera.scroll.x += SCROLL_SPEED;

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.scroll.x -= (FlxG.mouse.wheel * 100);
		}

		this.scrollX = FlxG.camera.scroll.x; // recrod the scrollX so when we switch back to the map state, we can return to the scroll we were at.
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMovement();
	}
}
