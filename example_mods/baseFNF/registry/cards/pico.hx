import flixel.addons.display.FlxBackdrop;
import mikolka.compatibility.FreeplayHelpers;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import mikolka.funkin.FlxAtlasSprite;
import mikolka.compatibility.FunkinPath;

// Background layers and FX
var scrollLower:FlxBackdrop;
var scrollTop:FlxBackdrop;
var scrollMiddle:FlxBackdrop;
var glow:FlxSprite;
var glowDark:FlxSprite;
var blueBar:FlxSprite;

// Confirmation sprite
var confirmAtlas:FlxAtlasSprite;

// Beat frequency and options
var beatFreq:Int = 1;
var beatFreqList:Array<Int> = [1, 2, 4, 8];

function init() {
  // Hidden background to maintain vanilla fade transition
  pinkBack = new FlxSprite().loadGraphic(Paths.image('freeplay/pinkBack'));
  pinkBack.color = 0x240042;
  pinkBack.visible = false;
  add(pinkBack);

  // Scrolling background layers
  scrollBack = new FlxBackdrop(Paths.image('freeplay/backingCards/pico/lowerLoop'), 0x01, 20);
  scrollBack.setPosition(0, 200);
  scrollBack.flipX = true;
  scrollBack.alpha = 0.39;
  scrollBack.velocity.x = 110;
  add(scrollBack);

  scrollLower = new FlxBackdrop(Paths.image('freeplay/backingCards/pico/lowerLoop'), 0x01, 20);
  scrollLower.setPosition(0, 406);
  scrollLower.velocity.x = -110;
  add(scrollLower);

  blueBar = new FlxSprite(0, 239).loadGraphic(Paths.image('freeplay/backingCards/pico/blueBar'));
  blueBar.blend = 9;
  blueBar.alpha = 0.4;
  add(blueBar);

  // Animated top bar
  scrollTop = new FlxBackdrop(null, 0x01, 20);
  scrollTop.setPosition(0, 80);
  scrollTop.velocity.x = -220;
  scrollTop.frames = Paths.getSparrowAtlas('freeplay/backingCards/pico/topLoop');
  scrollTop.animation.addByPrefix('uzi', 'uzi info', 24, false);
  scrollTop.animation.addByPrefix('sniper', 'sniper info', 24, false);
  scrollTop.animation.addByPrefix('rocket launcher', 'rocket launcher info', 24, false);
  scrollTop.animation.addByPrefix('rifle', 'rifle info', 24, false);
  scrollTop.animation.addByPrefix('base', 'base', 24, false);
  scrollTop.animation.play('base');
  add(scrollTop);

  scrollMiddle = new FlxBackdrop(Paths.image('freeplay/backingCards/pico/middleLoop'), 0x01, 15);
  scrollMiddle.setPosition(0, 346);
  scrollMiddle.velocity.x = 220;
  add(scrollMiddle);

  // Glow effects
  glowDark = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/backingCards/pico/glow'));
  glowDark.blend = 9;
  add(glowDark);

  glow = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/backingCards/pico/glow'));
  glow.blend = 0;
  add(glow);

  // Hide visuals initially for smooth entrance
  blueBar.visible = false;
  scrollBack.visible = false;
  scrollLower.visible = false;
  scrollTop.visible = false;
  scrollMiddle.visible = false;
  glow.visible = false;
  glowDark.visible = false;

  // Confirmation sprite
  confirmAtlas = new FlxAtlasSprite(5, 55, FunkinPath.animateAtlas("freeplay/backingCards/pico/pico-confirm"));
  confirmAtlas.visible = false;
  add(confirmAtlas);

  // Card glow for transition flair
  cardGlow = new FlxSprite(-30, -30).loadGraphic(Paths.image('freeplay/cardGlow'));
  cardGlow.blend = 0;
  cardGlow.visible = false;
  add(cardGlow);
}

function introDone():Void {
  pinkBack.color = 0xFF98A2F3;
  pinkBack.visible = true;

  blueBar.visible = true;
  scrollBack.visible = true;
  scrollLower.visible = true;
  scrollTop.visible = true;
  scrollMiddle.visible = true;
  glowDark.visible = true;
  glow.visible = true;

  cardGlow.visible = true;
  FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});
}

function beatHit(curBeat:Int) {
  beatFreq = beatFreqList[Math.floor(FreeplayHelpers.BPM / 140)];

  if (curBeat % beatFreq != 0) return;

  FlxTween.cancelTweensOf(glow);
  FlxTween.cancelTweensOf(glowDark);

  glow.alpha = 0.8;
  FlxTween.tween(glow, {alpha: 0}, 16 / 24, {ease: FlxEase.quartOut});

  glowDark.alpha = 0;
  FlxTween.tween(glowDark, {alpha: 0.6}, 18 / 24, {ease: FlxEase.quartOut});
}

function confirm() {
  confirmAtlas.visible = true;
  confirmAtlas.anim.play("");
}

function applyExitMovers(exitMovers, exitMoversCharSel) {
  if (exitMovers == null || exitMoversCharSel == null) return;

  exitMoversCharSel.set([scrollTop],      { y: -90, speed: 0.8, wait: 0.1 });
  exitMoversCharSel.set([scrollMiddle],   { y: -80, speed: 0.8, wait: 0.1 });
  exitMoversCharSel.set([blueBar],        { y: -70, speed: 0.8, wait: 0.1 });
  exitMoversCharSel.set([scrollLower],    { y: -60, speed: 0.8, wait: 0.1 });
  exitMoversCharSel.set([scrollBack],     { y: -50, speed: 0.8, wait: 0.1 });
}

function disappear() {
  // Custom transition to preserve aesthetic
  FlxTween.color(pinkBack, 0.25, 0xFF98A2F3, 0xFFFFD0D5, {ease: FlxEase.quadOut});
  FlxTween.tween(pinkBack, {x: -1000}, 0.6, {ease: FlxEase.sineOut});

  blueBar.visible = false;
  scrollBack.visible = false;
  scrollLower.visible = false;
  scrollTop.visible = false;
  scrollMiddle.visible = false;
  glowDark.visible = false;
  glow.visible = false;

  cardGlow.visible = true;
  cardGlow.alpha = 1;
  cardGlow.scale.set(1, 1);
  FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.25, {ease: FlxEase.sineOut});
}

function enterCharSel() {
  FlxTween.tween(scrollBack.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
  FlxTween.tween(scrollLower.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
  FlxTween.tween(scrollTop.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
  FlxTween.tween(scrollMiddle.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
}