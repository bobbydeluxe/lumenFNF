function onCreate()
	if lowQuality == false then
		makeLuaSprite('sky', 'philly/sky', -100, 0)
		setScrollFactor('sky', 0.1, 0.1)
		addLuaSprite('sky')
	end

	makeLuaSprite('city', 'philly/city', -10, 0)
	scaleObject('city', 0.85, 0.85)
	setScrollFactor('city', 0.3, 0.3)
	addLuaSprite('city')

	makeLuaSprite('window', 'philly/window', -10, 0)
	scaleObject('window', 0.85, 0.85)
	setScrollFactor('window', 0.3, 0.3)
	addLuaSprite('window')
	setProperty('window.alpha', 0)

	if lowQuality == false then
		makeLuaSprite('behindTrain', 'philly/behindTrain', -40, 50)
		addLuaSprite('behindTrain')
	end

	makeLuaSprite('train', 'philly/train', 2000, 360)
	addLuaSprite('train')
	precacheSound('train_passes')

	makeLuaSprite('street', 'philly/street', -40, 50)
	addLuaSprite('street')
end

function onCreatePost()
	-- Sets up the sprites for the 'Philly Glow' event if it's present in the chart.
	for note = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', note, 'event') == 'Philly Glow' then
			makeLuaSprite('blackenScreen', '', screenWidth * -0.5, screenHeight * -0.5)
			makeGraphic('blackenScreen', screenWidth * 2, screenHeight * 2, '000000')
			setObjectOrder('blackenScreen', getObjectOrder('street'))
			addLuaSprite('blackenScreen')
			setProperty('blackenScreen.visible', false)

			makeLuaSprite('windowEvent', 'philly/window', -10, 0)
			setGraphicSize('windowEvent', getProperty('windowEvent.width') * 0.85)
			setScrollFactor('windowEvent', 0.3, 0.3)
			setObjectOrder('windowEvent', getObjectOrder('blackenScreen') + 1)
			addLuaSprite('windowEvent')
			setProperty('windowEvent.visible', false)

			makeLuaSprite('gradient', 'philly/gradient', -400, 225)
			setGraphicSize('gradient', 2000, 400)
			setScrollFactor('gradient', 0, 0.75)
			setObjectOrder('gradient', getObjectOrder('windowEvent') + 1)
			addLuaSprite('gradient')
			setProperty('gradient.visible', false)
			if flashingLights == false then
				setProperty('gradient.alpha', 0.7)
			end
			
			phillyGlowParticles = {}
			precacheImage('philly/particle')
			windowsEventColors = {
				'31A2FD',
				'31FD8C',
				'FB33F5',
				'FD4531',
				'FBA633'
			}
			-- Custom color variables because we can't change certain properties through Lua.
			streetColors = { -- * 0.5 Brightness
				0x025497,
				0x029745,
				0x960391,
				0x971102,
				0x965903
			}
			if flashingLights == false then
				charactersColors = { -- * 0.5 Saturation
					0x639CCA,
					0x63CA91,
					0xC964C5,
					0xCA6D63,
					0xC99F64
				}
			else
				charactersColors = { -- * 0.75 Saturation
					0x499EE4,
					0x49E48F,
					0xE24BDD,
					0xE45949,
					0xE2A34B
				}
			end
        end
    end
end

-- All of this down below is to make the mechanics of the stage work. 
windowsColors = {
	0x31A2FD,
	0x31FD8C,
	0xFB33F5,
	0xFD4531,
	0xFBA633
}

isTrainMoving = false
trainFrameTiming = 0
startedMoving = false

trainCars = 8
isTrainFinished = false
trainCooldown = 0

function onUpdate(elapsed)
	if isTrainMoving == true then
		trainFrameTiming = trainFrameTiming + elapsed

		if trainFrameTiming >= 1 / 24 then
			updateTrainPos()
			trainFrameTiming = 0
		end
	end
	setProperty('window.alpha', getProperty('window.alpha') - (crochet / 1000) * elapsed * 1.5)
	updateFlash(elapsed)
	updateGradient(elapsed)
	updateParticles(elapsed)
end

