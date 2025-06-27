function onCreate()
	makeLuaSprite('sunset', 'limo/limoSunset', -220, -80)
	scaleObject('sunset', 0.9, 0.9)
	setScrollFactor('sunset', 0.1, 0.1)
	addLuaSprite('sunset')

	if lowQuality == false then
		makeAnimatedLuaSprite('limoBG', 'limo/bgLimo', -200, 480)
		addAnimationByPrefix('limoBG', 'anim', 'background limo pink')
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
	
	makeAnimatedLuaSprite('limo', 'limo/limoDrive', -120, 520)
	addAnimationByPrefix('limo', 'anim', 'Limo stage')
	setObjectOrder('limo', getObjectOrder('gfGroup') + 1) -- For those like me who want GF behind the limo, unlike Shadow Mario does
	addLuaSprite('limo')
end

function onCreatePost()
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

				precacheSound('dancerdeath')
			end
		end
	end
end

local elapsedTime = 0

-- Event stuff
function onUpdatePost(elapsed)
	updateKillingState(elapsed)
	updateHenchmenParticles()
end

-- All of this down below is to make the mechanics of the stage work. 
henchmenDanced = true
carCanDrive = true
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

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'carReset' then
		resetCar()
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