package views;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import models.GameMap;
import utils.ViewUtils;

class NodeSprite extends FlxTypedSpriteGroup<FlxSprite>
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
			case BOSS:
				color = FlxColor.PURPLE;
			case TREASURE:
				color = FlxColor.YELLOW;
			case HOME:
				color = FlxColor.GREEN;
			default:
				color = FlxColor.GRAY;
		}

		var nodeBody = new FlxSprite(0, 0);
		nodeBody.makeGraphic(64, 64, color);
		ViewUtils.centerSprite(nodeBody);
		add(nodeBody);

		var tooltip = new FlxText(0, 0, 0, nodeType.getName(), 16);
		ViewUtils.centerSprite(tooltip, 0, 50);
		add(tooltip);
		tooltip.kill();

		function onMouseOver(sprite:FlxSprite)
		{
			tooltip.revive();
		}
		function onMouseOut(sprite:FlxSprite)
		{
			tooltip.kill();
		}
		FlxMouseEventManager.add(nodeBody, null, null, onMouseOver, onMouseOut);
	}
}

class GameMapView extends FlxSpriteGroup
{
	var gameMap:GameMap;

	static inline var COL_WIDTH = 200;
	static inline var COL_HEIGHT = 600;

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
				var nodeSprite = new NodeSprite(node, xCoord, yCoord);
				add(nodeSprite);
			}
		}

		add(new FlxSprite(0, 0).makeGraphic(100, 10, FlxColor.GREEN));
		add(new FlxSprite(0, this.height).makeGraphic(100, 10, FlxColor.GREEN));
	}
}
