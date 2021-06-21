package ui.artifact;

import managers.GameController;
import models.artifacts.Artifact;
import ui.TooltipLayer.Tooltip;

using utils.ViewUtils;

/** Extends the base artifact tile to do stuff in the battle substate. **/
class ArtifactTileBattle extends ArtifactTile
{
	public var artifact:Artifact;

	public function setupHover()
	{
		var tooltip = Tooltip.genericTooltip(artifact.name, artifact.desc, {pos: BOTTOM});
		GameController.battleTooltipLayer.registerTooltip(tooltip, this, true);
	}

	public function new(artifact:Artifact)
	{
		super(artifact);
		this.artifact = artifact;
		this.addScaledToMouseManager();
	}
}
