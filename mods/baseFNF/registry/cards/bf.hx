import mikolka.vslice.freeplay.BGScrollingText;
import mikolka.compatibility.FreeplayHelpers;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

var moreWays:BGScrollingText;
var funnyScroll:BGScrollingText;
var txtNuts:BGScrollingText;
var funnyScroll2:BGScrollingText;
var moreWays2:BGScrollingText;
var funnyScroll3:BGScrollingText;

var glow:FlxSprite;
var glowDark:FlxSprite;

var beatFreq:Int = 1;
var beatFreqList:Array<Int> = [1, 2, 4, 8];

function onCreate() {
	funnyScroll = new BGScrollingText(0, 220, djText1, FlxG.width / 2, false, 60);
	funnyScroll2 = new BGScrollingText(0, 335, djText1, FlxG.width / 2, false, 60);
	moreWays = new BGScrollingText(0, 160, djText2, FlxG.width, true, 43);
	moreWays2 = new BGScrollingText(0, 397, djText2, FlxG.width, true, 43);
	txtNuts = new BGScrollingText(0, 285, djText3, FlxG.width / 2, true, 43);
	funnyScroll3 = new BGScrollingText(0, orangeBackShit.y + 10, djText1, FlxG.width / 2, false, 60);
}

function init() {
	// Set initial visibility to false
	moreWays.visible = false;
	funnyScroll.visible = false;
	txtNuts.visible = false;
	funnyScroll2.visible = false;
	moreWays2.visible = false;
	funnyScroll3.visible = false;

	// Set up styles, speeds, and cameras
	moreWays.funnyColor = 0xFFFFF383;
	moreWays.speed = 6.8;
	moreWays.cameras = [FlxG.state.subState.funnyCam];
	add(moreWays);

	funnyScroll.funnyColor = 0xFFFF9963;
	funnyScroll.speed = -3.8;
	funnyScroll.cameras = [FlxG.state.subState.funnyCam];
	add(funnyScroll);

	txtNuts.speed = 3.5;
	txtNuts.cameras = [FlxG.state.subState.funnyCam];
	add(txtNuts);

	funnyScroll2.funnyColor = 0xFFFF9963;
	funnyScroll2.speed = -3.8;
	funnyScroll2.cameras = [FlxG.state.subState.funnyCam];
	add(funnyScroll2);

	moreWays2.funnyColor = 0xFFFFF383;
	moreWays2.speed = 6.8;
	moreWays2.cameras = [FlxG.state.subState.funnyCam];
	add(moreWays2);

	funnyScroll3.funnyColor = 0xFFFEA400;
	funnyScroll3.speed = -3.8;
	funnyScroll3.cameras = [FlxG.state.subState.funnyCam];
	add(funnyScroll3);

	// Glow sprites
	glowDark = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/beatglow'));
	glowDark.blend = 9;
	glowDark.cameras = [FlxG.state.subState.funnyCam];
	add(glowDark);

	glow = new FlxSprite(-300, 330).loadGraphic(Paths.image('freeplay/beatglow'));
	glow.blend = 0;
	glow.cameras = [FlxG.state.subState.funnyCam];
	add(glow);

	glowDark.visible = false;
	glow.visible = false;
}

function beatHit(curBeat) {
	beatFreq = beatFreqList[Math.floor(FreeplayHelpers.BPM / 140)];
	if (curBeat % beatFreq != 0) return;

	FlxTween.cancelTweensOf(glow);
	FlxTween.cancelTweensOf(glowDark);

	glow.alpha = 0.8;
	FlxTween.tween(glow, {alpha: 0}, 16 / 24, {ease: FlxEase.quartOut});
	glowDark.alpha = 0;
	FlxTween.tween(glowDark, {alpha: 0.6}, 18 / 24, {ease: FlxEase.quartOut});
}

function introDone() {
	showSprites(true);
}

function confirm() {
	showSprites(false);
}

function disappear() {
  showSprites(false);
}
function showSprites(show:Bool) {
	moreWays.visible = show;
	funnyScroll.visible = show;
	txtNuts.visible = show;
	funnyScroll2.visible = show;
	moreWays2.visible = show;
	funnyScroll3.visible = show;
	glowDark.visible = show;
	glow.visible = show;
}

function applyExitMovers(exitMovers, exitMoversCharSel) {
	if (exitMovers == null || exitMoversCharSel == null) return;

	exitMovers.set([moreWays], {
		x: FlxG.width * 2,
		speed: 0.4
	});

	exitMovers.set([funnyScroll], {
		x: -funnyScroll.width * 2,
		y: funnyScroll.y,
		speed: 0.4,
		wait: 0
	});

	exitMovers.set([txtNuts], {
		x: FlxG.width * 2,
		speed: 0.4
	});

	exitMovers.set([funnyScroll2], {
		x: -funnyScroll2.width * 2,
		speed: 0.5
	});

	exitMovers.set([moreWays2], {
		x: FlxG.width * 2,
		speed: 0.4
	});

	exitMovers.set([funnyScroll3], {
		x: -funnyScroll3.width * 2,
		speed: 0.3
	});

	exitMoversCharSel.set([
		moreWays, funnyScroll, txtNuts, funnyScroll2, moreWays2, funnyScroll3
	], {
		y: -60,
		speed: 0.8,
		wait: 0.1
	});
}

function enterCharSel() {
	FlxTween.tween(funnyScroll, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
	FlxTween.tween(funnyScroll2, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
	FlxTween.tween(moreWays, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
	FlxTween.tween(moreWays2, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
	FlxTween.tween(txtNuts, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
	FlxTween.tween(funnyScroll3, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
}