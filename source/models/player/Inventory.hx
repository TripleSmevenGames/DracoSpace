package models.player;

import models.skills.Skill;

class Inventory
{
	public var unequippedSkills:Array<Skill>;

	public function new()
	{
		unequippedSkills = [];
	}
}
