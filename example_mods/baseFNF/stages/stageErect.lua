function onCreate()
	makeLuaSprite('darkBG', 'mainStage/erect/backDark', 729, -170)
	addLuaSprite('darkBG')

	makeAnimatedLuaSprite('crowd', 'mainStage/erect/crowd', 560, 290)
	addAnimationByPrefix('crowd', 'idle', 'Symbol 2 instance 1', 12)
	setScrollFactor('crowd', 0.8, 0.8)
	addLuaSprite('crowd')

	if lowQuality == false then
		makeLuaSprite('smallLight', 'mainStage/erect/brightLightSmall', 967, -103)
		setScrollFactor('smallLight', 1.2, 1.2)
		setBlendMode('smallLight', 'ADD')
		addLuaSprite('smallLight')
	end

	makeLuaSprite('backStage', 'mainStage/erect/bg', -603, -187)
	addLuaSprite('backStage')

	if lowQuality == false then
		makeLuaSprite('server', 'mainStage/erect/server', -361, 205)
		addLuaSprite('server')

		makeLuaSprite('greenServerLight', 'mainStage/erect/lightgreen', -171, 242)
		setBlendMode('greenServerLight', 'ADD')
		addLuaSprite('greenServerLight')

		makeLuaSprite('redServerLight', 'mainStage/erect/lightred', -101, 560)
		setObjectOrder('redServerLight', getObjectOrder('greenServerLight'))
		setBlendMode('redServerLight', 'ADD')
		addLuaSprite('redServerLight')
	end

	makeLuaSprite('orangeHue', 'mainStage/erect/orangeLight', 189, -195)
	setBlendMode('orangeHue', 'ADD')
	addLuaSprite('orangeHue')

	if lowQuality == false then
		makeLuaSprite('stageLights', 'mainStage/erect/lights', -601, -147)
		setScrollFactor('stageLights', 1.2, 1.2)
		addLuaSprite('stageLights', true)

		makeLuaSprite('light', 'mainStage/erect/lightAbove', 804, -117)
		setBlendMode('light', 'ADD')
		addLuaSprite('light', true)
	end
end

function onCreatePost()
	runHaxeCode([[
		function makeCoolShader(hue:Float, sat:Float, bright:Float, contrast:Float)
		{
			var colorShader = new shaders.AdjustColorScreenspace();
			colorShader.setAdjustColor(hue, sat, bright, contrast);
			colorShader.threshold = 1; //no rim lighting here
			return colorShader;
		}
		game.gf.shader = makeCoolShader(-9,0,-30,-4);
        game.dad.shader = makeCoolShader(-32,0,-33,-23);
        game.boyfriend.shader = makeCoolShader(12,0,-23,7);
	]])
end

-- Extra stuff for when the event happens.
function onEvent(event, value1, value2, strumTime)
	if event == 'Dadbattle Spotlight' then
		if value1 == '1' then
			setProperty('smallLight.visible', false)
			setProperty('light.visible', false)
		elseif value1 == '0' then
			setProperty('smallLight.visible', true)
			setProperty('light.visible', true)
		end
	end
end