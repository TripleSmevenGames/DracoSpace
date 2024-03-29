package models;

import constants.MapGeneration as MapGenConsts;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import haxe.Exception;
import managers.GameController;
import models.events.*;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.*;
import utils.GameUtils;

typedef Column = Array<Node>;

// a node in the map
class Node
{
	public var id:Int;
	public var connectedNodesId:Array<Int> = new Array<Int>();
	public var eventType:GameEventType;
	public var column:Int;

	public function new(id:Int, column:Int, ?eventType:GameEventType)
	{
		this.id = id;
		this.column = column;
		this.eventType = eventType;
	}
}

// the game map. The GameMapView will then take the nodes and
// render it on the screen.
class GameMap
{
	public var columns:Array<Column>;

	// reference to the global RNG
	var random:FlxRandom;

	function numNodesWeightedPick()
	{
		var items = MapGenConsts.NUM_NODE_CHANCE_ITEMS;
		var weights = MapGenConsts.NUM_NODE_CHANCE_WEIGHTS;
		return GameUtils.weightedPick(items, weights);
	}

	function nodeTypeWeightedPick()
	{
		var items = MapGenConsts.NODE_TYPE_CHANCE_ITEMS;
		var weights = MapGenConsts.NODE_TYPE_CHANCE_WEIGHTS;
		return GameUtils.weightedPick(items, weights);
	}

	/** Create a pool of GameEvents to fill in the map with. **/
	function createEventTypePool(length:Int)
	{
		var eventTypePool = new Array<GameEventType>();
		// add the guaranteed events in first, the battles and the encounter events.
		for (i in 0...MapGenConsts.MIN_BATTLES)
		{
			if (eventTypePool.length < length)
				eventTypePool.push(BATTLE);
		}
		for (i in 0...MapGenConsts.MIN_ENCOUNTERS)
		{
			if (eventTypePool.length < length)
				eventTypePool.push(ENCOUNTER);
		}

		// now add the variable events to the pool, based on their weight;
		while (eventTypePool.length < length)
		{
			var type = nodeTypeWeightedPick();
			eventTypePool.push(type);
		}
		if (eventTypePool.length != length)
		{
			throw new Exception('bad eventTypePool length. eventTypePool:${eventTypePool.length}, input length: ${length}');
		}
		return eventTypePool;
	}

	/** Fill the map with some pre determined events like treasures and Elites.
	 * Then, fill the rest of the nodes with variable events. 
	**/
	function fillVariableNodes(variableNodes:Array<Node>)
	{
		var nodeInd:Int = 0;
		// add treasures in a random node in the first half of the map.
		// Then remove the node from the list (so we won't override it)
		for (i in 0...MapGenConsts.TREASURES_IN_FIRST_HALF)
		{
			var nodeInd = random.int(0, Math.round(variableNodes.length / 2) - 1);
			variableNodes[nodeInd].eventType = TREASURE;
			variableNodes.splice(nodeInd, 1);
		}
		// add a treasure random node in the second half of the map.
		// Then again, remove those nodes from the list.
		for (i in 0...MapGenConsts.TREASURES_IN_SECOND_HALF)
		{
			nodeInd = random.int(Math.round(variableNodes.length / 2), variableNodes.length - 1);
			variableNodes[nodeInd].eventType = TREASURE;
			variableNodes.splice(nodeInd, 1);
		}

		// add 2 elites to the second half. Remove them from the list as always.
		for (i in 0...MapGenConsts.ELITES_IN_SECOND_HALF)
		{
			nodeInd = random.int(Math.round(variableNodes.length / 2), variableNodes.length - 1);
			variableNodes[nodeInd].eventType = ELITE;
			variableNodes.splice(nodeInd, 1);
		}

		// now, create a pool of events to be assigned to the rest nodes
		var eventTypePool = createEventTypePool(variableNodes.length);

		// for each of the remaining nodes, assign a random event from the pool to it and remove the event from the pool
		for (i in 0...variableNodes.length)
		{
			var eventInd = random.int(0, eventTypePool.length - 1);
			variableNodes[i].eventType = eventTypePool[eventInd];
			eventTypePool.splice(eventInd, 1);
		}
		if (eventTypePool.length != 0)
		{
			throw new Exception('event pool not empty after assignment:${eventTypePool.length}');
		}
	}

