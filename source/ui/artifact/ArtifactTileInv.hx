package ui.artifact;

import managers.GameController;
import models.artifacts.Artifact;
import ui.TooltipLayer.Tooltip;

using utils.ViewUtils;

/** Extends the base artifact tile to do stuff in the inventory substate. **/
class ArtifactTileInv extends ArtifactTile
{
	public var artifact:Artifact;

	public function setupHover()
	{
		this.addScaledToMouseManager();

		var tooltip = Tooltip.genericTooltip(artifact.name, artifact.desc, {});
		GameController.invTooltipLayer.registerTooltip(tooltip, this, true);
	}

	public function new(artifact:Artifact)
	{
		super(artifact);
		this.artifact = artifact;
		this.addScaledToMouseManager();
	}
}
