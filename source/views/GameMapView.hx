package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.GameMap;
import utils.ViewUtils;

using flixel.util.FlxSpriteUtil;

typedef ColumnSprite = Array<NodeSprite>;

// represents on node on the map view
class NodeSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	public var node:Node;
	public var id:Int;
	public var connectedNodesId:Array<Int>;
	// relative to parent
	public var xCoord:Float;
	public var yCoord:Float;

	var gameMapView:GameMapView;

	public var nodeBody:FlxSprite;
	public var tooltip:FlxSprite;
	public var here(default, set):Bool;
	public var hereMarker:FlxSprite;
	public var highlighted(default, set):Bool;
	public var highlightBorder:FlxSprite;
	public var visited:Bool;

	public function set_here(val:Bool)
	{
		if (val)
			hereMarker.visible = true;
		else
			hereMarker.visible = false;

		return here = val;
	}

	public function set_highlighted(val:Bool)
	{
		if (val)
		{
			tooltip.visible = true;
			highlightBorder.visible = true;
		}
		else
		{
			tooltip.visible = false;
			highlightBorder.visible = false;
		}
		return highlighted = val;
	}

	public function addClickListener(listener:FlxSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(nodeBody, listener);
	}

	public function addHoverListener(over:FlxSprite->Void, out:FlxSprite->Void)
	{
		FlxMouseEventManager.setMouseOverCallback(nodeBody, over);
		FlxMouseEventManager.setMouseOutCallback(nodeBody, out);
	}

	public function new(node:Node, x:Float = 0, y:Float = 0, mapView:GameMapView)
	{
		super(x, y);
		this.xCoord = x;
		this.yCoord = y;
		this.node = node;
		this.id = node.id;
		this.connectedNodesId = node.connectedNodesId;
		this.gameMapView = mapView;
		this.visited = false;
		active = false;

		var color:FlxColor;
		var nodeType = node.event.type;

		switch (nodeType)
		{
			case BATTLE:
				color = FlxColor.RED;
			case ELITE:
				color = FlxColor.fromRGB(255, 16, 16);
			case BOSS:
				color = FlxColor.PURPLE;
			case TREASURE:
				color = FlxColor.YELLOW;
			case HOME:
				color = FlxColor.LIME;
			case REST:
				color = FlxColor.LIME;
			case CHOICE:
				color = FlxColor.GRAY;
			default:
				color = FlxColor.GRAY;
		}

		var lineStyle:LineStyle = {color: FlxColor.BLACK, thickness: 2};
		var drawStyle:DrawStyle = {smoothing: false};

		nodeBody = new FlxSprite(0, 0);
		nodeBody.makeGraphic(64, 64, color);
		if (nodeType == ELITE)
		{
			nodeBody.drawRect(0, 0, 64, 64, FlxColor.TRANSPARENT, {color: FlxColor.GRAY, thickness: 10}, drawStyle);
		}
		ViewUtils.centerSprite(nodeBody);
		add(nodeBody);

		hereMarker = new FlxSprite(0, 0).makeGraphic(64, 64, FlxColor.TRANSPARENT);
		hereMarker.drawCircle(-1, -1, 14, FlxColor.WHITE, lineStyle, drawStyle);
		ViewUtils.centerSprite(hereMarker);
		add(hereMarker);
		hereMarker.visible = false;

		highlightBorder = new FlxSprite(0, 0);
		highlightBorder.makeGraphic(74, 74, FlxColor.fromRGB(0, 0, 0, 10));
		highlightBorder.drawRect(0, 0, 74, 74, FlxColor.TRANSPARENT, {color: FlxColor.GREEN, thickness: 10}, drawStyle);
		ViewUtils.centerSprite(highlightBorder);
		add(highlightBorder);
		highlightBorder.visible = false;

		tooltip = new FlxText(0, 0, 0, nodeType.getName(), 16);
		ViewUtils.centerSprite(tooltip, 0, 50);
		add(tooltip);
		tooltip.visible = false;

		FlxMouseEventManager.add(nodeBody, null, null, null, null, true);
		here = false;
	}
}

// the actual sprite representation of the map and its nodes.
class GameMapView extends FlxSpriteGroup
{
	var gameMap:GameMap;
	var columnSprites = new Array<ColumnSprite>();
	// flattened column sprites
	var nodeSprites = new Array<NodeSprite>();

	public var eventView:EventView;

	var connectingLinesScreen:FlxSprite;

	static inline final COL_WIDTH = 200;
	static inline final COL_HEIGHT = 600;
	static inline var SCROLL_SPEED = 25;

	private function updateMovement()
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

	public function markHere(nodeSprite:NodeSprite)
	{
		for (columnSprite in columnSprites)
		{
			for (nodeSprite in columnSprite)
			{
				nodeSprite.here = false;
			}
		}
		nodeSprite.here = true;
	}

	public function visit(nodeSprite:NodeSprite)
	{
		markHere(nodeSprite);
		eventView.showEvent(nodeSprite.node.event);
		this.active = false;
	}

	// draw lines between every node and its connected nodes in the next column
	function drawConnectingLines()
	{
		var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 10};
		var drawStyle:DrawStyle = {smoothing: false};
		connectingLinesScreen.makeGraphic(Math.round(this.width), Math.round(this.height), FlxColor.TRANSPARENT);
		for (nodeSprite in nodeSprites)
		{
			for (id in nodeSprite.node.connectedNodesId)
			{
				var otherNodeSprite = nodeSprites[id];
				connectingLinesScreen.drawLine(nodeSprite.xCoord, nodeSprite.yCoord, otherNodeSprite.xCoord, otherNodeSprite.yCoord, lineStyle, drawStyle);
			}
		}
	}

	public function new(x:Float = 0, y:Float = 0, eventView:EventView)
	{
		super(x, y);

		this.gameMap = new GameMap();
		this.eventView = eventView;
		this.eventView.exitCallback = function()
		{
			this.active = true;
		}

		// add this screen first, so the connecting lines will be under the nodes
		this.connectingLinesScreen = new FlxSprite(0, 0);
		add(connectingLinesScreen);

		for (i in 0...gameMap.columns.length)
		{
			var column = gameMap.columns[i];
			var columnSprite = new ColumnSprite();
			for (j in 0...column.length)
			{
				// set the nodeSprite's node and position on the map
				var node:Node = column[j];
				var xCoord = i * COL_WIDTH + 50;
				var yCoord = (COL_HEIGHT / (column.length + 1) * (j + 1));
				var nodeSprite = new NodeSprite(node, xCoord, yCoord, this);

				nodeSprite.addClickListener(function(_)
				{
					visit(nodeSprite);
				});
				nodeSprite.addHoverListener(function(_)
				{
					#if debug
					trace('mouse over node');
					#end
					nodeSprite.highlighted = true;
				}, function(_)
				{
					nodeSprite.highlighted = false;
				});
				columnSprite.push(nodeSprite);
				nodeSprites.push(nodeSprite);

				add(nodeSprite);
				var line = new FlxSprite(0, 0).makeGraphic(8, 8, FlxColor.WHITE);
				line.setPosition(xCoord, yCoord);
			}
			columnSprites.push(columnSprite);
		}

		add(new FlxSprite(0, 0).makeGraphic(100, 10, FlxColor.GREEN));
		add(new FlxSprite(0, this.height).makeGraphic(100, 10, FlxColor.GREEN));
		drawConnectingLines();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMovement();
	}
}
