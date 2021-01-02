package ui.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import models.player.CharacterInfo;
import models.skills.Skill;
import ui.TooltipLayer.Tooltip;
import ui.battle.DamageNumbers;
import ui.battle.ITurnTriggerable;
import ui.battle.status.Status;
import utils.BattleAnimationManager;
import utils.BattleManager.BattleManagerStateNames;
import utils.BattleManager;
import utils.GameController;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

typedef TakeDamageOptions =
{
	?sound:FlxSound,
}

/** Represents a character's sprite during battle. */
class CharacterSprite extends FlxSpriteGroup implements ITurnTriggerable
{
	public var info:CharacterInfo;
	public var maxHp:Int;
	public var currHp(default, set):Int;
	public var currBlock(default, set):Int;
	public var skillSprites:Array<SkillSprite> = new Array<SkillSprite>();
	public var skillsPlayedThisTurn:Int = 0;

	public var dead(default, set):Bool = false;

	// hack for demo
	public var drone:FlxSprite;

	// the "body" of the character.
	public var sprite:FlxSprite;

	// an arrow pointing to the body, which will appear when you are targeting a skill.
	public var targetArrow:FlxSprite;

	// the character's hp and block displays.
	var hpBarSprite:CharacterHpBar;

	var statusDisplay:CharacterStatusDisplay;

	// the BM will set this btn's click handler to cancel a skill
	public var cancelSkillBtn:FlxSprite;

	// reference to the global managers.
	var bm:BattleManager;
	var bam:BattleAnimationManager;

	// internal timer used for some animations.
	var timer:FlxTimer;

	var hurtSound:FlxSound;
	var blockedSound:FlxSound;
	var gainBlockSound:FlxSound;

