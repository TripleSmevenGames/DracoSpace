package models.player;

import models.artifacts.Artifact;
import models.skills.Skill;

class Inventory
{
	public var unequippedSkills:Array<Skill>;
	public var unequippedArtifacts:Array<Artifact>;

	public function new()
	{
		unequippedSkills = [];
		unequippedArtifacts = [];
	}
}