	/** Create connections for each node to some nodes in the next column. Make sure every node is accessible somehow. **/
	function connectNodes()
	{
		for (i in 0...columns.length - 1)
		{
			var column = columns[i];
			var nextColumn = columns[i + 1];

			// index of the node with the highest index number in the next column, that a node in this column is connected to
			// e.g. the next column has nodes 0, 1, 2. 0 and 1 have connections to nodes in this column, but 2 doesn' t have any. // So 1 is the highestConnectedNode.
			var highestConnectedNode = 0;

			for (j in 0...column.length)
			{
				var node = column[j];
				var connectToHighestConnected:Bool;

				// you must connect to the previously highest connected node if you are the first node in your column,
				// or if the highest connected node is the last node in the next column.
				// the highest connected node is always 0 if you are the first node in your column.
				if (j == 0 || highestConnectedNode == nextColumn.length - 1)
					connectToHighestConnected = true;
				else
					connectToHighestConnected = random.bool();

				// the first connected node for this node is either the highest connected node from the previous node in this column
				// or the next one after the highest connected node.
				var connectedStart:Int;
				if (connectToHighestConnected)
					connectedStart = highestConnectedNode;
				else
					connectedStart = highestConnectedNode + 1;

				// if you are the last node, the last node you connect to must be the end of the next column.
				// else, the last node you connect to can be anywhere from your connectedStart to the end of the next column.
				// finally if you are the first node in your column, you have slightly different rules to make the pathing more even.
				var connectedEnd:Int;
				if (j == column.length - 1)
					connectedEnd = nextColumn.length - 1;
				else if (j == 0)
				{
					// without this exception for the first node, the map slightly favors the first node connecting to all the other nodes in the next column.
					// So make the first node connecting to all nodes in the next column half as likely as any other choice.
					var weights = new Array<Float>();
					for (k in 0...nextColumn.length)
					{
						var weight = k == nextColumn.length - 1 ? 1 : 2;
						weights.push(weight);
					}
					connectedEnd = random.weightedPick(weights);
				}
				else
					connectedEnd = random.int(connectedStart, nextColumn.length - 1);

				if (connectedEnd > nextColumn.length - 1)
					throw new Exception('connected end past end of next column');

				for (idx in connectedStart...connectedEnd + 1)
				{
					node.connectedNodesId.push(nextColumn[idx].id);
				}
				highestConnectedNode = connectedEnd;
			}
		}
	}

	public function new(numColumns:Int = 16)
	{
		this.random = GameController.rng;

		trace('generated map with seed ${random.currentSeed}');
		GameController.save.data.seed = random.currentSeed;
		GameController.save.flush();

		// nodes that are empty until the end. We will fill them with an event after we
		// fill in the pre determined nodes (e.g. the starting home node, boss at the end)
		var variableNodes = new Array<Node>();
		var idCounter = 0;

		this.columns = new Array<Column>();
		for (i in 0...numColumns)
		{
			var column = new Column();

			// if we're making the first column, just make it 1 HOME node.
			if (i == 0)
			{
				var node = new Node(0, i, HOME);
				column.push(node);
			}
			// If we're making the last column, just make it 1 BOSS node.
			else if (i == numColumns - 1)
			{
				var node = new Node(++idCounter, i, BOSS);
				column.push(node);
			}
			// If we're making the middle column, just make it 1 CAMP node.
			else if (i == Math.round(numColumns / 2))
			{
				var node = new Node(++idCounter, i, CAMP);
				column.push(node);
			}
			else
			{
				// for all other columns, create empty ones to be filled in later.
				// columns can have 2-4 nodes.
				var nodesInColumn = numNodesWeightedPick();

				for (j in 0...nodesInColumn)
				{
					var node = new Node(++idCounter, i);
					column.push(node);
					variableNodes.push(node);
				}
			}

			// finally, add this column to the map
			this.columns.push(column);
		}
		// remember those empty nodes we made? Now we have to assign them an event.
		fillVariableNodes(variableNodes);

		// finally, we have to calculate how the nodes are connected.
		connectNodes();
	}
}
