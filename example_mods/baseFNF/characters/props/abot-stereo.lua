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

    makeLuaSprite('AbotSpeakerBG', 'characters/abot/stereoBG')
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerBG', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeakerBG')

    for bar = 1, 7 do
        makeAnimatedLuaSprite('AbotSpeakerVisualizer'..bar, 'characters/abot/aBotViz')
        addAnimationByPrefix('AbotSpeakerVisualizer'..bar, 'idle', 'viz'..bar, 24, false)
        addAnimationByPrefix('AbotSpeakerVisualizer'..bar, 'visualizer', 'viz'..bar, 0, false)
        if characterType ~= '' then
            setObjectOrder('AbotSpeakerVisualizer'..bar, getObjectOrder(characterType..'Group'))
        end
        addLuaSprite('AbotSpeakerVisualizer'..bar)
        callMethod('AbotSpeakerVisualizer'..bar..'.animation.curAnim.finish')
    end

    makeLuaSprite('AbotEyes')
    makeGraphic('AbotEyes', 140, 60)
    if characterType ~= '' then
        setObjectOrder('AbotEyes', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotEyes')

    makeFlxAnimateSprite('AbotPupils')
    loadAnimateAtlas('AbotPupils', 'characters/abot/systemEyes')
    if characterType ~= '' then
        setObjectOrder('AbotPupils', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotPupils')

    looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        setProperty('AbotPupils.anim.curFrame', 17)
        callMethod('AbotPupils.anim.pause')
    else
        setProperty('AbotPupils.anim.curFrame', 0)
        callMethod('AbotPupils.anim.pause')
    end
    
    makeFlxAnimateSprite('AbotSpeaker')
    loadAnimateAtlas('AbotSpeaker', 'characters/abot/abotSystem')
    if characterType ~= '' then
        setObjectOrder('AbotSpeaker', getObjectOrder(characterType..'Group'))
    else
        setProperty('AbotSpeaker.x', offsetData[1])
        setProperty('AbotSpeaker.y', offsetData[2])
    end
    addLuaSprite('AbotSpeaker')
    setProperty('AbotSpeaker.anim.curFrame', getProperty('AbotSpeaker.anim.length') - 1)

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
            for (i in 0...7) getLuaObject('AbotSpeakerVisualizer' + (i + 1)).animation.curAnim.finish();
        }

        var levels:Array<Bar>;
	    var levelMax:Int = 0;
        function updateVisualizer() {
            if (visualizer == null) {
                for (i in 0...7) getLuaObject('AbotSpeakerVisualizer' + (i + 1)).visible = false;
                return;
            }

            levels = visualizer.getLevels(levels);
		    var oldLevelMax = levelMax;
		    levelMax = 0;
		    for (i in 0...Std.int(Math.min(7, levels.length)))
		    {
                var visualizerBar = getLuaObject('AbotSpeakerVisualizer' + (i + 1));
                var animLength:Int = visualizerBar.animation.curAnim.numFrames - 1;

                var animFrame:Int = Math.round(levels[i].value * (animLength + 1));
                visualizerBar.visible = animFrame > 0;
			    animFrame = Std.int(Math.abs(FlxMath.bound((animFrame - 1), 0, animLength) - animLength));
		
                visualizerBar.animation.curAnim.curFrame = animFrame;
			    levelMax = Std.int(Math.max(levelMax, animLength - animFrame));
		    }

            if(levelMax >= 4) {
			    if(oldLevelMax <= levelMax && (levelMax >= 5 || getLuaObject('AbotSpeaker').anim.curFrame >= 3))
				    getLuaObject('AbotSpeaker').anim.play('', true);
		    }
        }

        // Shader Tracking Code
        function shaderCheck(object:String, character:String) return getLuaObject(object).shader == getAttachedCharacter(character).shader;
        function shaderAtlasCheck(object:String, character:String) return game.variables.get(object).shader == getAttachedCharacter(character).shader;
        
        function applyShader(object:String, character:String, atlas:Bool) {
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
                if (atlas) {
                    game.variables.get(object).shader = colorShader;
                }
                else {
                    getLuaObject(object).shader = colorShader;
                }
            }
            else {
                if (atlas) {
                    game.variables.get(object).shader = baseShader;
                }
                else {
                    getLuaObject(object).shader = baseShader;
                }
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
                    return getLuaObject('AbotSpeaker');
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
    for _, object in ipairs({'AbotSpeaker', 'AbotSpeakerBG', 'AbotPupils', 'AbotEyes'}) do
        setProperty(object..'.visible', value)
    end  
    for bar = 1, 7 do
        setProperty('AbotSpeakerVisualizer'..bar..'.visible', value)
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
        setProperty('AbotSpeaker.x', getProperty(characterType..'.x') + offsetData[1])
        setProperty('AbotSpeaker.y', getProperty(characterType..'.y') + offsetData[2])
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
                    playAnim('AbotPupils', '', true, false, 17)
                end
            end
        end
        for _, startStringDad in ipairs({'1', 'dad', 'opponent'}) do
            if stringStartsWith(string.lower(value1), startStringDad) then
                if looksAtPlayer == true then
                    playAnim('AbotPupils', '', true, false, 0)
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
            playAnim('AbotSpeaker', '', true, false, 1)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizer'..bar, 'idle', true)
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
            playAnim('AbotSpeaker', '', true, false, 1)
            for bar = 1, 7 do
                playAnim('AbotSpeakerVisualizer'..bar, 'idle', true)
            end
        end
    end
end

function onMoveCamera(character)
    -- Abot will look to the right (towards the player).
    if character == 'boyfriend' then
        if looksAtPlayer == false then
            playAnim('AbotPupils', '', true, false, 17)
        end
    end
    -- Abot will look to the left (towards the opponent).
    if character == 'dad' then
        if looksAtPlayer == true then
            playAnim('AbotPupils', '', true, false, 0)
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
            setProperty('AbotSpeakerVisualizer'..bar..'.visible', not getProperty('AbotSpeakerVisualizer'..bar..'.animation.finished'))
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
            if propertyTracker[property][2] ~= getProperty('AbotSpeaker.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty('AbotSpeaker.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        end
    end

    -- Ditto, but for shaders.
    if getVar('trackShader') == true then
        for _, object in ipairs({'AbotSpeaker', 'AbotPupils'}) do
            if runHaxeFunction('shaderAtlasCheck', {object, characterType}) == false then
                runHaxeFunction('applyShader', {object, characterType, true})
            end
        end
        for bar = 1, 7 do
            if runHaxeFunction('shaderCheck', {'AbotSpeakerVisualizer'..bar, characterType}) == false then
                runHaxeFunction('applyShader', {'AbotSpeakerVisualizer'..bar, characterType, false})
            end
        end
        for _, object in ipairs({'AbotSpeakerBG', 'AbotEyes'}) do
            if runHaxeFunction('shaderCheck', {object, characterType}) == false then
                runHaxeFunction('applyShader', {object, characterType, false})
            end
        end
    end

    -- These make it so the animations stop when they're supposed to, instead of looping endlessly.
    if getProperty('AbotSpeaker.anim.curFrame') >= 15 then
        callMethod('AbotSpeaker.anim.pause')
    end
    if looksAtPlayer == true then
        if getProperty('AbotPupils.anim.curFrame') >= 17 then
            looksAtPlayer = false
            callMethod('AbotPupils.anim.pause')
        end
    end
    if looksAtPlayer == false then
        if getProperty('AbotPupils.anim.curFrame') >= 31 then
            looksAtPlayer = true
            callMethod('AbotPupils.anim.pause')
        end
    end

    -- This is how we control the animations' speed depending on the 'playbackRate' for Atlas Sprites.
    setProperty('AbotSpeaker.anim.framerate', 24 * playbackRate)
    setProperty('AbotPupils.anim.framerate', 24 * playbackRate)
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
    setProperty('AbotSpeaker.alpha', 0.5)   --> If not attached to any character type.

    Other Lua functions also work the same way.
    Examples:
    - If attached to a character type:
        doTweenX('tweenTestX', 'boyfriend', 500, 3, 'linear')
        doTweenY('tweenTestY', 'dad', 200, 3, 'linear')
        doTweenColor('tweenTestColor', 'gf', 'FF0000', 3, 'linear')
    
    - If not attached to a character type:
        setSpriteShader('AbotSpeaker', 'shaderName')
        setShaderFloat('AbotSpeaker', 'shaderValue', value)
]]
function setAbotSpeakerProperty(property, value)
    if property == 'x' then
        if characterType ~= '' then
            value = value + offsetData[1]
            setProperty('AbotSpeaker.'..property, value - 100)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, getProperty('AbotSpeaker.'..property) + 200 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBG.'..property, getProperty('AbotSpeaker.'..property) + 165)
        setProperty('AbotEyes.'..property, getProperty('AbotSpeaker.'..property) + 30)
        setProperty('AbotPupils.'..property, getProperty('AbotSpeaker.'..property) - 507)
    elseif property == 'y' then
        if characterType ~= '' then
            value = value + offsetData[2]
            setProperty('AbotSpeaker.'..property, value + 316)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, getProperty('AbotSpeaker.'..property) + 84 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBG.'..property, getProperty('AbotSpeaker.'..property) + 30)
        setProperty('AbotEyes.'..property, getProperty('AbotSpeaker.'..property) + 230)
        setProperty('AbotPupils.'..property, getProperty('AbotSpeaker.'..property) - 492)
    else
        if characterType ~= '' then
            setProperty('AbotSpeaker.'..property, value)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, value)
        end
        setProperty('AbotSpeakerBG.'..property, value)
        setProperty('AbotEyes.'..property, value)
        setProperty('AbotPupils.'..property, value)
    end
end

--[[ Old version of the function above.

function updateSpeaker(property)
    if property == 'x' then
        setProperty('AbotSpeaker.'..property, offset.x - 100)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, offset.x + 100 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBG.'..property, offset.x + 65)
        setProperty('AbotEyes.'..property, offset.x - 60)
        setProperty('AbotPupils.'..property, offset.x - 607)
    elseif property == 'y' then
        setProperty('AbotSpeaker.'..property, offset.y + 316)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, offset.y + 400 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBG.'..property, offset.y + 347)
        setProperty('AbotEyes.'..property, offset.y + 567)
        setProperty('AbotPupils.'..property, offset.y - 176)
    elseif characterType ~= '' then
        setProperty('AbotSpeaker.'..property, getProperty(characterType..'.'..property))
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, getProperty(characterType..'.'..property))
        end
        setProperty('AbotSpeakerBG.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotEyes.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotPupils.'..property, getProperty(characterType..'.'..property))
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

function getCharacterType(characterName)
    if boyfriendName == characterName then
        return 'boyfriend'
    elseif dadName == characterName then
        return 'dad'
    elseif gfName == characterName then
        return 'gf'
    end
end