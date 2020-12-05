package models.events;

import models.events.GameEvent.GameEventType;

class HomeEvent implements GameEvent
{
	public var name:String;
	public var desc:String;

	public var type:GameEventType = HOME;

	public function new(name:String)
	{
		this.name = name;
		this.desc = "Home event";
	}
}
