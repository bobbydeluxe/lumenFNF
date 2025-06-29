--[[
    This script fixes an issue related to the 'Change Character' event.
    If you used it when the character had shaders on, 
    it would duplicate the character with a potential bugged shader,
    and spawn the new character without the shaders.

    DISCLAIMER!!!
    Although this script is pretty useful for simple shaders,
    you might have to reset some shader values in other scripts
    to make your shaders work correctly.
    (Just like in Stress (Pico Mix) with Tankman and the dropShadow shader.)

    Also, if you use this script in another mod, credits will be appreciated! - Ledonic
]]

local characterEventTiming = {}
function onCreatePost()
    local index = 0
    for i = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', i, 'event') == 'Change Character' then
            index = index + 1   
            characterEventTiming[index] = {
                charType = getCharacterType(getPropertyFromGroup('eventNotes', i, 'value1')),
                strumTime = getPropertyFromGroup('eventNotes', i, 'strumTime'),
                shaderSaved = false
            }
        end
    end

    runHaxeCode([[
        var bfShader:FlxRuntimeShader;
        var dadShader:FlxRuntimeShader;
        var gfShader:FlxRuntimeShader;

        function saveShader(character:String) {
            switch(character) {
                case 'boyfriend':
                    bfShader = game.boyfriend.shader;
                case 'dad':
                    dadShader = game.dad.shader;
                case 'gf':
                    gfShader = game.gf.shader;
                default:
                    return;
            }
        }

        function applyShader(character:String) {
            switch(character) {
                case 'boyfriend':
                    game.boyfriend.shader = bfShader;
                case 'dad':
                    game.dad.shader = dadShader;
                case 'gf':
                    game.gf.shader = gfShader;
                default:
                    return;
            }
        }
    ]])
end

function onEvent(event, value1, value2, strumTime)
    if event == 'Change Character' then
        runHaxeFunction('applyShader', {getCharacterType(value1)})
    end
end

function onUpdate(elapsed)
    for i = 1, #characterEventTiming do
        if characterEventTiming[i].shaderSaved == false then
            if getSongPosition() >= characterEventTiming[i].strumTime - (elapsed * 1000 * playbackRate) then
                runHaxeFunction('saveShader', {characterEventTiming[i].charType})
                removeSpriteShader(characterEventTiming[i].charType)
                characterEventTiming[i].shaderSaved = true
            end
        end
    end
end

function getCharacterType(stringValue)
    stringValue = string.lower(stringValue)
    if stringValue == '0' or stringValue == 'bf' or stringValue == 'boyfriend' then
        return 'boyfriend'
    elseif stringValue == '1' or stringValue == 'dad' or stringValue == 'opponent' then
        return 'dad'
    elseif stringValue == '2' or stringValue == 'gf' or stringValue == 'girlfriend' then
        return 'gf'
    end
end