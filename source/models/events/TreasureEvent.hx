package models.events;

import models.events.GameEvent.GameEventType;
import models.items.Item;

class TreasureEvent implements GameEvent
{
	public var name:String;
	public var desc:String;
	public var item:Item;

	public var type:GameEventType = TREASURE;

	public static function sample()
	{
		var desc = "You found a treasure! Not really. Sample.";
		return new TreasureEvent('Sample Treasure', desc, EquipmentItem.sample());
	}

	public function new(name:String, desc:String, item:Item)
	{
		this.name = name;
		this.desc = desc;
		this.item = item;
	}
}
