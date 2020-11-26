package models.events;

import models.events.GameEvent.GameEventType;

class NoneEvent implements GameEvent
{
	public var name:String;
	public var desc:String;

	public var type:GameEventType = NONE;

	public function new()
	{
		this.name = 'none event';
		this.desc = 'Nothing here, folks';
	}
}
