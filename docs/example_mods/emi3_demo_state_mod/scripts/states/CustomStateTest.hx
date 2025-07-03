import flixel.group.FlxTypedSpriteGroup;
import states.MainMenuState;
import shaders.ColorSwap;
import Reflect;

import backend.ui.PsychUIButton;
import backend.ui.PsychUIBox;

var bf:Character;
var hsb:ColorSwap;
var click:Int = 0;
var point:Int = 0;
var alphabet:Alphabet;
var alphabetButSmall:Alphabet;

var tab:PsychUIBox;

var pointMultiplier:Int = 1;
var toys:FlxTypedSpriteGroup;

function onCreate():Void {
	rpcDetails = 'Custom State Test!!'; // custom RPC
	rpcState = 'Testing a Custom State';
	
	// you can also call updatePresence() to update it on demand! by default it only runs once on state creation.
	
	FlxG.mouse.visible = true;
	Conductor.bpm = 102;
	
	persistentUpdate = true;
	
	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
	bg.antialiasing = ClientPrefs.data.antialiasing;
	bg.color = 0xff808080;
	bg.screenCenter();
	add(bg);
	
	bf = new Character();
	bf.scale.set(.7, .7);
	bf.updateHitbox();
	bf.dance();
	add(bf);
	
	if (ClientPrefs.data.shaders) {
		hsb = new ColorSwap();
		bf.shader = hsb.shader;
	}
	
	alphabet = new Alphabet(0, 50, 'testing !!');
	alphabet.setScale(.4, .4);
	add(alphabet);
	alphabetButSmall = new Alphabet(0, 82, 'testing !! again !!!');
	alphabetButSmall.setScale(.25, .25);
	alphabetButSmall.alpha = .5;
	add(alphabetButSmall);
	
	updateClick();
	
	tab = new PsychUIBox(0, 50, 300, 90, ['Boyfriend Clicker']);
	tab.x = FlxG.width - tab.y - tab.width;
	add(tab);
	
	toys = new FlxTypedSpriteGroup();
	add(toys);
	
	var button:Dynamic = createButton(30, 'Cursor', 10, 1.1, (button) -> {
		var cursor:FlxSprite = new FlxSprite(0, 0, Paths.image('clicker/cursor'));
		cursor.setVar('toyType', 'cursor');
		cursor.setVar('toyTime', 0);
		cursor.screenCenter();
		
		cursor.x += FlxG.random.int(-120, 120);
		cursor.y += FlxG.random.int(-120, 120);
		cursor.alpha = .5;
		
		toys.add(cursor);
		button.label = 'Cursors: ' + getToyCount('cursor');
	});
	button[0].label = 'Cursors: 0';
	
	var button:Dynamic = createButton(60, 'Multiplier', 100, 2.2, (button) -> {
		pointMultiplier *= 2;
		button.label = 'Multiplier: ' + pointMultiplier + 'x';
	});
	button[0].label = 'Multiplier: 1x';
}

function onUpdate(elapsed:Float):Void {
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;
	
	var time:FLoat = MusicBeatState.timePassedOnState;
	bf.setPosition((FlxG.width - bf.frameWidth) * .5 + Math.sin(time * 4) * 50, (FlxG.height - bf.frameHeight) * .5 + Math.cos(time * 3.159324832) * 50);
	
	bf.setColorTransform();
	if (FlxG.mouse.overlaps(bf)) {
		if (FlxG.mouse.pressed) {
			bf.setColorTransform(.75, .75, .75);
		} else {
			bf.setColorTransform(1.5, 1.5, 1.5);
		}
		
		if (FlxG.mouse.justReleased)
			doClick(pointMultiplier, true);
	}
	
	for (toy in toys)
		updateToy(toy, elapsed);
	
	if (controls.BACK)
		MusicBeatState.switchState(new MainMenuState(false, true));
}

function onBeatHit(beat:Int):Void {
	if (beat % 2 == 0)
		bf.dance();
}

function onDestroy():Void {
	FlxG.mouse.visible = false;
}

// Fun
function createButton(y:Float, item:String, initialCost:Int, ?mult:Float = 1.3, ?funny:PsychUIButton -> Void) {
	var ok = [];
	var cost:Int = initialCost;
	var text:FlxText = new FlxText(0, 0, 240, 'Cost: ' + initialCost);
	var button:PsychUIButton = new PsychUIButton(10, y, 'Buy ' + item, () -> {
		if (point >= Std.int(cost)) {
			FlxG.sound.play(Paths.sound('confirmMenu'), .75);
			
			point -= Std.int(cost);
			updateClick();
			
			cost *= mult;
			text.text = 'Cost: ' + Std.int(cost);
			
			if (funny != null)
				funny(ok[0]);
		}
	}, 100);
	ok.push(button);
	
	text.setPosition(button.x + button.width + 10, button.y + 3);
	
	tab.add(button);
	tab.add(text);
	
	return [button, text];
}

function doClick(?count:Int, ?mine:Bool = false) {
	FlxG.sound.play(Paths.sound('scrollMenu'), mine ? .4 : .2);
	
	point += count ?? 1;
	click += count ?? 1;
	updateClick();
}

function updateClick() {
	alphabet.text = point == 1 ? (point + " boyfriend point") : (point + " boyfriend points");
	alphabet.screenCenter(0x01);
	alphabetButSmall.text = '(' + click + ' clicks total)';
	alphabetButSmall.screenCenter(0x01);
	
	if (hsb != null)
		hsb.hue = (click / 50) % 1;
}

function updateToy(toy:FlxBasic, elapsed:Float) {
	switch (toy.toyType) {
		case 'cursor':
			toy.toyTime += elapsed;
			
			if (toy.toyTime >= 1) {
				FlxTween.color(toy, .25, 0x8000ff00, 0x80ffffff);
				
				toy.toyTime -= 1;
				doClick();
			}
		default:
			trace('who r you (' + toy.toyType + ')');
	}
}
function getToyCount(type:String) {
	var count:Int = 0;
	for (toy in toys) {
		if (toy.toyType == type)
			count ++;
	}
	return count;
}

function onShutDown() {
	trace('haha owned');
	return Function_Stop;
}