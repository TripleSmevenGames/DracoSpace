package models;

import flixel.math.FlxRandom;
import haxe.ds.Vector;
import models.GameEvent;

class Node
{
	public var id(default, null):Int;

	public var event(default, null):GameEvent;

	public function new(id:Int, event:GameEvent)
	{
		this.id = id;
		this.event = event;
	}
}

class GameMap
{
	public var columns:Array<Array<Node>>;
	public var currentNode:Vector<Int> = new Vector(2);
	public var size:Int;

	public function print()
	{
		for (i in 0...size)
		{
			var traceVal:String = '';
			var column = columns[i];
			for (i in 0...column.length)
			{
				traceVal += 'id:${column[i].id} name:${column[i].event.name}, ';
			}
			trace(traceVal);
		}
	}

	public function new(size:Int = 10)
	{
		this.size = size;
		var idCounter = 0;
		var random = new FlxRandom();

		this.columns = new Array<Array<Node>>();
		for (i in 0...size)
		{
			var column = new Array<Node>();

			// create the initial "home" node in first column
			if (i == 0)
			{
				var node = new Node(0, new HomeEvent('Home'));
				column.push(node);
			}
			// create the boss node in the last column
			else if (i == size - 1)
			{
				var node = new Node(0, BossEvent.sample());
				column.push(node);
			}
			// for every other column after...
			else
			{
				// create this column's 2-4 nodes
				for (i in 0...random.int(2, 4))
				{
					// get a random event for this node
					var event:GameEvent;
					var randInt = random.int(0, 2);
					switch (randInt)
					{
						case 0:
							event = BattleEvent.sample();
						case 1:
							event = TreasureEvent.sample();
						default:
							event = new NoneEvent();
					}
					var node = new Node(++idCounter, event);
					column.push(node);
				}
			}

			// finally, add this column to the map
			columns.push(column);
		}
	}
}
