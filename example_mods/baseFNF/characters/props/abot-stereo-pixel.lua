local characterType = ''
local characterName = ''
local looksAtPlayer = nil
local offsetData = {0, 0}
local propertyTracker = {
    {'x', nil},
    {'y', nil},
    {'color', nil},
    {'scrollFactor.x', nil},
    {'scrollFactor.y', nil},
    {'angle', nil},
    {'alpha', nil},
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

    --[[
        WARNING!!!
        Only set this variable to false if you want to set up specific shaders 
        to each individual part of Abot. Else, refer to line 376 to know how to set shaders globally.
    ]]
    if getVar('trackShader') == nil then
        setVar('trackShader', true)
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

    makeAnimatedLuaSprite('AbotHeadPixel', 'characters/abot/pixel/abotHead')
    addAnimationByPrefix('AbotHeadPixel', 'lookLeft', 'toleft', 24, false)
    addAnimationByPrefix('AbotHeadPixel', 'lookRight', 'toright', 24, false)
    scaleObject('AbotHeadPixel', 6, 6)
    if characterType ~= '' then
        setObjectOrder('AbotHeadPixel', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotHeadPixel')
    setProperty('AbotHeadPixel.antialiasing', false)

    looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        playAnim('AbotHeadPixel', 'lookLeft', true)
        callMethod('AbotHeadPixel.animation.curAnim.finish')
    else
        playAnim('AbotHeadPixel', 'lookRight', true)
        callMethod('AbotHeadPixel.animation.curAnim.finish')
    end
    
    makeAnimatedLuaSprite('AbotPixelSpeakers', 'characters/abot/pixel/aBotPixelSpeaker')
    addAnimationByPrefix('AbotPixelSpeakers', 'idle', 'bop', 24, false)
    scaleObject('AbotPixelSpeakers', 6, 6)
    if characterType ~= '' then
        setObjectOrder('AbotPixelSpeakers', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotPixelSpeakers')
    setProperty('AbotPixelSpeakers.antialiasing', false)
    callMethod('AbotPixelSpeakers.animation.curAnim.finish')
    
    makeLuaSprite('AbotSpeakerBGPixel', 'characters/abot/pixel/aBotPixelBack')
    scaleObject('AbotSpeakerBGPixel', 6, 6)
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerBGPixel', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeakerBGPixel')
    setProperty('AbotSpeakerBGPixel.antialiasing', false)

    for bar = 1, 7 do
        makeAnimatedLuaSprite('AbotSpeakerVisualizerPixel'..bar, 'characters/abot/pixel/aBotVizPixel')
        addAnimationByPrefix('AbotSpeakerVisualizerPixel'..bar, 'visualizer', 'viz'..bar, 0, false)
        addAnimationByPrefix('AbotSpeakerVisualizerPixel'..bar, 'idle', 'viz'..bar, 24, false)
        scaleObject('AbotSpeakerVisualizerPixel'..bar, 6, 6)
        if characterType ~= '' then
            setObjectOrder('AbotSpeakerVisualizerPixel'..bar, getObjectOrder(characterType..'Group'))
        end
        addLuaSprite('AbotSpeakerVisualizerPixel'..bar)
        setProperty('AbotSpeakerVisualizerPixel'..bar..'.antialiasing', false)
        callMethod('AbotSpeakerVisualizerPixel'..bar..'.animation.curAnim.finish')
    end
    
    makeAnimatedLuaSprite('AbotSpeakerPixel', 'characters/abot/pixel/aBotPixelBody')
    addAnimationByPrefix('AbotSpeakerPixel', 'idle', 'bop', 24, false)
    scaleObject('AbotSpeakerPixel', 6, 6)
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerPixel', getObjectOrder(characterType..'Group'))
    else
        setProperty('AbotSpeakerPixel.x', offsetData[1])
        setProperty('AbotSpeakerPixel.y', offsetData[2])
    end
    addLuaSprite('AbotSpeakerPixel')
    setProperty('AbotSpeakerPixel.antialiasing', false)
    callMethod('AbotSpeakerPixel.animation.curAnim.finish')

    runHaxeCode([[
        // Visualizer Code
        import funkin.vis.dsp.SpectralAnalyzer;
        import shaders.AdjustColorScreenspace;

        var visualizer:SpectralAnalyzer;
        function startVisualizer() {
            visualizer = new SpectralAnalyzer(FlxG.sound.music._channel.__audioSource, 7, 0.1, 40);
            visualizer.fftN = 256;
        }

        function stopVisualizer() {
            visualizer = null;
            for (i in 0...7) getLuaObject('AbotSpeakerVisualizerPixel' + (i + 1)).animation.curAnim.finish();
        }

        var levels:Array<Bar>;
	    var levelMax:Int = 0;
        function updateVisualizer() {
            if (visualizer == null) {
                for (i in 0...7) getLuaObject('AbotSpeakerVisualizerPixel' + (i + 1)).visible = false;
                return;
            }

            levels = visualizer.getLevels(levels);
		    var oldLevelMax = levelMax;
		    levelMax = 0;
		    for (i in 0...Std.int(Math.min(7, levels.length)))
		    {
                var visualizerBar = getLuaObject('AbotSpeakerVisualizerPixel' + (i + 1));
                var animLength:Int = visualizerBar.animation.curAnim.numFrames - 1;

                var animFrame:Int = Math.round(levels[i].value * (animLength + 1));
                visualizerBar.visible = animFrame > 0;
			    animFrame = Std.int(Math.abs(FlxMath.bound((animFrame - 1), 0, animLength) - animLength));
		
                visualizerBar.animation.curAnim.curFrame = animFrame;
			    levelMax = Std.int(Math.max(levelMax, animLength - animFrame));
		    }

            if(levelMax >= 4) {
			    if(oldLevelMax <= levelMax && (levelMax >= 5 || getLuaObject('AbotPixelSpeakers').animation.curAnim.curFrame >= 5))
				    getLuaObject('AbotPixelSpeakers').animation.play('idle', true, false, 2);
		    }
        }

        // Shader Tracking Code
        function shaderCheck(object:String, character:String) return getLuaObject(object).shader == getAttachedCharacter(character).shader;
        
        function applyShader(object:String, character:String) {
            var baseShader = getAttachedCharacter(character).shader;
            if (Std.isOfType(baseShader, AdjustColorScreenspace)) {
                var colorShader = new shaders.AdjustColorScreenspace();
                colorShader.setAdjustColor(
                    baseShader.hue.value[0],
                    baseShader.saturation.value[0],
                    baseShader.brightness.value[0],
                    baseShader.contrast.value[0]
                );
                colorShader.threshold = 1;
                getLuaObject(object).shader = colorShader;
            }
            else {
                getLuaObject(object).shader = baseShader;
            }
        }

        function getAttachedCharacter(character:String) {
            switch(character) {
                case 'boyfriend':
                    return game.boyfriend;
                case 'dad':
                    return game.dad;
                case 'gf':
                    return game.gf;
                default:
                    return getLuaObject('AbotSpeakerPixel');
            }
        }
    ]])

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            showSpeaker(false)
        end
    end
end

local speakerActive = true
-- Self explanatory. Nothing to add this time.
function showSpeaker(value)
    for _, object in ipairs({'AbotSpeakerPixel', 'AbotPixelSpeakers', 'AbotSpeakerBGPixel', 'AbotHeadPixel'}) do
        setProperty(object..'.visible', value)
    end  
    for bar = 1, 7 do
        setProperty('AbotSpeakerVisualizerPixel'..bar..'.visible', value)
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
        setProperty('AbotSpeakerPixel.x', getProperty(characterType..'.x') + offsetData[1])
        setProperty('AbotSpeakerPixel.y', getProperty(characterType..'.y') + offsetData[2])
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
                    playAnim('AbotHeadPixel', 'lookRight', true)
                    looksAtPlayer = true
                end
            end
        end
        for _, startStringDad in ipairs({'1', 'dad', 'opponent'}) do
            if stringStartsWith(string.lower(value1), startStringDad) then
                if looksAtPlayer == true then
                    playAnim('AbotHeadPixel', 'lookLeft', true)
                    looksAtPlayer = false
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
        playAnim('AbotSpeakerPixel', 'idle', true)
        if visualizerActive == false then
            playAnim('AbotPixelSpeakers', 'idle', true)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizerPixel'..bar, 'idle', true)
            end
        end
    end
end

function onBeatHit()
    --[[
        Ditto, but it works for the entirety of the song.
    ]]
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
        playAnim('AbotSpeakerPixel', 'idle', true)
        if visualizerActive == false then
            playAnim('AbotPixelSpeakers', 'idle', true)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizerPixel'..bar, 'idle', true)
            end
        end
    end
end

function onMoveCamera(character)
    -- Abot will look to the right (towards the player).
    if character == 'boyfriend' then
        if looksAtPlayer == false then
            playAnim('AbotHeadPixel', 'lookRight', true)
            looksAtPlayer = true
        end
    end
    -- Abot will look to the left (towards the opponent).
    if character == 'dad' then
        if looksAtPlayer == true then
            playAnim('AbotHeadPixel', 'lookLeft', true)
            looksAtPlayer = false
        end
    end
end

function onSongStart()
    -- Starts Abot's Visualizer, if the option has been selected.
    if visualizerActive == true and speakerActive == true then
        runHaxeFunction('startVisualizer')
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
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.visible', not getProperty('AbotSpeakerVisualizerPixel'..bar..'.animation.finished'))
        end
    end

    --[[ 
        This is what makes Abot track properties and apply them to the entire speaker.
        It also works when the speaker isn't attached to any character, 
        as it'd be annoying to change every part of the speaker manually.
    ]]
    for property = 1, #propertyTracker do
        if characterType ~= '' then
            if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        else
            if propertyTracker[property][2] ~= getProperty('AbotSpeakerPixel.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty('AbotSpeakerPixel.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        end
    end

    -- Ditto, but for shaders.
    if getVar('trackShader') == true then
        for _, object in ipairs({'AbotSpeakerPixel', 'AbotPixelSpeakers', 'AbotHeadPixel', 'AbotSpeakerBGPixel'}) do
            if runHaxeFunction('shaderCheck', {object, characterType}) == false then
                runHaxeFunction('applyShader', {object, characterType})
            end
        end
        for bar = 1, 7 do
            if runHaxeFunction('shaderCheck', {'AbotSpeakerVisualizerPixel'..bar, characterType}) == false then
                runHaxeFunction('applyShader', {'AbotSpeakerVisualizerPixel'..bar, characterType})
            end
        end
    end
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
    setProperty('AbotSpeakerPixel.alpha', 0.5)   --> If not attached to any character type.

    Other Lua functions also work the same way.
    Examples:
    - If attached to a character type:
        doTweenX('tweenTestX', 'boyfriend', 500, 3, 'linear')
        doTweenY('tweenTestY', 'dad', 200, 3, 'linear')
        doTweenColor('tweenTestColor', 'gf', 'FF0000', 3, 'linear')
    
    - If not attached to a character type:
        setSpriteShader('AbotSpeakerPixel', 'shaderName')
        setShaderFloat('AbotSpeakerPixel', 'shaderValue', value)
]]
function setAbotSpeakerProperty(property, value)
    if property == 'x' then
        if characterType ~= '' then
            value = value + offsetData[1]
            setProperty('AbotSpeakerPixel.'..property, value - 100)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, getProperty('AbotSpeakerPixel.'..property) + 78 + (visualizerOffsetX(bar) * 6))
        end
        setProperty('AbotPixelSpeakers.'..property, getProperty('AbotSpeakerPixel.'..property) - 138)
        setProperty('AbotSpeakerBGPixel.'..property, getProperty('AbotSpeakerPixel.'..property) + 18)
        setProperty('AbotHeadPixel.'..property, getProperty('AbotSpeakerPixel.'..property) - 137)
    elseif property == 'y' then
        if characterType ~= '' then
            value = value + offsetData[2]
            setProperty('AbotSpeakerPixel.'..property, value + 90)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, getProperty('AbotSpeakerPixel.'..property) + 85 + (visualizerOffsetY(bar) * 6))
        end
        setProperty('AbotPixelSpeakers.'..property, getProperty('AbotSpeakerPixel.'..property) + 24)
        setProperty('AbotSpeakerBGPixel.'..property, getProperty('AbotSpeakerPixel.'..property) + 35)
        setProperty('AbotHeadPixel.'..property, getProperty('AbotSpeakerPixel.'..property) + 100)
    else
        if characterType ~= '' then
            setProperty('AbotSpeakerPixel.'..property, value)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, value)
        end
        setProperty('AbotPixelSpeakers.'..property, getProperty('AbotSpeakerPixel.'..property))
        setProperty('AbotSpeakerBGPixel.'..property, value)
        setProperty('AbotHeadPixel.'..property, getProperty('AbotSpeakerPixel.'..property))
    end
