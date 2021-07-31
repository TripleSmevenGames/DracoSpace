package ui;

import flixel.group.FlxSpriteGroup;

/** This class acts as a render layer, much like DamageNumbersLayer, TooltipLayer, etc.
 * Except it has no specialty.
 * You can pull random objects from inside the Views into this layer, so they appear above everything else.
 * For example, the target arrow is attached to the character sprite its assigned to, but we want to render it above all other chars.
 *
 * You should probably put this at the "bottom" of all the other above-view layers.
**/
class MiscUILayer extends FlxSpriteGroup
{
	public function new()
	{
		super();
	}
}
