package ui.artifact;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.artifacts.Artifact;

using utils.ViewUtils;

/** Just a sprite showing the artifact art with a border bg behind it. Centered. 
 * Has NO base functionality.
**/
class ArtifactTile extends FlxSpriteGroup
{
	static final bgPath = AssetPaths.artifactBorderCommon__png;

	var art:FlxSprite;

	public function new(artifact:Artifact)
	{
		super();
		var bg = new FlxSprite(0, 0, bgPath);
		bg.scale3x();
		bg.centerSprite();
		add(bg);

		var art = new FlxSprite(0, 0, artifact.assetPath);
		art.scale3x();
		art.centerSprite();
		add(art);
	}
}
