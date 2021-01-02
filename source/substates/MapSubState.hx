package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.GameMap;
import ui.MapTile;
import ui.header.Header;
import utils.GameController;
import utils.SubStateManager;
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

	var currentTile:MapTile;

	// large sprite that draws the lines connecting the nodes
	var connectingLinesScreen:FlxSprite;

	var header:Header;

	// reference to global sub state manager
	var ssm:SubStateManager;

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

	public function visit(mapTile:MapTile)
	{
		if (currentTile.connectedNodesId.contains(mapTile.id))
		{
			currentTile = mapTile;
			markHere(mapTile);
			ssm.initEvent(mapTile.node.event);
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

	public function refresh()
	{
		header.refresh();
	}

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		this.gameMap = new GameMap(18);
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

				mapTile.addClickListener(function(_)
				{
					visit(mapTile);
				});
				mapTile.addHoverListener(function(_)
				{
					#if debug
					trace('mouse over node');
					#end
					mapTile.highlighted = true;
				}, function(_)
				{
					mapTile.highlighted = false;
				});
				columnSprite.push(mapTile);
				mapTiles.push(mapTile);

				add(mapTile);
				var line = new FlxSprite(0, 0).makeGraphic(8, 8, FlxColor.WHITE);
				line.setPosition(xCoord, yCoord);
			}
			columnSprites.push(columnSprite);
		}

		drawConnectingLines();
		this.header = new Header();
		header.scrollFactor.set(0, 0);
		add(header);

		currentTile = mapTiles[0];
		markHere(currentTile);
	}
}

// a substate containing the map view
class MapSubState extends FlxSubState
{
	var view:GameMapView;

	static inline final SCROLL_SPEED = 25;

	/** Call this when we switch back to this state from the ssm. **/
	public function onSwitch()
	{
		view.refresh();
	}

	override public function create()
	{
		super.create();
		view = new GameMapView(0, 0);
		add(view);
	}

	function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up)
			FlxG.camera.scroll.y -= SCROLL_SPEED;
		if (down)
			FlxG.camera.scroll.y += SCROLL_SPEED;
		if (left)
			FlxG.camera.scroll.x -= SCROLL_SPEED;
		if (right)
			FlxG.camera.scroll.x += SCROLL_SPEED;

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.scroll.x -= (FlxG.mouse.wheel * 100);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMovement();
	}

	override public function destroy()
	{
		super.destroy();
		if (view != null)
			this.view.destroy();
	}
}
