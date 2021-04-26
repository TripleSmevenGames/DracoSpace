package ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import models.GameMap.Node;
import models.events.GameEvent.GameEventType;

using utils.ViewUtils;

class MapTile extends FlxSpriteGroup
{
	var body:FlxSprite;
	var hereMarker:FlxSprite;
	var highlight:FlxSprite;

	public var node:Node;
	public var id:Int;
	public var connectedNodesId:Array<Int>;

	public var here(default, set):Bool = false;
	public var highlighted(default, set):Bool = false;

	static var typeToSpriteMap = [
		CHOICE => AssetPaths.choiceMapTile__png,
		BATTLE => AssetPaths.enemyMapTile__png,
		ELITE => AssetPaths.eliteMapTile__png,
		BOSS => AssetPaths.bossMapTile__png,
		TREASURE => AssetPaths.treasureMapTile__png,
		CAMP => AssetPaths.restMapTile__png,
	];

	public function set_here(val:Bool)
	{
		hereMarker.visible = val;
		return here = val;
	}

	public function set_highlighted(val:Bool)
	{
		highlight.visible = val;
		return highlighted = val;
	}

	public function addClickListener(listener:FlxSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(body, listener);
	}

	public function addHoverListener(over:FlxSprite->Void, out:FlxSprite->Void)
	{
		FlxMouseEventManager.setMouseOverCallback(body, over);
		FlxMouseEventManager.setMouseOutCallback(body, out);
	}

	function getSpriteForType(type:GameEventType)
	{
		if (!typeToSpriteMap.exists(type))
			return AssetPaths.mapTile__png;
		else
			return typeToSpriteMap.get(type);
	}

	function setupParts()
	{
		highlight = new FlxSprite(0, 0, AssetPaths.tileHighlight1__png);
		highlight.scale.set(3, 3);
		highlight.updateHitbox();
		highlight.centerSprite();
		highlight.visible = false;

		hereMarker = new FlxSprite(0, 0, AssetPaths.BlueArrow1D__png);
		hereMarker.scale.set(3, 3);
		hereMarker.updateHitbox();
		hereMarker.centerSprite(0, -48);
		hereMarker.visible = false;

		body = new FlxSprite(0, 0);
		var type = this.node.eventType;
		var spritePath = getSpriteForType(type);

		body.loadGraphic(spritePath);
		body.scale.set(3, 3);
		body.updateHitbox();
		body.centerSprite();

		add(body);
		add(highlight);
		add(hereMarker);
		hereMarker.hoverTween(1);
	}

	public function new(node:Node, x:Int = 0, y:Int = 0)
	{
		super(x, y);
		this.node = node;
		this.connectedNodesId = node.connectedNodesId;
		this.id = node.id;

		setupParts();
		FlxMouseEventManager.add(body, null, null, null, null, false, true, false);
	}
}
