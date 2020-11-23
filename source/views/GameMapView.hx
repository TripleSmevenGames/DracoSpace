package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
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

		makeGraphic(16, 16, color);
	}
}

class GameMapView extends FlxTypedGroup<FlxSprite>
{
	var gameMap:GameMap;

	static inline var COL_WIDTH = 200;
	static inline var NODE_GAP = 50;

	public function new(gameMap:GameMap)
	{
		super();
		this.gameMap = gameMap;

		for (i in 0...gameMap.columns.length)
		{
			for (j in 0...gameMap.columns[i].length)
			{
				var node:Node = gameMap.columns[i][j];
				var nodeView = new NodeSprite(node, i * COL_WIDTH + 50, j * NODE_GAP);
				add(nodeView);
			}
		}
	}
}
