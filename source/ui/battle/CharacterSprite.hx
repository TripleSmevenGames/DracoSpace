package ui.battle;

import models.player.CharacterInfo;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import models.skills.Skill;
import ui.battle.ITurnable;
import utils.BattleAnimationManager;
import utils.BattleManager.BattleManagerStateNames;
import utils.BattleManager;
import utils.DamageNumbers;
import utils.GameController;
import utils.ViewUtils;

/** Represents a character's sprite during battle. */
class CharacterSprite extends FlxSpriteGroup implements ITurnable
{
	public var info:CharacterInfo;
	public var maxHp:Int;
	public var currHp(default, set):Int;
	public var currBlock(default, set):Int;
	public var skillSprites:Array<SkillSprite> = new Array<SkillSprite>();

	public var dead(default, null):Bool = false;

	// the "body" of the character.
	public var sprite:FlxSprite;

	// an arrow pointing to the body, which will appear when you are targeting a skill.
	public var targetArrow:FlxSprite;

	// the character's hp and block displays.
	var hpBarSprite:CharacterHpBar;

	// reference to the global managers.
	var bm:BattleManager;
	var bam:BattleAnimationManager;

	// internal timer used for some animations.
	var timer:FlxTimer;

	var hurtSound:FlxSound;
	var blockedSound:FlxSound;
	var gainBlockSound:FlxSound;

	// target arrow X distance from char sprite.
	public static inline final TARGET_ARROW_DISTANCE = 50;

	// since we are using an FlxBar for the hp bar, the bar should automatically update
	// we don' t need to explicitly call update on it
	public function set_currHp(val:Int)
	{
		if (val > maxHp)
		{
			val = maxHp;
		}
		else if (val <= 0)
		{
			val = 0;
			if (!dead)
			{
				dead = true;
				playDeadAnimation();
			}
		}
		this.info.currHp = val; // set the hp on the char info first.
		return currHp = val;
	}

	// we'll have to explicitly update the block indicator.
	public function set_currBlock(val:Int)
	{
		if (val < 0)
			val = 0;

		if (val > currBlock)
			gainBlockSound.play();

		if (hpBarSprite != null)
			hpBarSprite.updateBlockIndicator(val);

		return currBlock = val;
	}

	function set_dead(val:Bool)
	{
		if (val)
			disableAllSkills();

		return dead = val;
	}

	/** Call this function for the character to take damage blocked by block. **/
	public function takeDamage(val:Int)
	{
		if (val > currBlock)
		{
			playHurtAnimation();
			hurtSound.play(true);
			currHp -= (val - currBlock);
		}
		else
		{
			blockedSound.play(true);
		}
		spawnDamageNumber(Std.string(val));
		currBlock -= val;
	}

	function singleFlash()
	{
		sprite.alpha = sprite.alpha == 1 ? .5 : 1;
	}

	function playHurtAnimation()
	{
		if (!timer.finished)
			return;

		var time = .1;
		var loops = 6;
		var onComplete = (_) -> singleFlash();

		timer.start(time, onComplete, loops);
	}

	function playDeadAnimation()
	{
		var tween = FlxTween.tween(sprite, {alpha: 0}, 1);
		bam.addAnim(tween, () -> this.kill());
	}

	function spawnDamageNumber(val:String)
	{
		if (sprite == null)
			return;

		var spawnX = sprite.x + sprite.width / 2;
		var spawnY = sprite.y;

		DamageNumbers.spawnDamageNumber(spawnX, spawnY, val);
	}

	function disableAllSkills()
	{
		for (skillSprite in skillSprites)
		{
			skillSprite.disabled = true;
		}
	}

	function refreshAllSkills()
	{
		for (skillSprite in skillSprites)
		{
			skillSprite.onNewRound();
		}
	}

	public function onPlayerStartTurn()
	{
		if (this.info.type == PLAYER) // reset the players' block
			currBlock = 0;

		refreshAllSkills(); // refresh both the players' and the enemies' skills.
	}

