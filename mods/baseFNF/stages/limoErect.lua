function onCreate()
	makeLuaSprite('sunset', 'limo/erect/limoSunset', -220, -80)
	scaleObject('sunset', 0.9, 0.9)
	setScrollFactor('sunset', 0.1, 0.1)
	addLuaSprite('sunset')

	makeAnimatedLuaSprite('shootingStar', 'limo/erect/shooting star', 200, 0)
	addAnimationByPrefix('shootingStar', 'anim', 'shooting star', 24, false)
	setScrollFactor('shootingStar', 0.12, 0.12)
	setBlendMode('shootingStar', 'ADD')
	addLuaSprite('shootingStar')
	setProperty('shootingStar.visible', false)

	if lowQuality == false then
		makeAnimatedLuaSprite('limoBG', 'limo/erect/bgLimo', -200, 480)
		addAnimationByPrefix('limoBG', 'anim', 'background limo blue')
		setScrollFactor('limoBG', 0.4, 0.4)
		addLuaSprite('limoBG')

		for i = 1, 5 do
			makeAnimatedLuaSprite('henchmen'..i, 'limo/limoDancer', getProperty('limoBG.x') + 300 * i, 100)
			addAnimationByIndices('henchmen'..i, 'danceLeft', 'bg dancer sketch PINK', '0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14')
			addAnimationByIndices('henchmen'..i, 'danceRight', 'bg dancer sketch PINK', '15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29')
			setScrollFactor('henchmen'..i, 0.4, 0.4)
			addLuaSprite('henchmen'..i)
			playAnim('henchmen'..i, 'danceLeft')
		end
	end
	
	makeLuaSprite('car', 'limo/fastCarLol', -12600, 160)
	addLuaSprite('car')
	precacheSound('carPass0')
	precacheSound('carPass1')
	
	makeAnimatedLuaSprite('limo', 'limo/erect/limoDrive', -120, 520)
	addAnimationByPrefix('limo', 'anim', 'Limo stage')
	setObjectOrder('limo', getObjectOrder('gfGroup') + 1) -- For those like me who want GF behind the limo, unlike Shadow Mario does
	addLuaSprite('limo')
end

