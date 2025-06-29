local characterType = ''
local characterName = ''
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
--[[ 
    Self explanatory, creates the speaker based on if if's attached to a character or not,
    and the inputted offsets. Wait, why did I explain it still?
    Because it also syncs up the speaker's shader with the character's, if it's attached to one.
]]
function createSpeaker(attachedCharacter, offsetX, offsetY)
    characterName = attachedCharacter
    offsetData = {offsetX, offsetY}
    if getCharacterType(attachedCharacter) ~= nil then
        characterType = getCharacterType(attachedCharacter)
    end

    if not luaSpriteExists('speaker') then
        makeAnimatedLuaSprite('speaker', 'characters/speaker_assets')
        addAnimationByPrefix('speaker', 'idle', 'bumpBox', 24, false)
        if characterType ~= '' then
            setObjectOrder('speaker', getObjectOrder(characterType..'Group'))
        end
        addLuaSprite('speaker')
    else
        setProperty('speaker.visible', true)
    end
    
    if characterType ~= '' then
        runHaxeCode([[
            function shaderCheck() return getLuaObject('speaker').shader == ]]..characterType..[[.shader;
            function applyShader() getLuaObject('speaker').shader = ]]..characterType..[[.shader;
        ]])
    end
    
    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            setProperty('speaker.visible', false)
        end
    end
end

-- This is to prevent the speaker from still appearing when the attached character's gone.
function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Change Character' then
        if getCharacterType(value2) == characterType and value2 ~= characterName then
            setProperty('speaker.visible', false)
        elseif characterName ~= '' then
            createSpeaker(characterName, offsetData[1], offsetData[2])
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
        playAnim('speaker', 'idle', true)
    end
end

function onBeatHit()
    --[[
        Ditto, but it works for every beat of the song.
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
        playAnim('speaker', 'idle', true)
    end
end

-- Makes the speaker have the same properties as the character, if attached to one.
function onUpdatePost(elapsed)
    for property = 1, #propertyTracker do
        if characterType ~= '' then
            if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
            
                local propertyName = propertyTracker[property][1]
            
                -- Skip alpha update if stage is spookyErect
                if propertyName == 'alpha' and string.lower(curStage) == 'spookyerect' then
                    -- do nothing
                elseif property < 3 then
                    setProperty('speaker.'..propertyName, propertyTracker[property][2] + offsetData[property])
                else
                    setProperty('speaker.'..propertyName, propertyTracker[property][2])
                end
            end            
        end
    end
    if characterType ~= '' then
        if runHaxeFunction('shaderCheck') == false then
            runHaxeFunction('applyShader')
        end
    end
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