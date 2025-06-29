package options;

import openfl.utils.Assets;

class LanguageSubState extends ScriptedSubState
{
	#if TRANSLATIONS_ALLOWED
	var grpLanguages:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var languages:Array<String> = [];
	var displayLanguages:Map<String, String> = [];
	var curSelected:Int = 0;
	var titleText:Alphabet;
	public function new()
	{
		super();
		
		rpcDetails = 'Language Select Menu';
		
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);
		add(grpLanguages);
		
		titleText = new Alphabet(75, 45, 'Language Select', true);
		titleText.setScale(.6);
		titleText.alpha = .4;
		updateTitleText();
		add(titleText);

		languages.push(ClientPrefs.defaultData.language); //English (US)
		displayLanguages.set(ClientPrefs.defaultData.language, Language.defaultLangName);
		var directories:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/');
		for (directory in directories)
		{
			for (file in FileSystem.readDirectory(directory))
			{
				if(file.toLowerCase().endsWith('.lang'))
				{
					var langFile:String = file.substring(0, file.length - '.lang'.length).trim();
					if(!languages.contains(langFile))
						languages.push(langFile);

					if(!displayLanguages.exists(langFile))
					{
						var path:String = '$directory/$file';
						#if MODS_ALLOWED 
						var txt:String = File.getContent(path);
						#else
						var txt:String = Assets.getText(path);
						#end

						var id:Int = txt.indexOf('\n');
						if(id > 0) //language display name shouldnt be an empty string or null
						{
							var name:String = txt.substr(0, id).trim();
							if(!name.contains(':')) displayLanguages.set(langFile, name);
						}
						else if(txt.trim().length > 0 && !txt.contains(':')) displayLanguages.set(langFile, txt.trim());
					}
				}
			}
		}

		languages.sort(function(a:String, b:String)
		{
			a = (displayLanguages.exists(a) ? displayLanguages.get(a) : a).toLowerCase();
			b = (displayLanguages.exists(b) ? displayLanguages.get(b) : b).toLowerCase();
			if (a < b) return -1;
			else if (a > b) return 1;
			return 0;
		});

		//trace(ClientPrefs.data.language);
		curSelected = languages.indexOf(ClientPrefs.data.language);
		if(curSelected < 0)
		{
			//trace('Language not found: ' + ClientPrefs.data.language);
			ClientPrefs.data.language = ClientPrefs.defaultData.language;
			curSelected = Std.int(Math.max(0, languages.indexOf(ClientPrefs.data.language)));
		}

		for (num => lang in languages)
		{
			var name:String = displayLanguages.get(lang);
			if(name == null) name = lang;

			var text:Alphabet = new Alphabet(0, 300, name, true);
			text.isMenuItem = true;
			text.targetY = num;
			text.changeX = false;
			text.distancePerItem.y = 100;
			if(languages.length < 7)
			{
				text.changeY = false;
				text.screenCenter(Y);
				text.y += (100 * (num - (languages.length / 2))) + 45;
			}
			text.screenCenter(X);
			grpLanguages.add(text);
		}
		changeSelected();
	}

	var changedLanguage:Bool = false;
	override function update(elapsed:Float) {
		preUpdate(elapsed);
		
		super.update(elapsed);

		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
		if(controls.UI_UP_P)
			changeSelected(-1 * mult);
		if(controls.UI_DOWN_P)
			changeSelected(1 * mult);
		if(FlxG.mouse.wheel != 0)
			changeSelected(FlxG.mouse.wheel * mult);

		if(controls.BACK)
		{
			if(changedLanguage)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.resetState();
			}
			else close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
			ClientPrefs.data.language = languages[curSelected];
			//trace(ClientPrefs.data.language);
			ClientPrefs.saveSettings();
			Language.reloadPhrases();
			changedLanguage = true;
			updateTitleText();
			changeSelected();
		}
		
		postUpdate(elapsed);
	}

	function changeSelected(change:Int = 0) {
		var next:Int = FlxMath.wrap(curSelected + change, 0, languages.length - 1);
		
		if (callOnScripts('onSelectItem', [languages[next], next], true) != psychlua.LuaUtils.Function_Stop) {
			curSelected = next;
			
			for (num => lang in grpLanguages) {
				lang.targetY = num - curSelected;
				
				lang.alpha = (num == curSelected ? 1 : .6);
				lang.color = (ClientPrefs.data.language == languages[num] ? 0xffffcc33 : FlxColor.WHITE);
			}
			
			if (change != 0)
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		}
	}
	
	function updateTitleText() {
		titleText.text = Language.getPhrase('language_menu', 'Language Select');
	}
	#end
}