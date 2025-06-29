function onCreate()
	makeLuaSprite('mallWall', 'christmas/bgWalls', -1000, -500)
	scaleObject('mallWall', 0.9, 0.9)
	setScrollFactor('mallWall', 0.2, 0.2)
	addLuaSprite('mallWall')

	if lowQuality == false then
		makeAnimatedLuaSprite('topBoppers', 'christmas/upperBop', -240, -90)
		addAnimationByPrefix('topBoppers', 'idle', 'Upper Crowd Bob', 24, false)
		scaleObject('topBoppers', 0.85, 0.85)
		setScrollFactor('topBoppers', 0.33, 0.33)
		addLuaSprite('topBoppers')

		makeLuaSprite('escalators', 'christmas/bgEscalator', -1100, -600)
		scaleObject('escalators', 0.9, 0.9)
		setScrollFactor('escalators', 0.3, 0.3)
		addLuaSprite('escalators')
	end

	makeLuaSprite('christmasTree', 'christmas/christmasTree', 370, -250)
	setScrollFactor('christmasTree', 0.4, 0.4)
	addLuaSprite('christmasTree')

	if lowQuality == false then
		makeLuaSprite('fog', 'christmas/white', -1000, 100)
		scaleObject('fog', 0.9, 0.9)
		setScrollFactor('fog', 0.85, 0.85)
		addLuaSprite('fog')
	end

	makeAnimatedLuaSprite('bottomBoppers', 'christmas/bottomBop', -300, 140)
	addAnimationByPrefix('bottomBoppers', 'idle', 'Bottom Level Boppers Idle', 24, false)
	addAnimationByPrefix('bottomBoppers', 'hey', 'Bottom Level Boppers HEY', 24, false)
	setScrollFactor('bottomBoppers', 0.9, 0.9)
	addLuaSprite('bottomBoppers')

	makeLuaSprite('snowGround', 'christmas/fgSnow', -600, 700)
	addLuaSprite('snowGround')

	makeAnimatedLuaSprite('santa', 'christmas/santa', -840, 150)
	addAnimationByPrefix('santa', 'idle', 'santa idle in fear', 24, false)
	addLuaSprite('santa')
end

local heyTimer = 0
function onCountdownTick(swagCounter)
	if lowQuality == false then
		playAnim('topBoppers', 'idle', true)
	end
	if heyTimer <= 0 then
		playAnim('bottomBoppers', 'idle', true)
	end
	playAnim('santa', 'idle', true)
end

function onBeatHit()
	if lowQuality == false then
		playAnim('topBoppers', 'idle', true)
	end
	if heyTimer <= 0 then
		playAnim('bottomBoppers', 'idle', true)
	end
	playAnim('santa', 'idle', true)
end

function onEvent(name, value1, value2)
	if name == 'Hey!' then
		value1 = tonumber(value1)
		if value1 == nil then
			value1 = 0
		end

		value2 = tonumber(value2)
		if value2 == nil then
			value2 = 0.6
		end

		if value1 ~= 0 then
			playAnim('bottomBoppers', 'hey', true)
			heyTimer = value2
		end
	end
end

function onUpdate(elapsed)
	if heyTimer > 0 then
		heyTimer = heyTimer - elapsed
		if heyTimer <= 0 then
			playAnim('bottomBoppers', 'idle', true)
			heyTimer = 0
		end
	end
end