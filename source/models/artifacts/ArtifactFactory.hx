package models.artifacts;

import flixel.math.FlxRandom;
import models.artifacts.listOfArtifacts.*;

class ArtifactFactory
{
	/** constant list of artifacts. **/
	static final listOfArtifacts:Array<Class<Artifact>> = [
		BatteryArtifact,
		BootsArtifact,
		EmergencyShieldsArtifact,
		EnergyBarArtifact,
		RedBannerArtifact
	];

	/** The actual list of artifacts to use for a run. As artifacts are obtained by the player, 
	 * the artifact will be pop'ed off so they can't be obtained again.
	**/
	static var workingList:Array<Class<Artifact>>;

	static public function init()
	{
		var random = new FlxRandom();
		workingList = listOfArtifacts.copy();
		random.shuffle(workingList);
	}

	/** Create the next artifact in the list. Call this everytime you need an artifact to be given to the player. **/
	static public function getNextArtifact():Artifact
	{
		if (workingList.length == 0)
			init();

		var artifactClass = workingList.pop();
		return Type.createInstance(artifactClass, []);
	}
}
