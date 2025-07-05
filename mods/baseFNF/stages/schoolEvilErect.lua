function onCreate()
	addHaxeLibrary('FlxAngle', 'flixel.math')
	addHaxeLibrary('FlxTrail', 'flixel.addons.effects')
	makeLuaSprite('schoolBuildingEvil', 'weeb/erect/evilSchoolBG', -275, -20)
	setScrollFactor('schoolBuildingEvil', 0.8, 0.9)
	scaleObject('schoolBuildingEvil', 6, 6)
	addLuaSprite('schoolBuildingEvil')
	setProperty('schoolBuildingEvil.antialiasing', false)

	setCharScrollFactor()
end

function onCreatePost()
	runHaxeCode([[
		import flixel.math.FlxAngle;
		import flixel.addons.effects.FlxTrail;

		// Adds the trail behind the opponent.
		var dadTrail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		game.addBehindDad(dadTrail);

		// SHADER STUFF BELOW
		
		var maskRemaps:Map<String, String> = [
			"senpai-angry" => "senpai"
		];

		function getRemappedName(original:String):String
		{
			return maskRemaps.exists(original) ? maskRemaps.get(original) : original;
		}
		
		function applyShader(sprite)
		{
			var rim = new shaders.AdjustColorScreenspace();

			if (sprite == game.gf)
			{
				rim.setAdjustColor(-28, -20, -42, 11);
				rim.distance = 3;
				rim.threshold = 0.3;
			}
			else
			{
				rim.setAdjustColor(-28, -20, -66, 31);
				rim.distance = 4;
				rim.threshold = 0.1;
			}

			rim.color = 0xFF521D4B;
			rim.antialiasAmt = 0;
			rim.attachedSprite = sprite;

			var remapped = getRemappedName(sprite.curCharacter);

			if (Paths.fileExists("images/weeb/erect/masks/" + remapped + ".png"))
			{
				rim.altMaskImage = Paths.image("weeb/erect/masks/" + remapped).bitmap;
				rim.maskThreshold = 1;
				rim.useAltMask = true;
			}

			sprite.animation.callback = function(anim, frame, index)
			{
				rim.updateFrameInfo(sprite.frame);
			};
			
			return rim;
		}

		for (sprite in [game.dad, game.boyfriend, game.gf]) {
			sprite.shader = applyShader(sprite);
		}
	]])

	if shadersEnabled == true then
		if lowQuality == false then
			initLuaShader('wiggle')
			setSpriteShader('schoolBuildingEvil', 'wiggle')
			setShaderFloat('schoolBuildingEvil', 'uSpeed', 2)
			setShaderFloat('schoolBuildingEvil', 'uFrequency', 4)
			setShaderFloat('schoolBuildingEvil', 'uWaveAmplitude', 0.017)
			setShaderInt('schoolBuildingEvil', 'effectType', 0)
		end
	end

	-- Sets up the sprites for the 'Trigger BG Ghouls' event if it's present in the chart.
	for note = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', note, 'event') == 'Trigger BG Ghouls' then
			if lowQuality == false then
				makeAnimatedLuaSprite('girlfreaksEvil', 'weeb/bgGhouls', -100, 190)
				addAnimationByPrefix('girlfreaksEvil', 'anim', 'BG freaks glitch instance', 24, false)
				setScrollFactor('girlfreaksEvil', 0.9, 0.9)
				scaleObject('girlfreaksEvil', 6, 6)
				addLuaSprite('girlfreaksEvil')
				setProperty('girlfreaksEvil.antialiasing', false)
				setProperty('girlfreaksEvil.visible', false)
			end
		end
	end
end

-- Simple thing to update the wiggle shader.
local elapsedTime = 0
function onUpdatePost(elapsed)
	if shadersEnabled == true and lowQuality == false then
		elapsedTime = elapsedTime + elapsed
		setShaderFloat('schoolBuildingEvil', 'uTime', elapsedTime)
	end
end

-- Everything from this point is for the 'Trigger BG Ghouls' event
function onEvent(eventName, value1, value2, strumTime)
	if eventName == 'Trigger BG Ghouls' then
		if lowQuality == false then
			playAnim('girlfreaksEvil', 'anim', true)
			--setProperty('girlfreaksEvil.visible', true) -- Remove the comment if you want this event to work on the stage
			runTimer('freaksAnimLength', getProperty('girlfreaksEvil.animation.curAnim.numFrames') / 24)
		end
	end
	if eventName == 'Change Character' then
		setCharScrollFactor()
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'freaksAnimLength' then
		setProperty('girlfreaksEvil.visible', false)
	end
end

function setCharScrollFactor()
	setScrollFactor('dad', 1, 1)
	setScrollFactor('boyfriend', 1, 1)
	setScrollFactor('gf', 0.95, 0.95)
end