function onCreatePost()
	createInstance('colorShader', 'shaders.AdjustColorScreenspace')
	runHaxeCode([[
		getVar('colorShader').setAdjustColor(-30, -20, -30, 0);
		getVar('colorShader').threshold = 1;
		game.dad.shader = getVar('colorShader');
		game.boyfriend.shader = getVar('colorShader');
		game.gf.shader = getVar('colorShader');
	]])

	for i = 1, 5 do
		setProperty('henchmen'..i..'.shader', instanceArg('colorShader'), nil, true)
	end

	if lowQuality == false then
        mistData = {
            {mistImage = 'mistMid', scrollFactor = 1.1, alpha = 0.4, velocity = 1700, scale = 1.3, objectOrder = '', color = 0xC6BFDE},
            {mistImage = 'mistBack', scrollFactor = 1.2, alpha = 1, velocity = 2100, scale = 1, objectOrder = 'mist13', color = 0x6A4DA1},
            {mistImage = 'mistMid', scrollFactor = 0.8, alpha = 0.5, velocity = 900, scale = 1.5, objectOrder = 'henchmen5', color = 0xA7D9BE},
            {mistImage = 'mistBack', scrollFactor = 0.6, alpha = 1, velocity = 700, scale = 1.5, objectOrder = 'mist33', color = 0x9C77C7},
            {mistImage = 'mistMid', scrollFactor = 0.2, alpha = 1, velocity = 100, scale = 1.5, objectOrder = 'sunset', color = 0xE7A480},
        }
        for mistNum, data in ipairs(mistData) do
            for i = 0, 2 do
                makeLuaSprite('mist'..mistNum..''..(i + 1), 'limo/erect/'..data.mistImage, -650, -100)
                scaleObject('mist'..mistNum..''..(i + 1), data.scale, data.scale, false)
                setScrollFactor('mist'..mistNum..''..(i + 1), data.scrollFactor, data.scrollFactor)
                setBlendMode('mist'..mistNum..''..(i + 1), 'ADD')
                if data.objectOrder ~= '' then
                    setObjectOrder('mist'..mistNum..''..(i + 1), getObjectOrder(data.objectOrder) + 1)
                end
                addLuaSprite('mist'..mistNum..''..(i + 1), true)
                setProperty('mist'..mistNum..''..(i + 1)..'.alpha', data.alpha)
                setProperty('mist'..mistNum..''..(i + 1)..'.color', data.color)
                setProperty('mist'..mistNum..''..(i + 1)..'.velocity.x', data.velocity)
                local offsetMist = getProperty('mist'..mistNum..''..(i + 1)..'.x') + (getProperty('mist'..mistNum..''..(i + 1)..'.width') * data.scale) * i
                setProperty('mist'..mistNum..''..(i + 1)..'.x', offsetMist)
            end
        end
    end

	-- Sets up the sprites for the 'Kill Henchmen' event if it's present in the chart.
	for note = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', note, 'event') == 'Kill Henchmen' then
			if lowQuality == false then
				makeLuaSprite('lightPole', 'gore/metalPole', -500, 220)
				setScrollFactor('lightPole', 0.4, 0.4)
				setObjectOrder('lightPole', getObjectOrder('limoBG'))
				addLuaSprite('lightPole')
				setProperty('lightPole.visible', false)

				makeAnimatedLuaSprite('henchmenCorpse1', 'gore/noooooo', -500, getProperty('lightPole.y') - 130)
				addAnimationByPrefix('henchmenCorpse1', 'anim', 'Henchmen on rail')
				setScrollFactor('henchmenCorpse1', 0.4, 0.4)
				setObjectOrder('henchmenCorpse1', getObjectOrder('henchmen1'))
				addLuaSprite('henchmenCorpse1')
				setProperty('henchmenCorpse1.visible', false)

				makeAnimatedLuaSprite('henchmenCorpse2', 'gore/noooooo', -500, getProperty('lightPole.y'))
				addAnimationByPrefix('henchmenCorpse2', 'anim', 'henchmen death')
				setScrollFactor('henchmenCorpse2', 0.4, 0.4)
				setObjectOrder('henchmenCorpse2', getObjectOrder('henchmen1'))
				addLuaSprite('henchmenCorpse2')
				setProperty('henchmenCorpse2.visible', false)

				makeLuaSprite('light', 'gore/coldHeartKiller', getProperty('lightPole.x') - 180, getProperty('lightPole.y') - 80)
				setScrollFactor('light', 0.4, 0.4)
				setObjectOrder('light', getObjectOrder('henchmen5') + 1)
				addLuaSprite('light')
				setProperty('light.visible', false)

				-- This acts as a precache, it will never be actually used
				makeAnimatedLuaSprite('henchmenBlood', 'gore/stupidBlood', -400, -400)
				addAnimationByPrefix('henchmenBlood', 'anim', 'blood', 24, false)
				setScrollFactor('henchmenBlood', 0.4, 0.4)
				setObjectOrder('henchmenBlood', getObjectOrder('henchmen5'))
				addLuaSprite('henchmenBlood')
				setProperty('henchmenBlood.alpha', 0.01)

				setProperty('lightPole.shader', instanceArg('colorShader'), nil, true)
				setProperty('light.shader', instanceArg('colorShader'), nil, true)
				setProperty('henchmenCorpse1.shader', instanceArg('colorShader'), nil, true)
				setProperty('henchmenCorpse2.shader', instanceArg('colorShader'), nil, true)

				precacheSound('dancerdeath')
			end
		end
	end
end

local elapsedTime = 0
function onUpdate(elapsed)
	--[[
        Everything here controls the movement of the fog around the stage.
        3 'mist' sprites of the same placement follow along one another 
        until one of them gets too far to the left or right, and so then get behind the pack.
        Also, all of them do an up and down motion depending of their set values.
    ]]
	if lowQuality == false then
		for mistNum, mistScale in ipairs({1.3, 1, 1.5, 1.5, 1.5}) do
			for i = 1, 3 do
				if getProperty('mist'..mistNum..''..i..'.x') > (getProperty('mist'..mistNum..''..i..'.width') * mistScale) * 1.5 then
					setProperty('mist'..mistNum..''..i..'.x', getProperty('mist'..mistNum..''..i..'.x') - (getProperty('mist'..mistNum..''..i..'.width') * mistScale) * 3)
				end
			end
		end
		elapsedTime = elapsedTime + elapsed
		for i = 1, 3 do
			setProperty('mist1'..i..'.y', 100 + (math.sin(elapsedTime) * 200))
			setProperty('mist2'..i..'.y', 0 + (math.sin(elapsedTime * 0.8) * 100))
			setProperty('mist3'..i..'.y', -20 + (math.sin(elapsedTime * 0.5) * 200))
			setProperty('mist4'..i..'.y', -180 + (math.sin(elapsedTime * 0.4) * 300))
			setProperty('mist5'..i..'.y', -450 + (math.sin(elapsedTime * 0.2) * 150))
		end
	end
