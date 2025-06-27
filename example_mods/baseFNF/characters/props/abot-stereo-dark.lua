local characterType = ''
local characterName = ''
local looksAtPlayer = true
local offsetData = {0, 0}
local propertyTracker = {
    {'x', nil},
    {'y', nil},
    {'scrollFactor.x', nil},
    {'scrollFactor.y', nil},
    {'angle', nil},
    {'antialiasing', nil},
    {'visible', nil}
}

local visualizerActive = nil
function onCreate()
    --[[
        This is how the script recognizes which option you chose to use.
        However, if you decide to take Abot inside another mod,
        the 'visualizerActive' variable will default to 'true' to avoid any bugs or issues.
    ]]
    if getModSetting('visualizerActive') == nil then
        visualizerActive = true
    else
        visualizerActive = getModSetting('visualizerActive')
    end
end

--[[ 
    Self explanatory, creates the speaker based on if it's attached to a character or not,
    and the inputted offsets. Wait, why did I explain it still?
    Because it also sets up everything needed for the script to work, duh.
]]
function createSpeaker(attachedCharacter, offsetX, offsetY)
    characterName = attachedCharacter
    offsetData = {offsetX, offsetY}
    if getCharacterType(attachedCharacter) ~= nil then
        characterType = getCharacterType(attachedCharacter)
    end

    makeLuaSprite('AbotSpeakerBGDark', 'characters/abot/stereoBG')
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerBGDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeakerBGDark')
    setProperty('AbotSpeakerBGDark.color', 0x616785)
    for bar = 1, 7 do
        makeAnimatedLuaSprite('AbotSpeakerVisualizerDark'..bar, 'characters/abot/aBotViz')
        addAnimationByPrefix('AbotSpeakerVisualizerDark'..bar, 'idle', 'viz'..bar, 24, false)
        addAnimationByPrefix('AbotSpeakerVisualizerDark'..bar, 'visualizer', 'viz'..bar, 0, false)
        if characterType ~= '' then
            setObjectOrder('AbotSpeakerVisualizerDark'..bar, getObjectOrder(characterType..'Group'))
        end
        addLuaSprite('AbotSpeakerVisualizerDark'..bar)
        callMethod('AbotSpeakerVisualizerDark'..bar..'.animation.curAnim.finish')
    end

    makeLuaSprite('AbotEyesDark')
    makeGraphic('AbotEyesDark', 140, 60)
    if characterType ~= '' then
        setObjectOrder('AbotEyesDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotEyesDark')
    setProperty('AbotEyesDark.color', 0x6F96CE)

    makeFlxAnimateSprite('AbotPupilsDark')
    loadAnimateAtlas('AbotPupilsDark', 'characters/abot/systemEyes')
    if characterType ~= '' then
        setObjectOrder('AbotPupilsDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotPupilsDark')

    looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        setProperty('AbotPupilsDark.anim.curFrame', 17)
        callMethod('AbotPupilsDark.anim.pause')
    else
        setProperty('AbotPupilsDark.anim.curFrame', 0)
        callMethod('AbotPupilsDark.anim.pause')
    end
    
    makeFlxAnimateSprite('AbotSpeakerDark')
    loadAnimateAtlas('AbotSpeakerDark', 'characters/abot/abotSystem')
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerDark', getObjectOrder(characterType..'Group'))
    else
        setProperty('AbotSpeakerDark.x', offsetData[1])
        setProperty('AbotSpeakerDark.y', offsetData[2])
    end
    addLuaSprite('AbotSpeakerDark')
    setProperty('AbotSpeakerDark.anim.curFrame', getProperty('AbotSpeakerDark.anim.length') - 1)

    initLuaShader('textureSwap')
    setSpriteShader('AbotSpeakerDark', 'textureSwap')
    setShaderSampler2D('AbotSpeakerDark', 'image', 'characters/abot/dark/abotSystem/spritemap1')
    setShaderFloat('AbotSpeakerDark', 'fadeAmount', 1)

    runHaxeCode([[
        // Visualizer Code
        import funkin.vis.dsp.SpectralAnalyzer;

        var visualizer:SpectralAnalyzer;
        function startVisualizer() {
            visualizer = new SpectralAnalyzer(FlxG.sound.music._channel.__audioSource, 7, 0.1, 40);
            visualizer.fftN = 256;
        }

        function stopVisualizer() {
            visualizer = null;
            for (i in 0...7) getLuaObject('AbotSpeakerVisualizerDark' + (i + 1)).animation.curAnim.finish();
        }

        var levels:Array<Bar>;
	    var levelMax:Int = 0;
        function updateVisualizer() {
            if (visualizer == null) {
                for (i in 0...7) getLuaObject('AbotSpeakerVisualizerDark' + (i + 1)).visible = false;
                return;
            }

            levels = visualizer.getLevels(levels);
		    var oldLevelMax = levelMax;
		    levelMax = 0;
		    for (i in 0...Std.int(Math.min(7, levels.length)))
		    {
                var visualizerBar = getLuaObject('AbotSpeakerVisualizerDark' + (i + 1));
                var animLength:Int = visualizerBar.animation.curAnim.numFrames - 1;

                var animFrame:Int = Math.round(levels[i].value * (animLength + 1));
                visualizerBar.visible = animFrame > 0;
			    animFrame = Std.int(Math.abs(FlxMath.bound((animFrame - 1), 0, animLength) - animLength));
		
                visualizerBar.animation.curAnim.curFrame = animFrame;
			    levelMax = Std.int(Math.max(levelMax, animLength - animFrame));
		    }

            if(levelMax >= 4) {
			    if(oldLevelMax <= levelMax && (levelMax >= 5 || getLuaObject('AbotSpeakerDark').anim.curFrame >= 3))
				    getLuaObject('AbotSpeakerDark').anim.play('', true);
		    }
        }
        
        // Shader Application Code

        function applyShader(object:String, character:String, atlas:Bool) {
            var colorShader = new shaders.AdjustColorScreenspace();
            colorShader.setAdjustColor(-26, -45, 0, -12);
            colorShader.threshold = 1; // no rim lighting
            getLuaObject(object).shader = colorShader;
        }
    ]])

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            showSpeaker(false)
        end
    end
