package ui.inventory.equipmentMenu;

import flixel.FlxBasic;
import flixel.FlxSprite;

/** Used by the DragLayer, so we can call isInZone for any type with a zone. **/
interface IDropZone
{
	/** Anwsers the question: Is the sprite I'm currently dragging in the 
	 * Drag Layer in this zone?
	**/
	public function isInZone(sprite:FlxSprite):Bool;
}

class DragLayer<T> extends FlxBasic
{
	/** List of all the sprites on the screen that can be dragged. **/
	var draggables:Array<T>;

	/** The sprite we are currently dragging, or null**/
	var currentlyDragging:Null<T>;

	/** Trigger areas where we can "drop" a draggable. **/
	var droppableZones:Array<IDropZone>;

	function onDraggableMouseDown(draggable:FlxSprite) {}

	function onDraggableMouseUp(draggable:FlxSprite) {}

	/** Make sure every item in draggables is already added to the mouse manager. **/
	public function new(draggables:Array<T>, droppableZones:Array<IDropZone>) {}
}
