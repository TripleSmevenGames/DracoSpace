package models.events;

import models.events.GameEvent.GameEventType;

class Choice
{
	public var text:String;
	public var effect:Void->Void;
}

class ChoiceEvent implements GameEvent
{
	public var name:String;
	public var choices:Array<Choice>;
	public var desc:String;

	public var type:GameEventType = CHOICE;

	public static function sample()
	{
		var desc = 'Something happened. Choose what to do. Sample.';
		return new ChoiceEvent('Sample Choice', desc);
	}

	public function new(name:String, desc:String)
	{
		this.name = name;
		this.desc = desc;
	}
}