end

-- Self explanatory. Nothing to add this time.
local speakerActive = true
function showSpeaker(value)
    for _, object in ipairs({'AbotSpeakerDark', 'AbotSpeakerBGDark', 'AbotPupilsDark', 'AbotEyesDark'}) do
        setProperty(object..'.visible', value)
    end  
    for bar = 1, 7 do
        setProperty('AbotSpeakerVisualizerDark'..bar..'.visible', value)
    end

    speakerActive = value
    if visualizerActive == true then
        if value == true then 
            runHaxeFunction('startVisualizer')
        else
            runHaxeFunction('stopVisualizer')
        end
    end

    if characterType == '' and value == true then
        characterType = getCharacterType(characterName)
        setProperty('AbotSpeakerDark.x', getProperty(characterType..'.x') + offsetData[1])
        setProperty('AbotSpeakerDark.y', getProperty(characterType..'.y') + offsetData[2])
    end
end

function onEvent(eventName, value1, value2, strumTime)
    -- This is to prevent the speaker from still appearing when the attached character's gone.
    if eventName == 'Change Character' then
        if getCharacterType(value2) == characterType and value2 ~= characterName then
            showSpeaker(false)
        elseif characterName ~= '' then
            showSpeaker(true)
        end
    end
    -- This is to make Abot look at either the player or oppnent while using this camera event.
    if eventName == 'Set Camera Target' then
        for _, startStringBF in ipairs({'0', 'bf', 'boyfriend'}) do
            if stringStartsWith(string.lower(value1), startStringBF) then
                if looksAtPlayer == false then
                    playAnim('AbotPupilsDark', '', true, false, 17)
                end
            end
        end
        for _, startStringDad in ipairs({'1', 'dad', 'opponent'}) do
            if stringStartsWith(string.lower(value1), startStringDad) then
                if looksAtPlayer == true then
                    playAnim('AbotPupilsDark', '', true, false, 0)
                end
            end
        end
    end