function onBeatHit()
	if isTrainMoving == false then
		trainCooldown = trainCooldown + 1
	end

	if curBeat % 4 == 0 then
		local selectedColor = getRandomInt(1, #windowsColors)
		setProperty('window.alpha', 1)
		setProperty('window.color', windowsColors[selectedColor])
	end
	
	if curBeat % 8 == 4 and getRandomBool(30) and isTrainMoving == false and trainCooldown > 8 then
		trainCooldown = getRandomInt(-4, 0)
		trainStart()
	end
end

-- Makes the train start moving
function trainStart()
	isTrainMoving = true
	playSound('train_passes', 1, 'trainSound')
end

-- Updates the train's "animation" and blows GF's hair
function updateTrainPos()
	if getSoundTime('trainSound') >= 4700 then
		startedMoving = true
		playAnim('gf', 'hairBlow')
		setProperty('gf.specialAnim', true)
	end

	if startedMoving == true then
		setProperty('train.x', getProperty('train.x') - 400)
		if getProperty('train.x') < -2000 and isTrainFinished == false then
			setProperty('train.x', -1150)
			trainCars = trainCars - 1

			if trainCars <= 0 then
				isTrainFinished = true
			end
		end
		if getProperty('train.x') - 400 < -4000 and isTrainFinished == true then
			trainReset()
		end
	end
end

-- Resets the train position and stops GF's blowing hair
function trainReset()
	isTrainMoving = false
	trainCars = 8
	isTrainFinished = false
	startedMoving = false
	setProperty('train.x', screenWidth + 200)

	setProperty('gf.danced', false)
	playAnim('gf', 'hairFall')
	setProperty('gf.specialAnim', true)
end

-- Everything from this point is for the 'Philly Glow' event
function onEvent(eventName, value1, value2, strumTime)
	if eventName == 'Philly Glow' then
		if value1 == '0' then -- Deactivates the event.
			if getProperty('gradient.visible') == true then
				if flashingLights == false then
					doFlash('FFFFFF', 0.15, 0.5, true)
				else
					doFlash('FFFFFF', 0.15, 1, true)
				end

				if cameraZoomOnBeat == true then
					setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.5)
					setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.1)
				end

				setProperty('blackenScreen.visible', false)
				setProperty('windowEvent.visible', false)
				setProperty('gradient.visible', false)
				for num = 1, particles do
					if luaSpriteExists('particle'..num) then
						removeLuaSprite('particle'..num)
					end
					particles = particles - 1
					phillyGlowParticles[num] = nil
				end
				
				setProperty('street.color', 0xFFFFFF)
				for i, object in ipairs({'boyfriend', 'dad', 'gf'}) do
					setProperty(object..'.color', 0xFFFFFF)
				end
			end
		elseif value1 == '1' then -- Activates the event, and/or chooses a random color.
			selectedColor = getRandomInt(1, #windowsEventColors)

			if getProperty('gradient.visible') == false then
				if flashingLights == false then
					doFlash('FFFFFF', 0.15, 0.5, true)
				else
					doFlash('FFFFFF', 0.15, 1, true)
				end

				if cameraZoomOnBeat == true then
					setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.5)
					setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.1)
				end

				setProperty('blackenScreen.visible', true)
				setProperty('windowEvent.visible', true)
				setProperty('gradient.visible', true)
			elseif flashingLights == true then
				doFlash(windowsEventColors[selectedColor], 0.5, 0.25, true)
			end

			setProperty('windowEvent.color', getColorFromHex(windowsEventColors[selectedColor]))
			setProperty('gradient.color', getColorFromHex(windowsEventColors[selectedColor]))
			for num = 1, particles do
				setProperty('particle'..num..'.color', getColorFromHex(windowsEventColors[selectedColor]))
			end

			setProperty('street.color', streetColors[selectedColor])
			for i, object in ipairs({'boyfriend', 'dad', 'gf'}) do
				setProperty(object..'.color', charactersColors[selectedColor])
			end
		elseif value1 == '2' then -- Resets gradient, and creates new particles
			if lowQuality == false then
				particlesNum = getRandomInt(8, 12)
				particleWidth = 2000 / particlesNum
				for y = 1, 3 do
					for x = 1, particlesNum do
						offsetX = getRandomFloat(-particleWidth / 5, particleWidth / 5)
						offsetY = getRandomFloat(0, 125)
						createParticle(-400 + particleWidth * x + offsetX, 425 + (offsetY + y * 40), getColorFromHex(windowsEventColors[selectedColor]))
					end
				end
			end
			setGraphicSize('gradient', 2000, 400)
			setProperty('gradient.y', 225)
			if flashingLights == false then
				setProperty('gradient.alpha', 0.7)
			else
				setProperty('gradient.alpha', 1)
			end
		end
	end
