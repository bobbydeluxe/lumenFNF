package options;

import psychlua.LuaUtils;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

import objects.CheckboxThingie;
import objects.AttachedText;
import options.Option;
import backend.InputFormatter;

class BaseOptionsMenu extends ScriptedSubState
{
	private var optionsArray:Array<Option>;
	private var curOption:Option = null;
	private var curSelected:Int = 0;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;

	public var bg:FlxSprite;
	public function new(?title:String, ?rpcDetails:String)
	{
		super();
		
		this.title = title ?? 'Options';
		this.rpcDetails = rpcDetails ?? 'Options Menu';
		
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
	}
	
	public override function create():Void {
		preCreate();
		
		var titleText:Alphabet = new Alphabet(75, 45, title, true);
		titleText.setScale(0.6);
		titleText.alpha = 0.4;
		add(titleText);
		
		setupOptions();
		changeSelection();
		reloadCheckboxes();
		
		super.create();
	}
	
	public function setupOptions():Void {
		optionsArray ??= [];
		for (i => option in optionsArray) {
			var optionText:Alphabet = new Alphabet(220, 260, option.name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
			optionText.yMult = 90;*/
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(option.type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, Std.string(option.getValue()) == 'true');
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				//optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + option.getValue(), optionText.width + 60);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				option.child = valueText;
			}
			//optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(option);
		}
	}