end

function onCountdownTick(swagCounter)
    --[[
        Makes the speaker bop at the same time as the character.
        Ex: If the character only bops their head when the beat is even,
        then the speaker will also do the same.
        This will only work during the countdown.
    ]]
    if visualizerActive == false then
        if characterType == 'gf' then
            characterSpeed = getProperty('gfSpeed')
        else
            characterSpeed = 1
        end
        if characterType ~= '' then
            danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
        else
            danceEveryNumBeats = 1
        end
        if swagCounter % (danceEveryNumBeats * characterSpeed) == 0 then
            playAnim('AbotSpeakerDark', '', true, false, 1)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizerDark'..bar, 'idle', true)
            end
        end
    end
end

function onBeatHit()
    --[[
        Ditto, but it works for the entirety of the song.
    ]]
    if visualizerActive == false then
        if characterType == 'gf' then
            characterSpeed = getProperty('gfSpeed')
        else
            characterSpeed = 1
        end
        if characterType ~= '' then
            danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
        else
            danceEveryNumBeats = 1
        end
        if curBeat % (danceEveryNumBeats * characterSpeed) == 0 then
            playAnim('AbotSpeakerDark', '', true, false, 1)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizerDark'..bar, 'idle', true)
            end
        end
    end
end

function onMoveCamera(character)
    -- Abot will look to the right (towards the player).
    if character == 'boyfriend' then
        if looksAtPlayer == false then
            playAnim('AbotPupilsDark', '', true, false, 17)
        end
    end
    -- Abot will look to the left (towards the opponent).
    if character == 'dad' then
        if looksAtPlayer == true then
            playAnim('AbotPupilsDark', '', true, false, 0)
        end
    end
end

function onSongStart()
    -- Starts Abot's Visualizer, if the option has been selected.
    if visualizerActive == true and speakerActive == true then
        runHaxeFunction('startVisualizer')
    end
    for bar = 1, 7 do
        runHaxeFunction('applyShader', {'AbotSpeakerVisualizerDark'..bar, characterType, false})
    end
end

function onEndSong()
    --[[
        Stops Abot's Visualizer, if the option has been selected.
        This is to prevent the speaker from tracking the menu music.
    ]]
    if visualizerActive == true then
        runHaxeFunction('stopVisualizer')
    end
end