end

-- When you have to create a custom flash function because you can't do it by normal means on Lua. 
local flashDuration = 0
function doFlash(color, duration, startAlpha, forced)
	if forced == false and getProperty('flash.alpha') > 0 then
		return nil
	end
	if duration == 0 then
		duration = 0.000001
	end
	makeLuaSprite('flash', '', screenWidth * -0.5, screenHeight * -0.5)
	makeGraphic('flash', screenWidth * 2, screenHeight * 2, color)
	addLuaSprite('flash', true)
	setProperty('flash.alpha', startAlpha)
	flashDuration = duration / startAlpha
end

-- Creates the particles when the gradient resets.
particles = 0
function createParticle(x, y, color)
	particles = particles + 1
	local lifeTime = getRandomFloat(0.6, 0.9)
	local decay = getRandomFloat(0.8, 1)
	local scale = getRandomFloat(0.75, 1)
	scrollFactor = {x = getRandomFloat(0.3, 0.75), y = getRandomFloat(0.65, 0.75)}
	velocity = {x = getRandomFloat(-40, 40), y = getRandomFloat(-175, -250)}
	acceleration = getRandomFloat(-10, 10)

	makeLuaSprite('particle'..particles, 'philly/particle', x, y)
	scaleObject('particle'..particles, scale, scale)
	setScrollFactor('particle'..particles, scrollFactor.x, scrollFactor.y)
	setObjectOrder('particle'..particles, getObjectOrder('gradient') + 1)
	addLuaSprite('particle'..particles)
	setProperty('particle'..particles..'.color', color)
	setProperty('particle'..particles..'.velocity.x', velocity.x)
	setProperty('particle'..particles..'.velocity.y', velocity.y)
	setProperty('particle'..particles..'.acceleration.x', acceleration)
	setProperty('particle'..particles..'.acceleration.y', 25)
	if flashingLights == false then
		setProperty('particle'..particles..'.alpha', 0.5)
		decay = decay * 0.5
	end

	phillyGlowParticles[particles] = {lifeTime = lifeTime, decay = decay, scale = scale}
end

-- Updates the custom flash animation
function updateFlash(elapsed)
	if luaSpriteExists('flash') then
		if getProperty('flash.alpha') > 0 then
			setProperty('flash.alpha', getProperty('flash.alpha') - (elapsed / flashDuration))
		else
			removeLuaSprite('flash')
		end
	end
end

-- Makes the gradient shrink overtime.
function updateGradient(elapsed)
	curHeight = math.round(getProperty('gradient.height') - 1000 * elapsed)
	if curHeight > 0 then
		setGraphicSize('gradient', 2000, curHeight)
		setProperty('gradient.y', 225 + (400 - getProperty('gradient.height')))
		if flashingLights == false then
			setProperty('gradient.alpha', 0.7)
		else
			setProperty('gradient.alpha', 1)
		end
	else
		setProperty('gradient.alpha', 0)
		setProperty('gradient.y', -5000)
	end
end

-- Updates the particles and removes them overtime.
function updateParticles(elapsed)
	for num = 1, particles do
		if luaSpriteExists('particle'..num) then
			phillyGlowParticles[num].lifeTime = phillyGlowParticles[num].lifeTime - elapsed
			local lifeTime = phillyGlowParticles[num].lifeTime
			local decay = phillyGlowParticles[num].decay
			local scale = phillyGlowParticles[num].scale

			if lifeTime < 0 then
				phillyGlowParticles[num].lifeTime = 0
				setProperty('particle'..num..'.alpha', getProperty('particle'..num..'.alpha') - decay * elapsed)
				if getProperty('particle'..num..'.alpha') > 0 then
					scaleObject('particle'..num, scale * getProperty('particle'..num..'.alpha'), scale * getProperty('particle'..num..'.alpha'))
				else
					removeLuaSprite('particle'..num)
				end
			end
		end
	end
end

function math.round(num)
	if num % 1 < 0.5 then
		return math.floor(num)
	else
		return math.ceil(num)
	end
end