end

-- Event stuff
function onUpdatePost(elapsed)
	updateKillingState(elapsed)
	updateHenchmenParticles()
end

-- All of this down below is to make the mechanics of the stage work. 
henchmenDanced = true
carCanDrive = true
lastShootingStar = 0
shootingStarInterval = 2
function onBeatHit()
	if lowQuality == false then
		henchmenDanced = not henchmenDanced
		if henchmenDanced == true then
			for i = 1, 5 do
				playAnim('henchmen'..i, 'danceLeft', true)
			end
		else
			for i = 1, 5 do
				playAnim('henchmen'..i, 'danceRight', true)
			end
		end
	end

	if getRandomBool(10) and carCanDrive == true then
		carDrive()
	end

	if getRandomBool(10) and curBeat > lastShootingStar + shootingStarInterval then
		shootingStarAppear(curBeat)
	end
end

-- Resets the car position
function resetCar()
	local carPosY = getRandomInt(140, 250)
	setProperty('car.x', -12600)
	setProperty('car.y', carPosY)
	setProperty('car.velocity.x', 0)
	carCanDrive = true
end

-- Moves the car from left to right with a random velocity.
function carDrive()
	carCanDrive = false
	local soundNum = getRandomInt(0, 1)
	local carVelocity = getRandomInt(170, 220)
	playSound('carPass'..soundNum, 0.7)
	setProperty('car.velocity.x', (carVelocity / (1 / framerate)) * 3)
	runTimer('carReset', 2)
end

