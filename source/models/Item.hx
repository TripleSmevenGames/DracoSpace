package models;

interface Item
{
	var name:String;
}

class EquipmentItem implements Item
{
	public var name:String;

	public static function sample()
	{
		return new EquipmentItem('Sample Equipment');
	}

	public function new(name:String)
	{
		this.name = name;
	}
}