	public function addOption(option:Option) {
		if (optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;
	override function update(elapsed:Float)
	{
		preUpdate(elapsed);
		
		super.update(elapsed);

		if (bindingKey) {
			bindingKeyUpdate(elapsed);
			return;
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		} if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (curOption != null && nextAccept <= 0) {
			switch(curOption.type) {
				case BOOL:
					if(controls.ACCEPT) {
						var nextValue:Bool = (curOption.getValue() == true ? false : true);
						if (callOnScripts('onAccept', [curOption], true) != LuaUtils.Function_Stop &&
							callOnScripts('onChangeItem', [curOption, nextValue], true) != LuaUtils.Function_Stop) {
							FlxG.sound.play(Paths.sound('scrollMenu'));
							curOption.setValue(nextValue);
							curOption.change();
							reloadCheckboxes();
						}
					}

				case KEYBIND:
					if (controls.ACCEPT) {
						if (callOnScripts('onAccept', [curOption], true) != LuaUtils.Function_Stop) {
							bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
							bindingBlack.scale.set(FlxG.width, FlxG.height);
							bindingBlack.updateHitbox();
							bindingBlack.alpha = 0;
							FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
							add(bindingBlack);
		
							bindingText = new Alphabet(FlxG.width / 2, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
							bindingText.alignment = CENTERED;
							add(bindingText);
							
							bindingText2 = new Alphabet(FlxG.width / 2, 340, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete'), true);
							bindingText2.alignment = CENTERED;
							add(bindingText2);
		
							bindingKey = true;
							holdingEsc = 0;
							ClientPrefs.toggleVolumeKeys(false);
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
					}

				default:
					if(controls.UI_LEFT || controls.UI_RIGHT) {
						var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
						
						if (pressed)
							holdTime = 0;
						if (curOption.type != STRING)
							holdTime += elapsed;
						
						if (holdTime > 0.5 || pressed) {
							if (pressed) {
								var add:Dynamic = null;
								if (curOption.type != STRING)
									add = (pressed ? controls.UI_LEFT_P : controls.UI_LEFT) ? -curOption.changeValue : curOption.changeValue;
		
								switch(curOption.type) {
									case INT, FLOAT, PERCENT:
										holdValue = curOption.getValue() + add;
										if (holdValue < curOption.minValue) holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
										if(curOption.type == INT) {
											holdValue = Math.round(holdValue);
											if (callOnScripts('onChangeItem', [curOption, holdValue], true) != LuaUtils.Function_Stop)
												curOption.setValue(holdValue);
										}
										else {
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											if (callOnScripts('onChangeItem', [curOption, holdValue], true) != LuaUtils.Function_Stop)
												curOption.setValue(holdValue);
										}
		
									case STRING:
										var num:Int = curOption.curOption; //lol
										num = FlxMath.wrap(num + (controls.UI_LEFT_P ? -1 : 1), 0, curOption.options.length - 1);
										
										if (callOnScripts('onChangeItem', [curOption, curOption.options[num], num], true) != LuaUtils.Function_Stop) {
											curOption.curOption = num;
											curOption.setValue(curOption.options[num]);
										}

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('scrollMenu'));
							} else if (curOption.type != STRING) {
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								
								if (holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
								
								switch(curOption.type) {
									case INT:
										var target:Int = Math.round(holdValue);
										if (callOnScripts('onChangeItem', [curOption, target], true) != LuaUtils.Function_Stop && curOption.getValue() != target) {
											curOption.setValue(target);
											updateTextFrom(curOption);
											curOption.change();
										}
										
									case FLOAT | PERCENT:
										var target:Float = FlxMath.roundDecimal(holdValue, curOption.decimals);
										if (callOnScripts('onChangeItem', [curOption, target], true) != LuaUtils.Function_Stop && curOption.getValue() != target) {
											curOption.setValue(target);
											updateTextFrom(curOption);
											curOption.change();
										}
										
									default:
								}
							}
						}
					} else if (controls.UI_LEFT_R || controls.UI_RIGHT_R) {
						if (holdTime > 0.5)
							FlxG.sound.play(Paths.sound('scrollMenu'));
						holdTime = 0;
					}
			}

			if(controls.RESET)
			{
				var leOption:Option = optionsArray[curSelected];
				if (leOption.type != KEYBIND) {
					var args:Array<Dynamic> = [leOption, leOption.defaultValue];
					if (leOption.type != BOOL) {
						if (leOption.type == STRING) {
							leOption.curOption = leOption.options.indexOf(leOption.defaultValue);
							args.push(leOption.curOption);
						}
						updateTextFrom(leOption);
					}
					if (callOnScripts('onResetItem', [leOption], true) != LuaUtils.Function_Stop &&
						callOnScripts('onChangeItem', args, true) != LuaUtils.Function_Stop)
						leOption.setValue(leOption.defaultValue);
				} else {
					var target:String = (!Controls.instance.controllerMode ? leOption.defaultKeys.keyboard : leOption.defaultKeys.gamepad);
					
					if (callOnScripts('onResetItem', [leOption], true) != LuaUtils.Function_Stop &&
						callOnScripts('onChangeItem', [leOption, target], true) != LuaUtils.Function_Stop) {
						leOption.setValue(target);
						updateBind(leOption);
					}
				}
				leOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0)
			nextAccept -= 1;
		
		postUpdate(elapsed);
	}

	function bindingKeyUpdate(elapsed:Float)
	{
		if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				if (!controls.controllerMode) curOption.keys.keyboard = NONE;
				else curOption.keys.gamepad = NONE;
				updateBind(!controls.controllerMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			if(!controls.controllerMode)
			{
				if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
					var keyReleased:FlxKey = cast (FlxG.keys.firstJustReleased(), FlxKey);

					if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
					{
						changed = true;
						curOption.keys.keyboard = keyPressed;
					}
					else if(keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
					{
						changed = true;
						curOption.keys.keyboard = keyReleased;
					}
				}
			}
			else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:FlxGamepadInputID = NONE;
				var keyReleased:FlxGamepadInputID = NONE;
				if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
					keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
				else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
					keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if(gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if(keyPressed != NONE || keyReleased != NONE) break;
						}
					}
				}

				if(keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					changed = true;
					curOption.keys.gamepad = keyPressed;
				}
				else if(keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					changed = true;
					curOption.keys.gamepad = keyReleased;
				}
			}

			if(changed)
			{
				var target:Dynamic;
				var key:String = null;
				if (!controls.controllerMode) {
					if (curOption.keys.keyboard == null) curOption.keys.keyboard = 'NONE';
					target = curOption.keys.keyboard;
					key = InputFormatter.getKeyName(FlxKey.fromString(target));
				} else {
					if(curOption.keys.gamepad == null) curOption.keys.gamepad = 'NONE';
					target = curOption.keys.gamepad;
					key = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(target));
				}
				
				if (callOnScripts('onChangeItem', [curOption, target], true) != LuaUtils.Function_Stop) {
					curOption.setValue(target);
					updateBind(key);
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				closeBinding(); // the state will close regardless of stopping, cant leave the player stuck here!!
			}
		}
		
		postUpdate(elapsed);
	}

	final MAX_KEYBIND_WIDTH = 320;
	function updateBind(?text:String = null, ?option:Option = null)
	{
		if(option == null) option = curOption;
		if(text == null)
		{
			text = option.getValue();
			if(text == null) text = 'NONE';

			if(!controls.controllerMode)
				text = InputFormatter.getKeyName(FlxKey.fromString(text));
			else
				text = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(text));
		}

		var bind:AttachedText = cast option.child;
		var attach:AttachedText = new AttachedText(text, bind.offsetX);
		attach.sprTracker = bind.sprTracker;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		playstationCheck(attach);
		attach.scaleX = Math.min(1, MAX_KEYBIND_WIDTH / attach.width);
		attach.x = bind.x;
		attach.y = bind.y;

		option.child = attach;
		grpTexts.insert(grpTexts.members.indexOf(bind), attach);
		grpTexts.remove(bind);
		bind.destroy();
	}

	function playstationCheck(alpha:Alphabet)
	{
		if(!controls.controllerMode) return;

		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;
		var letter = alpha.letters[0];
		if(model == PS4)
		{
			switch(alpha.text)
			{
				case '[', ']': //Square and Triangle respectively
					letter.image = 'alphabet_playstation';
					letter.updateHitbox();
					
					letter.offset.x += 4;
					letter.offset.y -= 5;
			}
		}
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:Option) {
		if(option.type == KEYBIND) {
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == PERCENT) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}
	
	function changeSelection(change:Int = 0) {
		if (optionsArray.length == 0) return;
		
		var next:Int = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);
		
		if (callOnScripts('onSelectItem', [optionsArray[next], next], true) != LuaUtils.Function_Stop) {
			curSelected = next;
			curOption = optionsArray[curSelected]; //shorter lol
			
			updateTexts();
			
			if (change != 0)
				FlxG.sound.play(Paths.sound('scrollMenu'));
			
			callOnScripts('onSelectItemPost', [curOption, curSelected]);
		}
	}
	
	function updateTexts():Void {
		var option:Option = optionsArray[curSelected];
		
		descText.text = option?.description ?? 'Option unavailable';
		descText.screenCenter(Y);
		descText.y += 270;

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if(text.ID == curSelected) text.alpha = 1;
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true'; //Do not take off the Std.string() from this, it will break a thing in Mod Settings Menu
	}
}