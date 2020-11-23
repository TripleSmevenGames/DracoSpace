package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import models.GameMap.Node;
import models.GameMap;

class NodeSprite extends FlxSprite
{
	var node:Node;

	public function new(node:Node, x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.node = node;
		var color:FlxColor;
		var nodeType = node.event.type;

		#if debug
		trace('Made node of type $nodeType');
		#end

		switch (nodeType)
		{
			case BATTLE:
				color = FlxColor.RED;
			case TREASURE:
				color = FlxColor.YELLOW;
			case HOME:
				color = FlxColor.GREEN;
			default:
				color = FlxColor.GRAY;
		}

		// add mouse listeners to the node sprite
		function onMouseOver(sprite:FlxSprite)
		{
			trace('Moused over node');
		}
		FlxMouseEventManager.add(this, null, null, onMouseOver);

		makeGraphic(64, 64, color);
	}
}

class GameMapView extends FlxTypedSpriteGroup<FlxSprite>
{
	var gameMap:GameMap;

	static inline var COL_WIDTH = 200;
	static inline var COL_HEIGHT = 500;

	public function new(gameMap:GameMap, x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.gameMap = gameMap;

		for (i in 0...gameMap.columns.length)
		{
			var column = gameMap.columns[i];
			for (j in 0...column.length)
			{
				var node:Node = column[j];
				var xCoord = i * COL_WIDTH + 50;
				var yCoord = (COL_HEIGHT / (column.length + 1) * (j + 1));
				var nodeView = new NodeSprite(node, xCoord, yCoord);
				add(nodeView);
			}
		}
	}
}
