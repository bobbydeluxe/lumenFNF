--[[Recreation by Gostar64 [Probably doesn't work on android]
	Works on Psych Engine 0.7.3 [And maybe some older versions]
	Don't remove this credit thing or I'll be sad Ex: [:(]

	Also this is based off of Super_Hugo's Philly Glow Recreation
]]
local extraData = {
	spotlightColor = 0xFFFFFF,
	boyfriendSpotlightOffset = {x = 0, y = 0},
	dadSpotlightOffset = {x = 0, y = 0},
	gfSpotlightOffset = {x = 0, y = 0},
	smokeOffset = {x = 0, y = 0}
}
function onCreate()
	--[[
		Example code (copy, paste and change the values):
		if curStage == 'mallErect' then
			extraData.boyfriendSpotlightOffset.x = 450
			extraData.boyfriendSpotlightOffset.y = 150

			extraData.spotlightColor = 0xE62145

			extraData.smokeOffset.x = 1050
			extraData.smokeOffset.y = -300
		end
	]]
end

function onCreatePost()
	-- Sets up the sprites for the 'Dadbattle Spotlight' event if it's present in the chart.
	makeLuaSprite('blackenScreen', '', -800, -400)
	makeGraphic('blackenScreen', screenWidth * 2, screenHeight * 2, '000000')
	setScrollFactor('blackenScreen', 0, 0)
	addLuaSprite('blackenScreen', true)
	setProperty('blackenScreen.alpha', 0.25)
	setProperty('blackenScreen.visible', false)
			
    makeLuaSprite('spotlight', 'mainStage/spotlight', 400, -400)
	setBlendMode('spotlight', 'ADD')
	addLuaSprite('spotlight', true)
	setProperty('spotlight.color', extraData.spotlightColor)
	setProperty('spotlight.alpha', 0)
	setProperty('spotlight.visible', false)
			
	smoke1OffsetX = extraData.smokeOffset.x
	smoke1OffsetY = getRandomFloat(-15, 15) + extraData.smokeOffset.y
	smoke1Scale = getRandomFloat(1.1, 1.22)
	smoke1Velocity = getRandomFloat(15, 22)
	makeLuaSprite('smoke1', 'mainStage/smoke', -1650 + smoke1OffsetX, 680 + smoke1OffsetY)
	setGraphicSize('smoke1', getProperty('smoke1.width') * smoke1Scale)
	setScrollFactor('smoke1', 1.2, 1.05)
	addLuaSprite('smoke1', true)
	setProperty('smoke1.alpha', 0)
	setProperty('smoke1.velocity.x', smoke1Velocity)

	smoke2OffsetX = extraData.smokeOffset.x
	smoke2OffsetY = getRandomFloat(-15, 15) + extraData.smokeOffset.y
	smoke2Scale = getRandomFloat(1.1, 1.22)
	smoke2Velocity = getRandomFloat(-22, -15)
	makeLuaSprite('smoke2', 'mainStage/smoke', 1850 - smoke2OffsetX, 680 + smoke2OffsetY)
	setGraphicSize('smoke2', getProperty('smoke2.width') * smoke2Scale)
	setScrollFactor('smoke2', 1.2, 1.05)
	addLuaSprite('smoke2', true)
	setProperty('smoke2.alpha', 0)
	setProperty('smoke2.flipX', true)
	setProperty('smoke2.velocity.x', smoke2Velocity)
end

function onEvent(eventName, value1, value2, strumTime)
	if eventName == 'Dadbattle Spotlight' then
		value = tonumber(value1)
		if value == nil then
			value = 0
		end
		
		if value > 0 then
			if value == 1 then -- Activates the event
				setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.12)
				setProperty('blackenScreen.visible', true)
				setProperty('spotlight.visible', true)
				setProperty('smoke1.visible', true)
				setProperty('smoke2.visible', true)
			end

			-- Sets up the spotlight's target and offsets
			local target = 'dad'
			local spotlightOffset = {x = 0, y = 0}
			if value == 2 then
				target = 'dad'
				spotlightOffset.x = extraData.dadSpotlightOffset.x
				spotlightOffset.y = extraData.dadSpotlightOffset.y
			elseif value == 3 then
				target = 'boyfriend'
				spotlightOffset.x = extraData.boyfriendSpotlightOffset.x
				spotlightOffset.y = extraData.boyfriendSpotlightOffset.y
			elseif value == 4 then
				target = 'gf'
				spotlightOffset.x = extraData.gfSpotlightOffset.x
				spotlightOffset.y = extraData.gfSpotlightOffset.y
			end
			runTimer('spotlightAppears', 0.12)
			setProperty('spotlight.x', getGraphicMidpointX(target) - getProperty('spotlight.width') / 2 + spotlightOffset.x)
			setProperty('spotlight.y', getProperty(target..'.y') + getProperty(target..'.height') - getProperty('spotlight.height') + 50 + spotlightOffset.y)
			doTweenAlpha('smoke1Appears', 'smoke1', 0.7, 1.5, 'quadInOut')
			doTweenAlpha('smoke2Appears', 'smoke2', 0.7, 1.5, 'quadInOut')
		else
			-- Deactivates the event
			setProperty('defaultCamZoom', getProperty('defaultCamZoom') - 0.12)
			setProperty('blackenScreen.visible', false)
			setProperty('spotlight.visible', false)
			doTweenAlpha('smoke1ByeBye', 'smoke1', 0, 0.7, 'linear')
			doTweenAlpha('smoke2ByeBye', 'smoke2', 0, 0.7, 'linear')
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'spotlightAppears' then
		setProperty('spotlight.alpha', 0.375)
	end
end