	public function onPlayerEndTurn() {}

	public function onEnemyStartTurn()
	{
		if (this.info.type == ENEMY) // reset the enemy's block
			currBlock = 0;
	}

	public function onEnemyEndTurn() {}

	public function setOnClick(onClick:CharacterSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(sprite, (_) -> onClick(this));
	}

	public function setOnHover(onOver:CharacterSprite->Void, onOut:CharacterSprite->Void)
	{
		FlxMouseEventManager.setMouseOverCallback(sprite, (_) -> onOver(this));
		FlxMouseEventManager.setMouseOutCallback(sprite, (_) -> onOut(this));
	}

	public static function sampleSlime(lvl:Int = 1)
	{
		return new CharacterSprite(CharacterInfo.sampleSlime());
	}

	public static function sampleRyder()
	{
		return new CharacterSprite(CharacterInfo.sampleRyder());
	}

	/** Setup this character's HPbar and block indicator. Call this after setupSprite. **/
	function setupHpBar()
	{
		hpBarSprite = new CharacterHpBar(this);
		add(hpBarSprite);
	}

	/** Setup this character's sprite **/
	function setupSprite(assetPath:FlxGraphicAsset)
	{
		// the sprite is not centered on the group. The sprite's 0, 0 is on the group's 0, 0.
		// We might want to change this later.
		this.sprite = new FlxSprite(0, 0, assetPath);
		sprite.setGraphicSize(0, Std.int(sprite.height * 8));
		sprite.updateHitbox();
		this.add(sprite);
		FlxMouseEventManager.add(sprite, null, null, null, null, null, null, false);

		// add the targeting arrow. Render right side for players, left side for enemies,
		// assumes sprite is at 0, 0.
		if (this.info.type == PLAYER)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.GreenArrow1L__png);
			ViewUtils.centerSprite(targetArrow, TARGET_ARROW_DISTANCE + sprite.width, sprite.height / 2);
		}
		else if (this.info.type == ENEMY)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.GreenArrow1R__png);
			ViewUtils.centerSprite(targetArrow, -TARGET_ARROW_DISTANCE, sprite.height / 2);
		}
		targetArrow.scale.set(2, 2);
		this.add(targetArrow);
		targetArrow.visible = false;
	}

	/** Add skills to this character, and setup the skill tiles for battle */
	function setupSkills(skills:Array<Skill>)
	{
		var skills = this.info.skills;
		for (i in 0...skills.length)
		{
			var skill = skills[i];
			var skillSprite = new SkillSprite(skill, this);
			var tile = skillSprite.tile;

			// render skills right of player chars, and left of enemy chars.
			if (this.info.type == PLAYER)
			{
				skillSprite.setPosition(sprite.width + (tile.width + 8) * i, 0);
			}
			else if (this.info.type == ENEMY)
			{
				skillSprite.setPosition(0 - (tile.width + 8) * (i + 1), 0);
			}
			this.add(skillSprite);
			skillSprites.push(skillSprite);
		}
	}

	public function new(info:CharacterInfo)
	{
		super(0, 0);
		this.info = info;
		this.bm = GameController.battleManager;
		this.bam = GameController.battleAnimationManager;

		maxHp = currHp = info.maxHp;
		currBlock = 0;
		sprite = new FlxSprite();
		sprite.setGraphicSize(0, 64);

		setupSprite(info.spritePath);

		setupSkills(info.skills);

		setupHpBar();

		this.timer = new FlxTimer();
		timer.cancel();

		this.hurtSound = FlxG.sound.load(AssetPaths.standardHit2__wav);
		this.blockedSound = FlxG.sound.load(AssetPaths.blockedHit1__wav);
		this.gainBlockSound = FlxG.sound.load(AssetPaths.gainBlock1__wav);
	}
	/*
		override public function destroy()
			{
				super.destroy();
				FlxMouseEventManager.remove(sprite);
			}
	 */
}