-- There's a shooting star! Make a wish!
function shootingStarAppear(beatHit)
	lastShootingStar = beatHit
	shootingStarInterval = getRandomInt(4, 8)
	local pos = {x = getRandomInt(50, 900), y = getRandomInt(-10, 20)}
	local flipX = getRandomBool(50)

	setProperty('shootingStar.x', pos.x)
	setProperty('shootingStar.y', pos.y)
	setProperty('shootingStar.flipX', flipX)
	playAnim('shootingStar', 'anim', true)

	-- Doing this because it freaks out sometimes for whatever reason if it's visible.
	setProperty('shootingStar.visible', true)
	runTimer('shootingStarReset', 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'carReset' then
		resetCar()
	end
	if tag == 'shootingStarReset' then
		setProperty('shootingStar.visible', false)
	end
end

-- Everything from this point is for the 'Kill Henchmen' event
function eventEarlyTrigger(eventName, value1, value2, strumTime)
	if name == 'Kill Henchmen' then
		return 280 -- Ensures that the sound plays on beat.
	end
end

function onEvent(eventName, value1, value2, strumTime)
	if eventName == 'Kill Henchmen' then
		killHenchmen()
	end
end

local curKillState = 0
local henchmenParticles = {}
local limoSpeed = 0
-- Activates the event.
function killHenchmen()
	if lowQuality == false then
		if curKillState == 0 then
			setProperty('lightPole.x', -400)
			setProperty('lightPole.visible', true)
			setProperty('light.visible', true)
			setProperty('henchmenCorpse1.visible', false)
			setProperty('henchmenCorpse2.visible', false)
			curKillState = 1
			--addAchievementScore('roadkill_enthusiast')
		end
	end
end

-- This function controls the events entirely, based on the 'curKillState'.
function updateKillingState(elapsed)
	if curKillState == 1 then -- Henchmen all die :(
		setProperty('lightPole.x', getProperty('lightPole.x') + 5000 * elapsed)
		setProperty('light.x', getProperty('lightPole.x') - 180)
		setProperty('henchmenCorpse1.x', getProperty('light.x') - 50)
		setProperty('henchmenCorpse2.x', getProperty('light.x') + 35)

		for henchmenNum = 1, 5 do
			if getProperty('henchmen'..henchmenNum..'.x') < screenWidth * 1.5 and getProperty('light.x') > -200 + 300 * henchmenNum then
				if henchmenNum == 1 then
					playSound('dancerdeath', 0.5)
				end
				if henchmenNum % 2 == 1 then
					if henchmenNum ~= 3 then
						animString = ' '
					else
						animString = ' 2 '
					end
					for limbNum, data in ipairs({{offsetX = 200, offsetY = 0, limbPart = 'leg'}, {offsetX = 160, offsetY = 200, limbPart = 'arm'}, {offsetX = 0, offsetY = 50, limbPart = 'head'}}) do
						henchmenLimbTag = 'henchmenLimb'..henchmenNum..''..limbNum
						makeAnimatedLuaSprite(henchmenLimbTag, 'gore/noooooo', getProperty('henchmen'..henchmenNum..'.x') + data.offsetX, getProperty('henchmen'..henchmenNum..'.y') + data.offsetY)
						addAnimationByPrefix(henchmenLimbTag, 'anim', 'hench '..data.limbPart..' spin'..animString..'PINK', 24, false)
						setScrollFactor(henchmenLimbTag, 0.4, 0.4)
						setObjectOrder(henchmenLimbTag, getObjectOrder('light'))
						addLuaSprite(henchmenLimbTag)
						henchmenParticles[#henchmenParticles + 1] = henchmenLimbTag
					end

					henchmenBloodTag = 'henchmenBlood'..henchmenNum
					makeAnimatedLuaSprite(henchmenBloodTag, 'gore/stupidBlood', getProperty('henchmen'..henchmenNum..'.x') - 110, getProperty('henchmen'..henchmenNum..'.y') + 20)
					addAnimationByPrefix(henchmenBloodTag, 'anim', 'blood', 24, false)
					setScrollFactor(henchmenBloodTag, 0.4, 0.4)
					setObjectOrder(henchmenBloodTag, getObjectOrder('light'))
					addLuaSprite(henchmenBloodTag)
					henchmenParticles[#henchmenParticles + 1] = henchmenBloodTag
				elseif henchmenNum == 2 then
					setProperty('henchmenCorpse1.visible', true)
				elseif henchmenNum == 4 then
					setProperty('henchmenCorpse2.visible', true)
				end

				if shadersEnabled == true then
					for i = 1, #henchmenParticles do
						if luaSpriteExists(henchmenParticles[i]) then
							setSpriteShader(henchmenParticles[i], 'adjustColorDX')
							setShaderFloat(henchmenParticles[i], 'hue', -30)
							setShaderFloat(henchmenParticles[i], 'saturation', -20)
							setShaderFloat(henchmenParticles[i], 'contrast', 0)
							setShaderFloat(henchmenParticles[i], 'brightness', -30)
						end
					end
				end
				setProperty('henchmen'..henchmenNum..'.x', getProperty('henchmen'..henchmenNum..'.x') + screenWidth * 2)
			end
		end

		if getProperty('lightPole.x') > screenWidth * 2 then
			for i, object in ipairs({'lightPole', 'light', 'henchmenCorpse1', 'henchmenCorpse2'}) do
				setProperty(object..'.x', -500)
				setProperty(object..'.visible', false)
			end
			limoSpeed = 800
			curKillState = 2
		end
	elseif curKillState == 2 then -- The limo starts to back track off-screen
		limoSpeed = limoSpeed - 4000 * elapsed
		setProperty('limoBG.x', getProperty('limoBG.x') - limoSpeed * elapsed)
		if getProperty('limoBG.x') > screenWidth * 1.5 then
			limoSpeed = 3000
			curKillState = 3
		end
	elseif curKillState == 3 then -- The limo comes back with new henchmen
		limoSpeed = limoSpeed - 2000 * elapsed
		if limoSpeed < 1000 then
			limoSpeed = 1000
		end

		setProperty('limoBG.x', getProperty('limoBG.x') - limoSpeed * elapsed)
		if getProperty('limoBG.x') < -275 then
			curKillState = 4
			limoSpeed = 800
		end
		
		for i = 1, 5 do
			setProperty('henchmen'..i..'.x', getProperty('limoBG.x') + 300 * i)
		end
	elseif curKillState == 4 then -- The limo and henchmen finally get back to their original positions.
		limoBGPosX = math.lerp(-200, getProperty('limoBG.x'), math.exp(-elapsed * 9))
		setProperty('limoBG.x', limoBGPosX)

		if math.round(getProperty('limoBG.x')) == -200 then
			setProperty('limoBG.x', -200)
			curKillState = 0
			henchmenParticles = {}
		end

		for i = 1, 5 do
			setProperty('henchmen'..i..'.x', getProperty('limoBG.x') + 300 * i)
		end
	end
end

-- This function is what makes the henchmen's body parts and blood dissapear once their animation is finished.
function updateHenchmenParticles()
	if lowQuality == false then
		for i = 1, #henchmenParticles do
			if luaSpriteExists(henchmenParticles[i]) then
				if getProperty(henchmenParticles[i]..'.animation.curAnim.finished') then
					removeLuaSprite(henchmenParticles[i])
				end
			end
		end
	end
end

function math.lerp(a, b, ratio)
	return a + ratio * (b - a)
end

function math.round(num)
	if num % 1 < 0.5 then
		return math.floor(num)
	else
		return math.ceil(num)
	end
end