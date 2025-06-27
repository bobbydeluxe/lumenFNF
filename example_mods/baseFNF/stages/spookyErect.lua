function onCreate()
	makeAnimatedLuaSprite('outdoorTrees', 'spookyMansion/erect/bgtrees', 190, 30)
	addAnimationByPrefix('outdoorTrees', 'anim', 'bgtrees', 5)
	setScrollFactor('outdoorTrees', 0.85, 0.85)
	addLuaSprite('outdoorTrees')
	
	makeLuaSprite('corridorDark', 'spookyMansion/erect/bgDark', -360, -220)
	addLuaSprite('corridorDark')
	
	if lowQuality == false then
		makeLuaSprite('corridor', 'spookyMansion/erect/bgLight', -360, -220)
		addLuaSprite('corridor')
		setProperty('corridor.alpha', 0)

		makeLuaSprite('stairsDark', 'spookyMansion/erect/stairsDark', 966, -225)
		addLuaSprite('stairsDark', true)

		makeLuaSprite('stairs', 'spookyMansion/erect/stairsLight', 966, -225)
		addLuaSprite('stairs', true)
		setProperty('stairs.alpha', 0)
	end

	if flashingLights == true then
		makeLuaSprite('lightingFlash', '', -800, -400)
		makeGraphic('lightingFlash', screenWidth * 2, screenHeight * 2, 'FFFFFF')
		setScrollFactor('lightingFlash', 0, 0)
		setBlendMode('lightingFlash', 'ADD')
		addLuaSprite('lightingFlash', true)
		setProperty('lightingFlash.alpha', 0)
	end
	precacheSound('thunder_1')
	precacheSound('thunder_2')
end

function onCreatePost()
	if shadersEnabled == true then
        initLuaShader('rain')
        setSpriteShader('outdoorTrees', 'rain')
        setShaderFloat('outdoorTrees', 'uScale', screenHeight / 200 * 2)
        setShaderFloat('outdoorTrees', 'uIntensity', 0.4)
        setShaderBool('outdoorTrees', 'uSpriteMode', true)
		setShaderFloatArray('outdoorTrees', 'uRainColor', {102 / 255, 128 / 255, 204 / 255})

		-- Need to set up those, or the rain will freak out completely
		setShaderFloatArray('outdoorTrees', 'uScreenResolution', {screenWidth, screenHeight})
		setShaderFloatArray('outdoorTrees', 'uCameraBounds', {0, 0, screenWidth, screenHeight})
    end

	--[[
		This is to make the stage usable with other characters that don't have their dark varient.
		Go see the scripts for 'bf-dark', 'spooky-dark', and 'gf-dark' to see how they work,
		and use it for other characters that have dark varients (like Pico for example).
	]]
	for i, character in ipairs({'boyfriend', 'dad', 'gf'}) do
		if not stringEndsWith(_G[character..'Name'], '-dark') then
			setProperty(character..'.color', 0x070711)
		end
	end
end

local elapsedTime = 0
function onUpdate(elapsed)
	-- Makes the rain active.
    if shadersEnabled == true then
        elapsedTime = elapsedTime + elapsed
		setShaderFloat('outdoorTrees', 'uTime', elapsedTime)
		setShaderFloatArray('outdoorTrees', 'uFrameBounds', {getProperty('outdoorTrees.frame.uv.x'), getProperty('outdoorTrees.frame.uv.y'), getProperty('outdoorTrees.frame.uv.width'), getProperty('outdoorTrees.frame.uv.height')})
    end
end

-- All of this down below is to make the mechanics of the stage work. 
lastLightningStrike = 0
lightningInterval = 8
function onBeatHit()
	if getRandomBool(10) and curBeat > lastLightningStrike + lightningInterval then
		strikeLighting(curBeat)
	end
end

-- This is the function that makes the lighting strike and affect the background and characters.
function strikeLighting(beatHit)
	lastLightningStrike = beatHit
	lightningInterval = getRandomInt(8, 24)
	local soundNum = getRandomInt(1, 2)
	playSound('thunder_'..soundNum)
	
	if flashingLights == true then
		setProperty('lightingFlash.alpha', 0.4)
		doTweenAlpha('flashAlphaTween', 'lightingFlash', 0.5, 0.075, 'linear')
		runTimer('delayFlashAphaBack', 0.15)
	end

	if lowQuality == false then
		for i, stageObject in ipairs({'corridor', 'stairs'}) do
			setProperty(stageObject..'.alpha', 1)
		end
		for i, character in ipairs({'boyfriend', 'dad', 'gf'}) do
			if stringEndsWith(_G[character..'Name'], '-dark') then
				setProperty(character..'.alpha', 0)
			else
				-- Support for non '-dark' varients
				setProperty(character..'.color', 0xFFFFFF)
			end
		end
		runTimer('delayLightingBack', 0.06)
		runTimer('startLightingBack', 0.12)
	end

	if cameraZoomOnBeat == true then
		setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.015)
		setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03)

		if getProperty('camZooming') == false then
			doTweenZoom('zoomBack', 'camGame', getProperty('defaultCamZoom'), 0.5, 'linear')
			doTweenZoom('zoomBackHUD', 'camHUD', 1, 0.5, 'linear')
		end
	end

	playAnim('boyfriend', 'scared', true)
	playAnim('gf', 'scared', true)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'delayFlashAphaBack' then
		doTweenAlpha('flashAphaBack', 'lightingFlash', 0, 0.25, 'linear')
	end
	if tag == 'delayLightingBack' then
		for i, stageLightingt in ipairs({'corridor', 'stairs'}) do
			setProperty(stageObject..'.alpha', 0)
		end
		for i, character in ipairs({'boyfriend', 'dad', 'gf'}) do
			if stringEndsWith(_G[character..'Name'], '-dark') then
				setProperty(character..'.alpha', 1)
			else
				-- Support for non '-dark' varients
				setProperty(character..'.color', 0x070711)
			end
		end
	end
	if tag == 'startLightingBack' then
		for i, stageObject in ipairs({'corridor', 'stairs'}) do
			setProperty(stageObject..'.alpha', 1)
			doTweenAlpha(stageObject..'alphaBack', stageObject, 0, 1.5, 'linear')
		end
		for i, character in ipairs({'boyfriend', 'dad', 'gf'}) do
			if stringEndsWith(_G[character..'Name'], '-dark') then
				setProperty(character..'.alpha', 0)
				doTweenAlpha(character..'alphaBack', character, 1, 1.5, 'linear')
			else
				-- Support for non '-dark' varients
				setProperty(character..'.color', 0xFFFFFF)
				doTweenColor(character..'colorBack', character, '070711', 1.5, 'linear')
			end
		end
	end
end