end

--[[ Old version of the function above.

function updateSpeaker(property)
    if property == 'x' then
        setProperty('AbotSpeakerPixel.'..property, offset.x - 100)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, offset.x + 100 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBGPixel.'..property, offset.x + 65)
        setProperty('AbotEyes.'..property, offset.x - 60)
        setProperty('AbotPupils.'..property, offset.x - 607)
    elseif property == 'y' then
        setProperty('AbotSpeakerPixel.'..property, offset.y + 316)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, offset.y + 400 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBGPixel.'..property, offset.y + 347)
        setProperty('AbotEyes.'..property, offset.y + 567)
        setProperty('AbotPupils.'..property, offset.y - 176)
    elseif characterType ~= '' then
        setProperty('AbotSpeakerPixel.'..property, getProperty(characterType..'.'..property))
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizerPixel'..bar..'.'..property, getProperty(characterType..'.'..property))
        end
        setProperty('AbotSpeakerBGPixel.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotEyes.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotPupils.'..property, getProperty(characterType..'.'..property))
    end
end
]]

--[[
    This handles the offsets for each visualizer bar.
    Again, it is to make things automatic instead of doing everything manually.
]]
local visualizerPosX = {0, 7, 8, 9, 10, 6, 7}
local visualizerPosY = {0, -2, -1, 0, 0, 1, 2}
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

function getCharacterType(characterName)
    if boyfriendName == characterName then
        return 'boyfriend'
    elseif dadName == characterName then
        return 'dad'
    elseif gfName == characterName then
        return 'gf'
    end
end