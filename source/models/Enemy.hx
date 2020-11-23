package models;

interface Enemy
{
	var name:String;
	var lvl:Int;
	var hp:Int;
}

class SlimeEnemy implements Enemy
{
	public var name:String = 'Slime';
	public var lvl:Int;
	public var hp:Int;

	public function new(lvl:Int)
	{
		this.lvl = lvl;
		hp = lvl * 5;
	}
}