	// target arrow X distance from char sprite.
	public static inline final TARGET_ARROW_DISTANCE = 48;

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
		this.info.currHp = val; // set the hp on the char info too.
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
		{
			disableAllSkills();
			bm.enemyDiscardCards += info.draw;
		}
		return dead = val;
	}

	/** Add that many stacks of the status to this char. **/
	public function addStatus(type:StatusType, stacks:Int = 1)
	{
		statusDisplay.addStatusByType(type, stacks);
		spawnDamageNumber('+${type.getName()}', ViewUtils.getColorForStatus(type), false);
	}

	/** Completely remove the status from the char. Returns the stacks removed.**/
	public function removeStatus(type:StatusType)
	{
		return statusDisplay.removeStatusByType(type);
	}

	public function hasStatus(type:StatusType):Int
	{
		return statusDisplay.hasStatus(type);
	}

	/** Call this function for the character to take damage blocked by block. **/
	public function takeDamage(val:Int, ?options:TakeDamageOptions)
	{
		if (dead)
		{
			return;
			trace('a dead char took damage. ${this.info.name}');
		}

		if (options == null)
			options = {};

		var hurtSound:FlxSound;
		if (options.sound == null)
			hurtSound = this.hurtSound;
		else
			hurtSound = options.sound;

		currBlock -= val;
		if (val > currBlock)
		{
			playHurtAnimation();
			hurtSound.play(true);
			currHp -= (val - currBlock);
			FlxG.camera.shake(0.01, 0.1);
		}
		else
		{
			blockedSound.play(true);
		}

		spawnDamageNumber(Std.string(val));
	}

	/** Call this when one char deals damage to other char.**/
	public function dealDamageTo(target:CharacterSprite, val:Int)
	{
		var damage = onDealDamage(val);
		target.takeDamage(damage);
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

	public function isPlayingHurtAnimation()
	{
		return !timer.finished;
	}

	function playDeadAnimation()
	{
		var onComplete = (_) ->
		{
			this.kill();
		}
		var tween = FlxTween.tween(sprite, {alpha: 0}, 1, {onComplete: onComplete});
		bam.addTweens([tween]);
	}

	function spawnDamageNumber(val:String, color:FlxColor = FlxColor.WHITE, usePhysics:Bool = true)
	{
		if (sprite == null)
			return;

		var spawnX = sprite.x + sprite.width / 2;
		var spawnY = sprite.y;

		GameController.battleDamageNumbers.spawnDamageNumber(spawnX, spawnY, val, color, usePhysics);
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

	public function onPlayerStartTurn(context:BattleContext)
	{
		if (this.info.type == PLAYER)
		{
			currBlock = 0;
			statusDisplay.onPlayerStartTurn(context);
		}

		refreshAllSkills(); // refresh both the players' and the enemies' skills.
	}

	public function onPlayerEndTurn(context:BattleContext)
	{
		if (this.info.type == PLAYER)
		{
			statusDisplay.onPlayerEndTurn(context);
			skillsPlayedThisTurn = 0;
		}
	}

	public function onEnemyStartTurn(context:BattleContext)
	{
		if (this.info.type == ENEMY)
		{
			currBlock = 0;
			statusDisplay.onEnemyStartTurn(context);
		}
	}

	public function onEnemyEndTurn(context:BattleContext)
	{
		if (this.info.type == ENEMY)
		{
			statusDisplay.onEnemyEndTurn(context);
			skillsPlayedThisTurn = 0;
		}
	}

	function onDealDamage(originalDamage)
	{
		return statusDisplay.onDealDamage(originalDamage);
	}

	function onPlaySkill(skillSprite:SkillSprite, context:BattleContext)
	{
		skillsPlayedThisTurn += 1;
		statusDisplay.onPlaySkill(skillSprite, context);
	}

	public function playSkill(skillSprite:SkillSprite, targets:Array<CharacterSprite>, context:BattleContext)
	{
		onPlaySkill(skillSprite, context);
		skillSprite.play(targets, context);
	}

	public function setOnClick(onClick:CharacterSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(sprite, (_) -> onClick(this));
	}

	public function setOnHover(onOver:CharacterSprite->Void, onOut:CharacterSprite->Void)
	{
		FlxMouseEventManager.setMouseOverCallback(sprite, (_) -> onOver(this));
		FlxMouseEventManager.setMouseOutCallback(sprite, (_) -> onOut(this));
	}

	public function setOnClickCancelSkill(onClick:Void->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(cancelSkillBtn, (_) -> onClick());
	}

	public static function sampleSlime(lvl:Int = 1)
	{
		return new CharacterSprite(CharacterInfo.sampleSlime());
	}

	public static function sampleRyder()
	{
		return new CharacterSprite(CharacterInfo.sampleRyder());
	}

	/** Setup this character's sprite. It is the reference for the rest of the things, so probably should call this first. **/
	function setupSprite(assetPath:FlxGraphicAsset)
	{
		this.sprite = new FlxSprite(0, 0, assetPath);
		sprite.setGraphicSize(0, Std.int(sprite.height * 4));
		sprite.updateHitbox();
		ViewUtils.centerSprite(sprite, 0, 0);
		this.add(sprite);
		FlxMouseEventManager.add(sprite, null, null, null, null, false, true, false);

		// add the targeting arrow. Render right side for players, left side for enemies,
		// assumes sprite is at 0, 0.
		var targetArrowXPos = TARGET_ARROW_DISTANCE + sprite.width / 2;
		if (this.info.type == PLAYER)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.GreenArrow1L__png);
			ViewUtils.centerSprite(targetArrow, targetArrowXPos, 0);
		}
		else if (this.info.type == ENEMY)
		{
			this.targetArrow = new FlxSprite(0, 0, AssetPaths.GreenArrow1R__png);
			ViewUtils.centerSprite(targetArrow, -targetArrowXPos, 0);
		}
		targetArrow.scale.set(3, 3);
		this.add(targetArrow);
		targetArrow.visible = false;

		if (info.name == 'Ryder')
		{
			drone = new FlxSprite(100, 0);
			drone.loadGraphic(AssetPaths.ryderDrone1Sheet__png, true, 32, 32);
			drone.scale.set(4, 4);
			drone.updateHitbox();
			drone.animation.add('idle', [0, 1], 24, true);
			drone.animation.play('idle');
			add(drone);
		}
	}

	/** Add skills to this character, and setup the skill tiles for battle */
	function setupSkills(skills:Array<Skill>)
	{
		var skills = this.info.skills;
		var yStart = -sprite.height / 2;
		var cursor = sprite.width / 2;
		var padding = 4;
		for (i in 0...skills.length)
		{
			var skill = skills[i];
			var skillSprite = new SkillSprite(skill, this);

			// render skills right of player chars, and left of enemy chars.
			if (this.info.type == PLAYER)
				skillSprite.setPosition(cursor, yStart);
			else if (this.info.type == ENEMY)
				skillSprite.setPosition(-cursor, yStart);

			this.add(skillSprite);
			cursor += skillSprite.tile.width + padding;
			skillSprites.push(skillSprite);
		}
	}

	/** Setup this character's HPbar and block indicator. Call this after setupSprite. **/
	function setupHpBar()
	{
		hpBarSprite = new CharacterHpBar(this);
		hpBarSprite.setPosition(0, this.sprite.height / 2 + 8);
		add(hpBarSprite);
	}

	/** Setup the spot under the HP bar where the char's statuses will show up. **/
	function setupStatusDisplay()
	{
		statusDisplay = new CharacterStatusDisplay(this);
		statusDisplay.setPosition(0, hpBarSprite.y + 28);
		add(statusDisplay);
	}

	function setupCancelSkillButton()
	{
		cancelSkillBtn = new FlxSprite(0, 0, AssetPaths.cancelTargeting__png);
		cancelSkillBtn.scale.set(3, 3);
		cancelSkillBtn.updateHitbox();
		ViewUtils.centerSprite(cancelSkillBtn, sprite.width / 2, -sprite.height / 2);
		this.add(cancelSkillBtn);
		// killing the cancel button here causes uber weird behavior, so don't do it!!

		FlxMouseEventManager.add(cancelSkillBtn);
		var tooltip = new Tooltip('Cancel', null);
		GameController.battleTooltipLayer.registerTooltip(tooltip, cancelSkillBtn);
	}

	public function new(info:CharacterInfo)
	{
		super(0, 0);
		this.info = info;
		this.bm = GameController.battleManager;
		this.bam = GameController.battleAnimationManager;

		maxHp = info.maxHp;
		currHp = info.currHp;
		currBlock = 0;

		setupSprite(info.spritePath);

		setupSkills(info.skills);

		setupHpBar();

		setupStatusDisplay();

		if (info.type == PLAYER)
			setupCancelSkillButton();

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
