package models.events;

import managers.GameController;
import models.artifacts.Artifact;
import models.artifacts.ArtifactFactory;
import models.events.GameEvent.GameEventType;
import models.player.Player;
import utils.GameUtils;

class TreasureEvent extends GameEvent
{
	var artifact:Artifact;

	public static function getNextTreasureEvent()
	{
		var artifact = ArtifactFactory.getNextArtifact();
		return new TreasureEvent(artifact);
	}

	// this code will be run when the event is shown
	override public function onEventShown()
	{
		Player.gainArtifact(this.artifact);
	}

	public function new(artifact:Artifact)
	{
		var choices = [Choice.getLeave()];
		this.artifact = artifact;

		var a_or_an = GameUtils.getAOrAn(artifact.name);
		var desc = 'You find an abandoned supply crate. Inside is ${a_or_an} ${artifact.name}!';
		super(artifact.name, desc, TREASURE, choices);
	}
}
