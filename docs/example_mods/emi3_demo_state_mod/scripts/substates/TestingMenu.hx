import flixel.group.FlxTypedGroup;

var input:Bool = false;
var curSelected:Int = 0;
var grpTexts:FlxTypedGroup;
var options:Array<String> = [
	'State Test',
	'Sub-State Test'
];

function onCreate():Void {
	bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
	bg.scale.set(FlxG.width, FlxG.height);
	bg.scrollFactor.set();
	bg.updateHitbox();
	bg.alpha = .6;
	add(bg);

	grpTexts = new FlxTypedGroup();
	add(grpTexts);
	
	for (i in 0...options.length) {
		var option = options[i];
		var leText:Alphabet = new Alphabet(90, 320, option, true);
		leText.scrollFactor.set();
		leText.isMenuItem = true;
		leText.targetY = i - curSelected;
		leText.snapToPosition();
		grpTexts.add(leText);
	}
	
	changeSelection(0);
	
	parentState.persistentDraw = false;
	parentState.persistentUpdate = false;
}

function onUpdate(elapsed:Float):Void {
	if (controls.BACK) {
		close();
		return;
	}
	
	if (input) {
		if (controls.ACCEPT) {
			switch (options[curSelected]) {
				case 'State Test':
					MusicBeatState.switchState(new CustomState('CustomStateTest'));
				case 'Sub-State Test':
					var text:Alphabet = grpTexts.members[1];
					var newText:String = 'this is already a custom substate!!';
					if (text.text != newText) {
						text.text = newText;
						text.color = 0xff00ffff;
						text.setScale(.72, .72);
						
						FlxG.sound.play(Paths.sound('confirmMenu'), .7);
					} else {
						FlxG.sound.play(Paths.sound('cancelMenu'), .7);
					}
				default:
			}
		}
		
		if (controls.UI_UP_P) {
			changeSelection(-1);
		} if (controls.UI_DOWN_P) {
			changeSelection(1);
		}
	} else {
		input = true;
	}
}

function changeSelection(mod:Int):Void {
	curSelected = FlxMath.wrap(curSelected + mod, 0, options.length - 1);
	
	if (mod != 0)
		FlxG.sound.play(Paths.sound('scrollMenu'), .4);
	
	// Lumen does not support "i => item in grpTexts", so use a traditional for loop with index
	for (i in 0...grpTexts.length) {
		var item = grpTexts.members[i];
		item.targetY = i - curSelected;
		item.alpha = (i == curSelected ? 1 : .6);
	}
}

function onDestroy():Void {
	parentState.persistentDraw = true;
	parentState.persistentUpdate = true;
}