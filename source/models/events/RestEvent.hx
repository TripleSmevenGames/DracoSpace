package models.events;

import models.events.GameEvent.GameEventType;

class RestEvent implements GameEvent
{
	public var name:String;
	public var desc:String;

	public var type:GameEventType = REST;

	public static function sample()
	{
		return new RestEvent('Sample rest', 'Rest by this campfire, weary stranger. Sample.');
	}

	public function new(name:String, desc:String)
	{
		this.name = name;
		this.desc = desc;
	}
}