function onUpdatePost(elapsed)
    --[[ 
        Updates Abot's Visualizer, if the option has been selected.
        Otherwise, the Visualizer's bars will disappear when the animation is finished.
    ]]
    if visualizerActive == true then
        runHaxeFunction('updateVisualizer')
    elseif speakerActive == true then
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.visible', not getProperty('AbotSpeakerVisualizerDark'..bar..'.animation.finished'))
        end
    end

    --[[ 
        This is what makes Abot track properties and apply them to the entire speaker.
        It also works when the speaker isn't attached to any character, 
        as it'd be annoying to change every part of the speaker manually.
    ]]
    for property = 1, #propertyTracker do
        if characterType ~= '' then
            translateAlpha(getProperty(characterType..'.alpha'))
            if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        else
            if propertyTracker[property][2] ~= getProperty('AbotSpeakerDark.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty('AbotSpeakerDark.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        end
    end
    
    -- These make it so the animations stop when they're supposed to, instead of looping endlessly.
    if getProperty('AbotSpeakerDark.anim.curFrame') >= 15 then
        callMethod('AbotSpeakerDark.anim.pause')
    end
    if looksAtPlayer == true then
        if getProperty('AbotPupilsDark.anim.curFrame') >= 17 then
            looksAtPlayer = false
            callMethod('AbotPupilsDark.anim.pause')
        end
    end
    if looksAtPlayer == false then
        if getProperty('AbotPupilsDark.anim.curFrame') >= 31 then
            looksAtPlayer = true
            callMethod('AbotPupilsDark.anim.pause')
        end
    end
    -- This is how we control the animations' speed depending on the 'playbackRate' for Atlas Sprites.
    setProperty('AbotSpeakerDark.anim.framerate', 24 * playbackRate)
    setProperty('AbotPupilsDark.anim.framerate', 24 * playbackRate)
end

--[[
    Exclusive function for the dark variant of the speaker.
    This controls the look of the speaker when the lighting strikes 
    in 'spookyErect' depending on the attached character's alpha.

    More info inside the 'spookyErect' stage file, 
    and the scripts used for the dark variants of characters.
]]
function translateAlpha(value)
    setVar('vizInterpValue', value)
    setShaderFloat('AbotSpeakerDark', 'fadeAmount', value)
    runHaxeCode([[
        for (i in 0...7) {
            var obj = getLuaObject('AbotSpeakerVisualizerDark' + (i + 1));
            if (obj != null && obj.shader != null) {
                obj.shader.baseHue = parentLua.call('interpolateFloat', [0, -26, getVar('vizInterpValue')]);
                obj.shader.baseSaturation = parentLua.call('interpolateFloat', [0, -45, getVar('vizInterpValue')]);
                obj.shader.baseContrast = parentLua.call('interpolateFloat', [0, 0, getVar('vizInterpValue')]);
                obj.shader.baseBrightness = parentLua.call('interpolateFloat', [0, -12, getVar('vizInterpValue')]);
            }
        }
    ]])

    setProperty('AbotSpeakerBGDark.color', interpolateColor(0xFFFFFF, 0x616785, value))
    setProperty('AbotEyesDark.color', interpolateColor(0xFFFFFF, 0x6F96CE, value))
end

--[[
    This function is used when you change any of the properties of the attached character, 
    or the speaker itself if it's not attached to any character. 
    This only works for the properties present in 'propertyTracker'.

    WARNING: Do not use this function if you want to change Abot Speaker's properties,
    as it is only meant to be used inside this script.
    Instead, use the 'setProperty' function as usual.
    Examples:
    setProperty('boyfriend.alpha', 0.5)     --> If attached to the BF character type.
    setProperty('dad.alpha', 0.5)           --> If attached to the Dad character type.
    setProperty('gf.alpha', 0.5)            --> If attached to the GF character type.
    setProperty('AbotSpeakerDark.alpha', 0.5)   --> If not attached to any character type.

    Other Lua functions also work the same way (except for shader functions in this case).
    Examples:
    - If attached to a character type:
        doTweenX('tweenTestX', 'boyfriend', 500, 3, 'linear')
        doTweenY('tweenTestY', 'dad', 200, 3, 'linear')
        doTweenColor('tweenTestColor', 'gf', 'FF0000', 3, 'linear')
    
    - If not attached to a character type:
        doTweenX('tweenTestX', 'AbotSpeakerDark', 500, 3, 'linear')
        doTweenY('tweenTestY', 'AbotSpeakerDark', 200, 3, 'linear')
]]
function setAbotSpeakerProperty(property, value)
    if property == 'x' then
        if characterType ~= '' then
            value = value + offsetData[1]
            setProperty('AbotSpeakerDark.'..property, value - 100)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, getProperty('AbotSpeakerDark.'..property) + 200 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBGDark.'..property, getProperty('AbotSpeakerDark.'..property) + 165)
        setProperty('AbotEyesDark.'..property, getProperty('AbotSpeakerDark.'..property) + 30)
        setProperty('AbotPupilsDark.'..property, getProperty('AbotSpeakerDark.'..property) - 507)
    elseif property == 'y' then
        if characterType ~= '' then
            value = value + offsetData[2]
            setProperty('AbotSpeakerDark.'..property, value + 316)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, getProperty('AbotSpeakerDark.'..property) + 84 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBGDark.'..property, getProperty('AbotSpeakerDark.'..property) + 30)
        setProperty('AbotEyesDark.'..property, getProperty('AbotSpeakerDark.'..property) + 230)
        setProperty('AbotPupilsDark.'..property, getProperty('AbotSpeakerDark.'..property) - 492)
    else
        if characterType ~= '' then
            setProperty('AbotSpeakerDark.'..property, value)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, value)
        end
        setProperty('AbotSpeakerBGDark.'..property, value)
        setProperty('AbotEyesDark.'..property, value)
        setProperty('AbotPupilsDark.'..property, value)
    end
