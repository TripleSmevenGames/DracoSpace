package ui.inventory.equipmentMenu;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import ui.artifact.ArtifactTile;

/** A trigger zone which is used by the DragLayer. Pass in a callback which DragLayer will call when a draggable is dropped into it.
 * Not centered.
**/
class DropZone extends FlxSpriteGroup
{
	public var onDrop:FlxSprite->Void;

	// The actualy "trigger zone"
	var body:FlxSprite;

	// some sprites/text to render, telling the player what will happen if a draggable is dropped here
	// e.g. "Equip Artifact"
	var messageSprite:FlxSpriteGroup;

	public function isInZone(sprite:FlxSprite):Bool
	{
		return sprite.overlaps(body);
	}

	public function showMessage() {}

	public function hideMessage() {}

	/** Make a drop zone with w width and h height. **/
	public function new(onDrop:FlxSprite->Void, w:Float, h:Float)
	{
		super();
		this.onDrop = onDrop;

		this.body = new FlxSprite();
		body.makeGraphic(Std.int(w), Std.int(h), FlxColor.fromRGB(0, 0, 0, 100));
		add(body);
	}
}

class DragLayer extends FlxSpriteGroup
{
	/** List of all the sprites on the screen that can be dragged. **/
	var draggables:Array<FlxSprite>;

	/** The sprite we are currently dragging, or null**/
	var currentlyDragging:Null<FlxSprite>;

	var currentlyDraggingOriginalPosX:Float;
	var currentlyDraggingOriginalPosY:Float;

	/** Trigger areas where we can "drop" a draggable. **/
	var dropZones:Array<DropZone>;

	function onDraggableMouseDown(draggable:FlxSprite)
	{
		currentlyDraggingOriginalPosX = draggable.x;
		currentlyDraggingOriginalPosY = draggable.y;
		currentlyDragging = draggable;

		// add the draggable to the DragLayer, which will make it appear above
		// other flx sprite groups.
		add(currentlyDragging);
	}

	function onDraggableMouseUp(draggable:FlxSprite)
	{
		if (currentlyDragging == null)
			return;

		// remove it from the group.
		remove(currentlyDragging);

		var droppedInZone = false;
		for (dropZone in dropZones)
		{
			if (dropZone.isInZone(draggable))
			{
				dropZone.onDrop(draggable);
				droppedInZone = true;
				break;
			}
		}

		// return the draggable back to its original position if we didnt drop it in a zone.
		if (!droppedInZone)
			draggable.setPosition(currentlyDraggingOriginalPosX, currentlyDraggingOriginalPosY);

		currentlyDragging = null;
	}

	/** Make sure every item in draggables is already added to the mouse manager. **/
	public function new(draggables:Array<FlxSprite>, dropZones:Array<DropZone>)
	{
		super();
		this.draggables = draggables;
		this.dropZones = dropZones;

		// add the click handlers to the draggables. Remember that they should be added to the manager prior to this.
		for (draggable in draggables)
		{
			FlxMouseEventManager.setMouseDownCallback(draggable, onDraggableMouseDown);
		}
	}

	override public function update(elapsed:Float)
	{
		// if we just released the mouse, and if we are dragging a draggable, check each dropZone to see if we just dropped the draggable there.
		// If so, fire off the onDrop. Else, do something else
		if (FlxG.mouse.justReleased)
		{
			if (currentlyDragging != null)
				onDraggableMouseUp(currentlyDragging);

			currentlyDragging = null;
		}
		else
		{
			if (FlxG.mouse.pressed && currentlyDragging != null)
			{
				currentlyDragging.setPosition(FlxG.mouse.x, FlxG.mouse.y);
			}
		}
	}
}