end

--[[ Old version of the function above.
function updateSpeaker(property)
    if property == 'x' then
        setProperty('AbotSpeakerDark.'..property, offset.x - 100)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, offset.x + 100 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBGDark.'..property, offset.x + 65)
        setProperty('AbotEyesDark.'..property, offset.x - 60)
        setProperty('AbotPupilsDark.'..property, offset.x - 607)
    elseif property == 'y' then
        setProperty('AbotSpeakerDark.'..property, offset.y + 316)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, offset.y + 400 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBGDark.'..property, offset.y + 347)
        setProperty('AbotEyesDark.'..property, offset.y + 567)
        setProperty('AbotPupilsDark.'..property, offset.y - 176)
    elseif characterType ~= '' then
        setProperty('AbotSpeakerDark.'..property, getProperty(characterType..'.'..property))
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerDark'..bar..'.'..property, getProperty(characterType..'.'..property))
        end
        setProperty('AbotSpeakerBGDark.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotEyesDark.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotPupilsDark.'..property, getProperty(characterType..'.'..property))
    end
end
]]

--[[
    This handles the offsets for each visualizer bar.
    Again, it is to make things automatic instead of doing everything manually.
]]
local visualizerPosX = {0, 59, 56, 66, 54, 52, 51}
local visualizerPosY = {0, -8, -3.5, -0.4, 0.5, 4.7, 7}
function visualizerOffsetX(bar)
    local i = 1
    local offsetX = 0
    while i <= bar do
        offsetX = offsetX + visualizerPosX[i]
        i = i + 1
    end
    return offsetX
end

function visualizerOffsetY(bar)
    local i = 1
    local offsetY = 0
    while i <= bar do
        offsetY = offsetY + visualizerPosY[i]
        i = i + 1
    end
    return offsetY
end

-- This handles which color to return between two set colors, depending on the factor.
function interpolateColor(color1, color2, factor)
    redColor1 = color1 / (16^4)
    greenColor1 = (redColor1 - math.floor(redColor1)) * 256
    blueColor1 = (greenColor1 - math.floor(greenColor1)) * 256

    redColor2 = color2 / (16^4)
    greenColor2 = (redColor2 - math.floor(redColor2)) * 256
    blueColor2 = (greenColor2 - math.floor(greenColor2)) * 256

    targetRed = (math.floor(redColor2) - math.floor(redColor1)) * factor + math.floor(redColor1)
    targetGreen = (math.floor(greenColor2) - math.floor(greenColor1)) * factor + math.floor(greenColor1)
    targetBlue = (math.floor(blueColor2) - math.floor(blueColor1)) * factor + math.floor(blueColor1)
    
    return math.floor(targetRed) * 16^4 + math.floor(targetGreen) * 16^2 + math.floor(targetBlue)
end

-- Ditto, but for float values.
function interpolateFloat(value1, value2, factor)
    return (value2 - value1) * factor + value1
end

function getCharacterType(characterName)
    if boyfriendName == characterName then
        return 'boyfriend'
    elseif dadName == characterName then
        return 'dad'
    elseif gfName == characterName then
        return 'gf'
    end
end
